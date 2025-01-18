import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - ProductPage

struct ProductPage {
  @Bindable var store: StoreOf<ProductReducer>
}

extension ProductPage {
  @MainActor
  private var lastRating: Double? {
    store.itemList.last?.rating
  }

  @MainActor
  private var lastId: Int {
    store.itemList.last?.id ?? .zero
  }

  @MainActor
  private func optionSelected(option: FilterOption) async throws {
    store.selectedOption = option
    store.itemList = []
    getProducts()
  }

  @MainActor
  private func categorySelected(option: CategoryOption) async throws {
    store.selectedCategory = option
    store.itemList = []
    getProducts()
  }

  @MainActor
  private func getProducts() {
    store.send(.getProductList(store.selectedOption?.descending, store.selectedCategory?.category, 5, store.itemList.last))
  }

}

// MARK: View

extension ProductPage: View {
  var body: some View {
    List {
      ForEach(store.itemList, id: \.id) { item in
        ItemComponent(
          viewState: .init(item: item),
          text: "Add to Favorite",
          tapAction: { store.send(.onTapAddFavoriteProduct(item.id)) })
          .onAppear {
            guard let last = store.itemList.last, last.id == item.id else { return }
            guard !store.fetchProductList.isLoading else { return }
            getProducts()
          }
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Menu("Filter: \(store.selectedOption?.rawValue ?? "NONE")") {
          ForEach(FilterOption.allCases, id: \.self) { option in
            Button(action: {
              Task {
                try? await optionSelected(option: option)
              }
            }) {
              Text(option.rawValue)
            }
          }
        }
      }

      ToolbarItem(placement: .topBarTrailing) {
        Menu("Category: \(store.selectedCategory?.rawValue ?? "NONE")") {
          ForEach(CategoryOption.allCases, id: \.self) { option in
            Button(action: {
              Task {
                try? await categorySelected(option: option)
              }
            }) {
              Text(option.rawValue)
            }
          }
        }
      }
    }
    .onAppear {
      getProducts()
    }
  }
}
