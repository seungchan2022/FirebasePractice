import Domain
import Firebase
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
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

  public var me: () throws -> AuthEntity.Me.Response {
    {
      guard let user = Auth.auth().currentUser else { throw CompositeErrorRepository.incorrectUser }
      return user.serialized()
    }
  }

  public var signOut: () throws -> Bool {
    {
      do {
        let _ = try logOut()
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
}

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

  /// SSO관련 로그인들은 credential로 로그인들 하기 때문에, credential에 관한것을 구현하고 가져다 사용
  /// 만약 구글이면 구글 로그인 관련한 곳에 가져가 쓰고, 애플이면 애플 로그인하는 곳에 가져다씀
  func signInCredential(credential: AuthCredential) async throws -> AuthEntity.Me.Response {
    let me = try await Auth.auth().signIn(with: credential)
    return me.user.serialized()
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
