import Domain
import Foundation
import SwiftUI

// MARK: - FavoritePage.ItemComponent

extension FavoritePage {
  struct ItemComponent {
    let viewState: ViewState

  }
}

extension FavoritePage.ItemComponent { }

// MARK: - FavoritePage.ItemComponent + View

extension FavoritePage.ItemComponent: View {
  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      AsyncImage(url: URL(string: viewState.item.thumbnail ?? "")) { image in
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

      Text("\(viewState.item.id)")

      VStack(alignment: .leading, spacing: 4) {
        Text(viewState.item.title ?? "")
          .font(.headline)
          .foregroundStyle(.black)

        Text(viewState.item.description ?? "")
          .lineLimit(1)

        Text("Category: \(viewState.item.category ?? "")")

        Text("Price: $\((viewState.item.price ?? .zero).formatted(.number.precision(.fractionLength(2))))")
        Text("Rating: \((viewState.item.rating ?? .zero).formatted(.number.precision(.fractionLength(2))))")

        Text("TagList: \(viewState.item.tagList?.joined(separator: ", ") ?? "")")
      }
      .font(.callout)
      .foregroundStyle(.secondary)
    }
  }
}

// MARK: - FavoritePage.ItemComponent.ViewState

extension FavoritePage.ItemComponent {
  struct ViewState: Equatable {
    let item: ProductEntity.Product.Item
  }
}
