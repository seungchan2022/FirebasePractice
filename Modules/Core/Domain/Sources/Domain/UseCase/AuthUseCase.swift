import Foundation

public protocol AuthUseCase: Sendable {
  var signUpEmail: (AuthEntity.Email.Request) async throws -> Bool { get }
  var signInEmail: (AuthEntity.Email.Request) async throws -> Bool { get }

  var signInGoogle: () async throws -> Bool { get }

  var signInApple: () async throws -> Bool { get }

  var me: () throws -> AuthEntity.Me.Response { get }

  var signOut: () throws -> Bool { get }

  var updatePassword: (String, String) async throws -> Bool { get }

  var deleteUser: (String) async throws -> Bool { get }

  var resetPassword: (String) async throws -> Bool { get }

  var getProvider: () throws -> [AuthEntity.ProviderOption.Option] { get }

}
