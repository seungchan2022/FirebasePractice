import Foundation

public protocol ProductUseCase: Sendable {
  var downloadItemAndUploadToFirebase: () async throws -> Void { get }

  var getItemList: () async throws -> [ProductEntity.Product.Item] { get }
}
