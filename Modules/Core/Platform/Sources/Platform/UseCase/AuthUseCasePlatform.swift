import Architecture
import AuthenticationServices
import Domain
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
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
        let authDataResult = try await createUser(email: req.email, password: req.password)
        try await createNewUser(user: authDataResult)

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
        let authDataResult = try await signInWithGoogle(tokens: tokens)
        try await createNewSSOUser(user: authDataResult)
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
        let authDataResult = try await signInWithApple(tokens: tokens)
        try await createNewSSOUser(user: authDataResult)
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

        GIDSignIn.sharedInstance.signOut()
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

  public var deleteKakaoUser: () async throws -> Bool {
    {
      do {
        return try await deleteKakao()
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var deleteGoogleUser: () async throws -> Bool {
    {
      do {
        guard let googleUser = GIDSignIn.sharedInstance.currentUser else {
          throw CompositeErrorRepository.incorrectUser
        }

        // 토큰이 만료 되었을 경우에만 갱신
        try await googleUser.refreshTokensIfNeeded()

        let idToken = googleUser.idToken?.tokenString
        let accessToken = googleUser.accessToken.tokenString

        guard let idToken else {
          throw CompositeErrorRepository.invalidTypeCasting
        }

        // Firebase 유저 삭제
        let tokens = AuthEntity.Google.Response(idToken: idToken, accessToken: accessToken)
        try await deleteGoogle(tokens: tokens)
        try await GIDSignIn.sharedInstance.disconnect() // 연결 끊기

        return true
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var deleteAppleUser: () async throws -> Bool {
    {
      guard let me = Auth.auth().currentUser else {
        throw CompositeErrorRepository.incorrectUser
      }

      guard let lastSignInDate = me.metadata.lastSignInDate else {
        return false
      }

      let needsReauth = !lastSignInDate.isWithinPast(minutes: 5)
      let needsTokenRevocation = me.providerData.contains(where: { $0.providerID == "apple.com" })

      do {
        if needsReauth || needsTokenRevocation {
          // Apple 재인증 과정
          let appleAuthHelper = await AppleAuthHelper()
          let response = try await appleAuthHelper.startSignInWithAppleFlow()

          let credential = OAuthProvider.appleCredential(
            withIDToken: response.token,
            rawNonce: response.nonce,
            fullName: .none)

          if needsReauth {
            // Firebase에서 사용자 재인증
            try await me.reauthenticate(with: credential)
          }

          if needsTokenRevocation {
            guard let authorizationCode = response.authorizationCode else {
              throw CompositeErrorRepository.invalidTypeCasting
            }
            guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
              throw CompositeErrorRepository.invalidTypeCasting
            }
            try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
          }
        }

        try await me.delete()
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
  /// DB에 저장
  func createNewUser(user: AuthEntity.Me.Response) async throws {
    try Firestore.firestore().collection("users").document(user.uid).setData(from: user, merge: false)
  }

  /// 기본 Auth 로직 수행
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

  // MARK: Internal

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

  func createNewSSOUser(user: AuthEntity.Me.Response) async throws {
    let userRef = Firestore.firestore().collection("users").document(user.uid)
    let documentSnapshot = try await userRef.getDocument()

    if !documentSnapshot.exists {
      try userRef.setData(from: user, merge: false)
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

  // MARK: Private

  private func deleteGoogle(tokens: AuthEntity.Google.Response) async throws {
    guard let me = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }

    let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)

    try await me.reauthenticate(with: credential)
    try await me.delete()
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

  private func deleteKakao() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      UserApi.shared.me { kakaoUser, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        guard
          let email = kakaoUser?.kakaoAccount?.email,
          let password = kakaoUser?.id
        else {
          continuation.resume(throwing: CompositeErrorRepository.incorrectUser)
          return
        }

        guard let me = Auth.auth().currentUser else {
          continuation.resume(throwing: CompositeErrorRepository.incorrectUser)
          return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: "\(password)")

        Task {
          do {
            try await unlink()
            try await me.reauthenticate(with: credential)
            try await me.delete()

            continuation.resume(returning: true)
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }

  private func unlink() async throws {
    UserApi.shared.unlink { error in
      guard let error else { return Logger.debug("unlink() success.") }

      return Logger.error("\(error)")
    }
  }
}

extension FirebaseAuth.User {
  fileprivate func serialized() -> AuthEntity.Me.Response {
    .init(
      uid: uid,
      email: email,
      userName: displayName,
      photoURL: photoURL?.absoluteString,
      created: Date())
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

extension Date {
  fileprivate func isWithinPast(minutes: Int) -> Bool {
    let now = Date.now
    let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
    let range = timeAgo...now
    return range.contains(self)
  }
}
