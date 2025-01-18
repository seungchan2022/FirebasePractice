import ComposableArchitecture
import Domain
import Foundation
import SwiftUI

// MARK: - FavoritePage.ProductComponent

extension FavoritePage {
  struct ProductComponent {
    var viewState: ViewState
    let text: String
    let tapAction: () -> Void

    @Bindable var store: StoreOf<FavoriteReducer>
  }
}

extension FavoritePage.ProductComponent { }

// MARK: - FavoritePage.ProductComponent + View

extension FavoritePage.ProductComponent: View {
  var body: some View {
    ZStack {
      if let product = store.fetchProduct.value {
        FavoritePage.ItemComponent(viewState: .init(item: product))
          .contextMenu {
            Button(action: { tapAction() }) {
              Text(text)
            }
          }
      } else {
        ProgressView()
      }
    }
    .onAppear {
      store.send(.getProduct(viewState.productId))
    }
  }
}

// MARK: - FavoritePage.ProductComponent.ViewState

extension FavoritePage.ProductComponent {
  struct ViewState: Equatable {
    let productId: String
  }
}
