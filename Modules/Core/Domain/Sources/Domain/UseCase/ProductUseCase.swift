import Foundation

public protocol ProductUseCase: Sendable {
  var downloadItemAndUploadToFirebase: () async throws -> Void { get }

  var getItemList: () async throws -> [ProductEntity.Product.Item] { get }

  var getItemListSortedByPrice: (Bool) async throws -> [ProductEntity.Product.Item] { get }

  var getItemListForCategory: (String) async throws -> [ProductEntity.Product.Item] { get }

  var getAllItemList: (Bool?, String?) async throws -> [ProductEntity.Product.Item] { get }
}
