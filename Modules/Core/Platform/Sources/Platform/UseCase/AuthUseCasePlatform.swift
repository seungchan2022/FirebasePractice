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
        throw error
      }
    }
  }

  public var signInEmail: (AuthEntity.Email.Request) async throws -> Bool {
    { req in
      do {
        let _ = try await loginUser(email: req.email, password: req.password)
        return true
      } catch {
        throw error
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
        throw error
      }
    }
  }
}

extension AuthUseCasePlatform {
  func createUser(email: String, password: String) async throws -> AuthEntity.Me.Response {
    let me = try await Auth.auth().createUser(withEmail: email, password: password)
    return me.user.serialized()
  }

  func loginUser(email: String, password: String) async throws -> AuthEntity.Me.Response {
    let me = try await Auth.auth().signIn(withEmail: email, password: password)
    return me.user.serialized()
  }

  func logOut() throws {
    try Auth.auth().signOut()
  }
}

extension FirebaseAuth.User {
  fileprivate func serialized() -> AuthEntity.Me.Response {
    .init(
      uid: uid,
      email: email,
      photoURL: photoURL?.absoluteString)
  }
}
