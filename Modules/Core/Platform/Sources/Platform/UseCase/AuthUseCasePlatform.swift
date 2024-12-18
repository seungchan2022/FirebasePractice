import Domain
import Firebase
import FirebaseAuth
import Foundation

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

extension FirebaseAuth.User {
  fileprivate func serialized() -> AuthEntity.Me.Response {
    .init(
      uid: uid,
      email: email,
      userName: displayName,
      photoURL: photoURL?.absoluteString)
  }
}
