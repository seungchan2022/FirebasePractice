import Foundation

public protocol AuthUseCase: Sendable {
  var signUpEmail: (AuthEntity.Email.Request) async throws -> Bool { get }
  var signInEmail: (AuthEntity.Email.Request) async throws -> Bool { get }

  var me: () throws -> AuthEntity.Me.Response { get }

  var signOut: () throws -> Bool { get }
}
