import ComposableArchitecture
import DesignSystem
import SwiftUI

// MARK: - ProductPage

struct ProductPage {
  @Bindable var store: StoreOf<ProductReducer>
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
              .fill(Color.white)
          )
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.black, lineWidth: 0.2)
          )
          .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)

          VStack(alignment: .leading, spacing: 4) {
            Text(item.title ?? "")
              .font(.headline)
              .foregroundStyle(.black)

            Text(item.description ?? "")
              .lineLimit(1)
            Text(item.category ?? "")

            Text("\(item.price ?? .zero)")
            Text("\(item.rating ?? .zero)")
            Text(item.tagList?.joined(separator: ", ") ?? "")
          }
          .font(.callout)
          .foregroundStyle(.secondary)
        }
      }
    }
    .onAppear {
      store.send(.getItemList)
    }
  }
}
