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
        HStack(alignment: .top, spacing: 8) {
          AsyncImage(url: URL(string: item.thumbnail ?? "")) { image in
            image
              .resizable()
              .scaledToFill()
              .frame(width: 75, height: 75)
              .clipShape(RoundedRectangle(cornerRadius: 10))
          } placeholder: {
            ProgressView()
          }
          .frame(width: 75, height: 75)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.white))
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.black, lineWidth: 0.2))
          .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)

          Text("\(item.id)")

          VStack(alignment: .leading, spacing: 4) {
            Text(item.title ?? "")
              .font(.headline)
              .foregroundStyle(.black)

            Text(item.description ?? "")
              .lineLimit(1)

            Text("Category: \(item.category ?? "")")

            Text("Price: $\((item.price ?? .zero).formatted(.number.precision(.fractionLength(2))))")
            Text("Rating: \((item.rating ?? .zero).formatted(.number.precision(.fractionLength(2))))")

            Text("TagList: \(item.tagList?.joined(separator: ", ") ?? "")")
          }
          .font(.callout)
          .foregroundStyle(.secondary)
        }
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
