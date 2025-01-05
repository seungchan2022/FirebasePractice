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

  public var getItemList: () async throws -> [ProductEntity.Product.Item] {
    {
      do {
        return try await getAllItemList()
      } catch {
        throw CompositeErrorRepository.invalidTypeCasting
      }
    }
  }

}

extension ProductUseCasePlatform {

  private func uploadItem(item: ProductEntity.Product.Item) async throws {
    let ref = Firestore.firestore().collection("products").document("\(item.id)")

    try ref.setData(from: item, merge: false)
  }

  private func getAllItemList() async throws -> [ProductEntity.Product.Item] {
    try await Firestore.firestore().collection("products").getDocuments(as: ProductEntity.Product.Item.self)
  }
}

extension Query {
  fileprivate func getDocuments<T>(as _: T.Type) async throws -> [T] where T: Codable {
    let snapshot = try await getDocuments()

    return try snapshot.documents.map {
      try $0.data(as: T.self)
    }
  }
}
