import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - FavoriteSideEffect

struct FavoriteSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension FavoriteSideEffect {
  var getProduct: (String) -> Effect< FavoriteReducer.Action> {
    { productId in
      .run { send in
        do {
          let response = try await useCaseGroup.productUseCase.getProduct(productId)
          await send(FavoriteReducer.Action.fetchProduct(.success(response)))
        } catch {
          await send(FavoriteReducer.Action.fetchProduct(.failure(.other(error))))
        }
      }
    }
  }

  var getFavoriteProductList: () -> Effect<FavoriteReducer.Action> {
    {
      .run { send in
        do {
          let itemList = try await useCaseGroup.userUseCase.getFavoriteProduct()
          await send(FavoriteReducer.Action.fetchFavoriteProductList(.success(itemList)))
        } catch {
          await send(FavoriteReducer.Action.fetchFavoriteProductList(.failure(.other(error))))
        }
      }
    }
  }

  var removeFavoriteProduct: (String) -> Effect<FavoriteReducer.Action> {
    { favoriteProductId in
      .run { send in
        do {
          let response = try await useCaseGroup.userUseCase.removeFavoriteProduct(favoriteProductId)
          await send(FavoriteReducer.Action.fetchRemoveFavoriteProduct(.success(response)))
        } catch {
          await send(FavoriteReducer.Action.fetchRemoveFavoriteProduct(.failure(.other(error))))
        }
      }
    }
  }

}
