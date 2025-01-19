import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator
import Platform

// MARK: - FavoriteSideEffect

struct FavoriteSideEffect {
  let useCaseGroup: DashboardSidEffect
  let main: AnySchedulerOf<DispatchQueue>
  let navigator: RootNavigatorType

  init(useCaseGroup: DashboardSidEffect, main: AnySchedulerOf<DispatchQueue> = .main, navigator: RootNavigatorType) {
    self.useCaseGroup = useCaseGroup
    self.main = main
    self.navigator = navigator
  }

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

  var getListenerForAllUserFavoriteProducts: () -> Effect<FavoriteReducer.Action> {
    {
      .publisher {
        useCaseGroup.userUseCase
          .addListenerForAllUserFavoriteProducts()
          .receive(on: main)
          .mapToResult()
          .map(FavoriteReducer.Action.fetchListenerForAllUserFavoriteProducts)
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
