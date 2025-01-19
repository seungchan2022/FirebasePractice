import ComposableArchitecture
import Domain
import SwiftUI

// MARK: - FavoritePage

struct FavoritePage {
  @Bindable var store: StoreOf<FavoriteReducer>
}

extension FavoritePage { }

// MARK: View

extension FavoritePage: View {
  var body: some View {
    List {
      ForEach(store.favoriteProductList, id: \.id) { item in
        ProductComponent(
          viewState: .init(productId: String(item.productId)),
          text: "Remove to Favorite",
          tapAction: {
            store.send(.onTapRemoveFavoriteProduct(item.id))
          },
          store: store)
      }
    }
    .onAppear {
//      store.send(.getFavoriteProductList)
      store.send(.getListenerForAllUserFavoriteProducts)
    }
  }
}
