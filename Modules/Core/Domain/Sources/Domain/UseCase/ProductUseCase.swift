import Foundation

public protocol ProductUseCase: Sendable {
  var downloadItemAndUploadToFirebase: () async throws -> Void { get }
}
