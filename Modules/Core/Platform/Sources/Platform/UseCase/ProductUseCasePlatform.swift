import Architecture
import Domain
import Firebase
import FirebaseFirestore
import Foundation

// MARK: - ProductUseCasePlatform

public struct ProductUseCasePlatform {
  public init() { }
}

// MARK: ProductUseCase

extension ProductUseCasePlatform: ProductUseCase {

  public var downloadItemAndUploadToFirebase: () async throws -> Void {
    {
      guard let url = URL(string: "https://dummyjson.com/products") else { throw CompositeErrorRepository.networkNotFound }

      Task {
        do {
          let (data, _) = try await URLSession.shared.data(from: url)
          let result = try JSONDecoder().decode(ProductEntity.Product.Response.self, from: data)
          let itemList = result.itemList

          for item in itemList {
            try? await uploadItem(item: item)
          }

        } catch {
          throw CompositeErrorRepository.invalidTypeCasting
        }
      }
    }
  }

  public var getProduct: (String) async throws -> ProductEntity.Product.Item {
    { productId in
      do {
        let ref = Firestore.firestore().collection("products").document(productId)
        return try await ref.getDocument(as: ProductEntity.Product.Item.self)
      } catch {
        throw CompositeErrorRepository.other(error)
      }
    }
  }

  public var getItemList: () async throws -> [ProductEntity.Product.Item] {
    {
      do {
        return try await getAllItem()
      } catch {
        throw CompositeErrorRepository.invalidTypeCasting
      }
    }
  }

  public var getItemListSortedByPrice: (Bool) async throws -> [ProductEntity.Product.Item] {
    { descending in
      do {
        return try await sortedByPrice(descending: descending)
      } catch {
        throw CompositeErrorRepository.invalidTypeCasting
      }
    }
  }

  public var getItemListForCategory: (String) async throws -> [ProductEntity.Product.Item] {
    { category in
      do {
        return try await sortedByCategory(category: category)
      } catch {
        throw CompositeErrorRepository.invalidTypeCasting
      }
    }
  }

  public var getAllItemList: (Bool?, String?) async throws -> [ProductEntity.Product.Item] {
    { descending, category in
      switch (descending, category) {
      case (let descending?, let category?):
        try await sortedByPriceAndCategory(descending: descending, category: category)
      case (let descending?, .none):
        try await sortedByPrice(descending: descending)
      case (.none, let category?):
        try await sortedByCategory(category: category)
      case (.none, .none):
        try await getAllItem()
      }
    }
  }

  public var getItemListByRating: (Int, Double?, Int?) async throws -> [ProductEntity.Product.Item] {
    { limit, lastRating, lastId in

      if let lastId {
        try await Firestore.firestore().collection("products")
          .order(by: "rating", descending: true)
          .order(by: "id", descending: true)
          .limit(to: limit)
          .start(after: [lastRating ?? 999, lastId])
          .getDocuments(as: ProductEntity.Product.Item.self)
      } else {
        try await Firestore.firestore().collection("products")
          .order(by: "rating", descending: true)
          .order(by: "id", descending: true)
          .limit(to: limit)
          .getDocuments(as: ProductEntity.Product.Item.self)
      }
    }
  }

  public var getProductList: (Bool?, String?, Int, ProductEntity.Product.Item?) async throws -> [ProductEntity.Product.Item] {
    { descending, category, limit, item in

      switch (descending, category) {
      case (let descending?, let category?):
        try await sortedProductByPriceAndCategory(descending: descending, category: category, limit: limit, lastItem: item)
      case (let descending?, .none):
        try await sortedProductByPrice(descending: descending, limit: limit, lastItem: item)
      case (.none, let category?):
        try await sortedProductByCategory(category: category, limit: limit, lastItem: item)
      case (.none, .none):
        try await getAllProduct(limit: limit, lastItem: item)
      }
    }
  }

}

extension ProductUseCasePlatform {

  private func uploadItem(item: ProductEntity.Product.Item) async throws {
    let ref = Firestore.firestore().collection("products").document("\(item.id)")

    try ref.setData(from: item, merge: false)
  }

  private func getAllItem() async throws -> [ProductEntity.Product.Item] {
    try await Firestore.firestore().collection("products")
      .getDocuments(as: ProductEntity.Product.Item.self)
  }

  private func sortedByPrice(descending: Bool) async throws -> [ProductEntity.Product.Item] {
    try await Firestore.firestore().collection("products")
      .order(by: "price", descending: descending)
      .getDocuments(as: ProductEntity.Product.Item.self)
  }

  private func sortedByCategory(category: String) async throws -> [ProductEntity.Product.Item] {
    try await Firestore.firestore().collection("products")
      .whereField("category", isEqualTo: category)
      .getDocuments(as: ProductEntity.Product.Item.self)
  }

  private func sortedByPriceAndCategory(descending: Bool, category: String) async throws -> [ProductEntity.Product.Item] {
    try await Firestore.firestore().collection("products")
      .whereField("category", isEqualTo: category)
      .order(by: "price", descending: descending)
      .getDocuments(as: ProductEntity.Product.Item.self)
  }

  private func getAllProduct(limit: Int, lastItem: ProductEntity.Product.Item?) async throws -> [ProductEntity.Product.Item] {
    let query = Firestore.firestore().collection("products")
      .order(by: "id")
      .limit(to: limit)

    if let lastItem {
      return try await query
        .start(after: [lastItem.id])
        .getDocuments(as: ProductEntity.Product.Item.self)
    } else {
      return try await query.getDocuments(as: ProductEntity.Product.Item.self)
    }
  }

  private func sortedProductByPrice(
    descending: Bool,
    limit: Int,
    lastItem: ProductEntity.Product.Item?) async throws -> [ProductEntity.Product.Item]
  {
    let query = Firestore.firestore().collection("products")
      .order(by: "price", descending: descending)
      .order(by: "id", descending: true)
      .limit(to: limit)

    if let lastItem {
      return try await query
        .start(after: [lastItem.price ?? .zero, lastItem.id])
        .getDocuments(as: ProductEntity.Product.Item.self)
    } else {
      return try await query.getDocuments(as: ProductEntity.Product.Item.self)
    }
  }

  private func sortedProductByCategory(
    category: String,
    limit: Int,
    lastItem: ProductEntity.Product.Item?) async throws -> [ProductEntity.Product.Item]
  {
    let query = Firestore.firestore().collection("products")
      .whereField("category", isEqualTo: category)
      .order(by: "id", descending: true)
      .limit(to: limit)

    if let lastItem {
      return try await query
        .start(after: [lastItem.id])
        .getDocuments(as: ProductEntity.Product.Item.self)
    } else {
      return try await query.getDocuments(as: ProductEntity.Product.Item.self)
    }
  }

  private func sortedProductByPriceAndCategory(
    descending: Bool,
    category: String,
    limit: Int,
    lastItem: ProductEntity.Product.Item?) async throws -> [ProductEntity.Product.Item]
  {
    let query = Firestore.firestore().collection("products")
      .whereField("category", isEqualTo: category)
      .order(by: "price", descending: descending)
      .order(by: "id", descending: true)
      .limit(to: limit)

    if let lastItem {
      return try await query
        .start(after: [lastItem.price ?? .zero, lastItem.id])
        .getDocuments(as: ProductEntity.Product.Item.self)
    } else {
      return try await query.getDocuments(as: ProductEntity.Product.Item.self)
    }
  }
}

extension Query {
  public func getDocuments<T>(as _: T.Type) async throws -> [T] where T: Codable {
    let snapshot = try await getDocuments()

    return try snapshot.documents.map {
      try $0.data(as: T.self)
    }
  }
}
