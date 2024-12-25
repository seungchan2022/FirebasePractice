import Architecture
import Domain
import Firebase
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser
import UIKit

// MARK: - AuthUseCasePlatform

public struct AuthUseCasePlatform {
  public init() { }
}

// MARK: AuthUseCase

extension AuthUseCasePlatform: AuthUseCase {

  public var signUpEmail: (AuthEntity.Email.Request) async throws -> Bool {
    { req in
      do {
        let _ = try await createUser(email: req.email, password: req.password)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var signInEmail: (AuthEntity.Email.Request) async throws -> Bool {
    { req in
      do {
        let _ = try await loginUser(email: req.email, password: req.password)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var signInGoogle: () async throws -> Bool {
    {
      do {
        let tokens = try await googleSignIn()
        try await signInWithGoogle(tokens: tokens)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var signInApple: () async throws -> Bool {
    {
      do {
        let helper = await AppleAuthHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        try await signInWithApple(tokens: tokens)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var signInKakao: () async throws -> Bool {
    {
      do {
        return try await signInWithKakao()
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var me: () throws -> AuthEntity.Me.Response {
    {
      guard let user = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }

      return user.serialized()
    }
  }

  public var signOut: () throws -> Bool {
    {
      do {
        try logOut()
        
        if AuthApi.hasToken() {
          signOutWithKakao()
        }
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var updatePassword: (String, String) async throws -> Bool {
    { currPassword, newPassword in
      do {
        let _ = try await updatePassword(currPassword: currPassword, newPassword: newPassword)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var deleteUser: (String) async throws -> Bool {
    { currPassword in
      do {
        let _ = try await deleteUser(password: currPassword)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var resetPassword: (String) async throws -> Bool {
    { email in
      do {
        let _ = try await sendPasswordReset(email: email)
        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getProvider: () throws -> [AuthEntity.ProviderOption.Option] {
    {
      guard let providerData = Auth.auth().currentUser?.providerData else { throw CompositeErrorRepository.invalidTypeCasting }

      var itemList: [AuthEntity.ProviderOption.Option] = []
      for provider in providerData {
        if let option = AuthEntity.ProviderOption.Option(rawValue: provider.providerID) {
          itemList = itemList + [option]
        } else {
          assertionFailure("Provider option not found: \(provider.providerID)")
        }
      }

      return itemList
    }
  }
}

// MARK: Email
extension AuthUseCasePlatform {
  func createUser(email: String, password: String) async throws -> AuthEntity.Me.Response {
    let me = try await Auth.auth().createUser(withEmail: email, password: password)

    let userName = email.components(separatedBy: "@").first ?? ""

    let changeRequest = me.user.createProfileChangeRequest()
    changeRequest.displayName = userName
    try await changeRequest.commitChanges()

    return me.user.serialized()
  }

  func loginUser(email: String, password: String) async throws -> AuthEntity.Me.Response {
    let me = try await Auth.auth().signIn(withEmail: email, password: password)
    return me.user.serialized()
  }

  func logOut() throws {
    try Auth.auth().signOut()
  }

  func updatePassword(currPassword: String, newPassword: String) async throws {
    guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }

    let credential = EmailAuthProvider.credential(withEmail: me.email ?? "", password: currPassword)

    try await me.reauthenticate(with: credential)
    try await me.updatePassword(to: newPassword)
  }

  func deleteUser(password: String) async throws {
    guard let me = Auth.auth().currentUser else { return }

    let credential = EmailAuthProvider.credential(withEmail: me.email ?? "", password: password)

    try await me.reauthenticate(with: credential)
    try await me.delete()
  }

  func sendPasswordReset(email: String) async throws {
    Auth.auth().languageCode = "ko"

    try await Auth.auth().sendPasswordReset(withEmail: email)
  }
}

// MARK: Google, Apple
extension AuthUseCasePlatform {
  @MainActor
  func googleSignIn() async throws -> AuthEntity.Google.Response {
    try await withCheckedThrowingContinuation { continuation in
      guard let rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController else {
        continuation.resume(throwing: CompositeErrorRepository.webSocketDisconnect)
        return
      }

      guard let clientID = FirebaseApp.app()?.options.clientID else {
        continuation.resume(throwing: CompositeErrorRepository.invalidTypeCasting)
        return
      }

      let config = GIDConfiguration(clientID: clientID)
      GIDSignIn.sharedInstance.configuration = config

      GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
        if let error {
          continuation.resume(throwing: CompositeErrorRepository.other(error))
        } else if let result {
          guard let idToken = result.user.idToken?.tokenString else {
            continuation.resume(throwing: CompositeErrorRepository.invalidTypeCasting)
            return
          }

          let accessToken = result.user.accessToken.tokenString
          let tokens = AuthEntity.Google.Response(idToken: idToken, accessToken: accessToken)

          continuation.resume(returning: tokens)
        } else {
          continuation.resume(throwing: CompositeErrorRepository.invalidTypeCasting)
        }
      }
    }
  }

  @discardableResult
  func signInWithGoogle(tokens: AuthEntity.Google.Response) async throws -> AuthEntity.Me.Response {
    let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
    return try await signInCredential(credential: credential)
  }

  @discardableResult
  func signInWithApple(tokens: AuthEntity.Apple.Response) async throws -> AuthEntity.Me.Response {
    let credential = OAuthProvider.appleCredential(
      withIDToken: tokens.token,
      rawNonce: tokens.nonce,
      fullName: .init(givenName: tokens.name))
    return try await signInCredential(credential: credential)
  }

  /// SSO관련 로그인들은 credential로 로그인들 하기 때문에, credential에 관한것을 구현하고 가져다 사용
  /// 만약 구글이면 구글 로그인 관련한 곳에 가져가 쓰고, 애플이면 애플 로그인하는 곳에 가져다씀
  func signInCredential(credential: AuthCredential) async throws -> AuthEntity.Me.Response {
    let me = try await Auth.auth().signIn(with: credential)
    return me.user.serialized()
  }
}

// MARK: Kakao
extension AuthUseCasePlatform {
  private func signInWithKakao() async throws -> Bool {
    if AuthApi.hasToken() {
      try await validateKakaoToken()
    } else {
      try await openKakaoService()
    }
  }

  private func openKakaoService() async throws -> Bool {
    if UserApi.isKakaoTalkLoginAvailable() {
      try await handleLoginWithApp()
    } else {
      try await handleLoginWithWeb()
    }
  }

  private func validateKakaoToken() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.accessTokenInfo { _, error in
        if error != nil {
          Task {
            do {
              let result = try await openKakaoService()
              continuation.resume(returning: result)
            } catch {
              continuation.resume(throwing: error)
            }
          }
        } else {
          // 토큰 유효성 체크 성공 (필요 시 토큰 갱신됨)
          UserApi.shared.me { kakaoUser, error in
            if let error {
              Logger.error("기존 회원 로그인 에러 발생: \(error.localizedDescription)")
              continuation.resume(throwing: error)
            } else {
              Logger.debug("기존 회원 로그인 진행")
              guard
                let email = kakaoUser?.kakaoAccount?.email,
                let password = kakaoUser?.id
              else {
                return continuation.resume(throwing: CompositeErrorRepository.incorrectUser)
              }

              Task {
                do {
                  let response = try await signInEmail(.init(email: email, password: "\(password)"))
                  continuation.resume(returning: response)
                } catch {
                  Logger.error("Firebase 로그인 실패: \(error.localizedDescription)")
                  continuation.resume(throwing: error)
                }
              }
            }
          }
        }
      }
    }
  }

  @MainActor
  private func handleLoginWithApp() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.loginWithKakaoTalk { oauthToken, error in
        if let error {
          Logger.error("Error during login with KakaoTalk: \(error)")
          continuation.resume(throwing: error)
        } else {
          Logger.debug("loginWithKakaoTalk() success.")

          guard oauthToken != nil else { return continuation.resume(throwing: CompositeErrorRepository.networkUnauthorized) }
          Task {
            let response = try await uploadKakaoInfoToFirebase()
            continuation.resume(returning: response)
          }
        }
      }
    }
  }

  @MainActor
  private func handleLoginWithWeb() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.loginWithKakaoAccount { oauthToken, error in
        if let error {
          Logger.error("Error during login with KakaoAccount: \(error)")
          continuation.resume(throwing: error)
        } else {
          Logger.debug("loginWithKakaoAccount() success.")
          guard oauthToken != nil else { return continuation.resume(throwing: CompositeErrorRepository.networkUnauthorized) }
          Task {
            let response = try await uploadKakaoInfoToFirebase()
            continuation.resume(returning: response)
          }
        }
      }
    }
  }

  private func uploadKakaoInfoToFirebase() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.me { kakaoUser, error in
        if let error {
          Logger.error("DEBUG: 카카오톡 사용자 정보가져오기 에러 \(error.localizedDescription)")
          continuation.resume(throwing: error)
        } else {
          Logger.debug("DEBUG: 카카오톡 사용자 정보 가져오기 success.")
          guard
            let email = kakaoUser?.kakaoAccount?.email,
            let password = kakaoUser?.id
          else {
            continuation.resume(throwing: CompositeErrorRepository.incorrectUser)
            return
          }
          Task {
            do {
              let response = try await signUpEmail(.init(email: email, password: "\(password)"))
              continuation.resume(returning: response)
            } catch {
              // error가 CompositeErrorRepository.other라는 케이스인지를 확인합니다.
              // 해당 케이스라면 내부의 authError 값을 추출합니다.
              // 추출한 authError 값을 NSError로 변환한 뒤, code가 emailAlreadyInUse 오류 코드와 같은지 확인합니다.
              if
                case CompositeErrorRepository.other(let authError) = error,
                (authError as NSError).code == AuthErrorCode.emailAlreadyInUse.rawValue
              {
                // 조건을 모두 만족하면 이 블록이 실행됩니다.
                Logger.debug("DEBUG: 이미 가입된 계정입니다. 로그인 진행.")
                do {
                  let response = try await signInEmail(.init(email: email, password: "\(password)"))
                  continuation.resume(returning: response)
                } catch {
                  Logger.error("DEBUG: 로그인 실패")
                  continuation.resume(throwing: error)
                }
              } else {
                continuation.resume(throwing: error)
              }
            }
          }
        }
      }
    }
  }

  private func signOutWithKakao() {
    UserApi.shared.logout { error in
      guard let error else { return }
      Logger.error("카카오 로그아웃 에러 \(error.localizedDescription)")
    }
  }
}

extension FirebaseAuth.User {
  fileprivate func serialized() -> AuthEntity.Me.Response {
    .init(
      uid: uid,
      email: email,
      userName: displayName,
      photoURL: photoURL?.absoluteString)
  }
}

extension UIApplication {
  fileprivate var firstKeyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .filter { $0.activationState == .foregroundActive }
      .first?.windows
      .first(where: \.isKeyWindow)
  }
}
