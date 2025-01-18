import Foundation

public protocol ProductUseCase: Sendable {
  var downloadItemAndUploadToFirebase: () async throws -> Void { get }

  var getProduct: (String) async throws -> ProductEntity.Product.Item { get }

  /// 전체 아이템 리스트
  var getItemList: () async throws -> [ProductEntity.Product.Item] { get }

  /// 가격 정렬한 아이템 리스트
  var getItemListSortedByPrice: (Bool) async throws -> [ProductEntity.Product.Item] { get }

  /// 카테고리 필터링된 아이템 리스트
  var getItemListForCategory: (String) async throws -> [ProductEntity.Product.Item] { get }

  /// 가격 정렬 + 카테고리 필터링된 아이템 리스트
  var getAllItemList: (Bool?, String?) async throws -> [ProductEntity.Product.Item] { get }

  /// 평점 정렬 아이템 리스트 + 페이지 네이션
  var getItemListByRating: (Int, Double?, Int?) async throws -> [ProductEntity.Product.Item] { get }

  /// 가격 정렬 + 카테고리 필터링된 아이템 리스트 + 페이지 네이션
  var getProductList: (Bool?, String?, Int, ProductEntity.Product.Item?) async throws -> [ProductEntity.Product.Item] { get }
}
