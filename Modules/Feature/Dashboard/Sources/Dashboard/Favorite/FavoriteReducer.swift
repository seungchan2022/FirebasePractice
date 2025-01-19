import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - FavoriteReducer

@Reducer
struct FavoriteReducer {
  let sideEffect: FavoriteSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .getProduct(let productId):
        state.fetchProduct.isLoading = true
        return sideEffect
          .getProduct(productId)
          .cancellable(pageID: state.id, id: CancelID.requestProduct, cancelInFlight: true)

      case .fetchProduct(let result):
        state.fetchProduct.isLoading = false
        switch result {
        case .success(let item):
          state.fetchProduct.value = item
          state.product = item
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getFavoriteProductList:
        state.fetchFavoriteProductList.isLoading = true
        return sideEffect
          .getFavoriteProductList()
          .cancellable(pageID: state.id, id: CancelID.requestFavoriteProductList, cancelInFlight: true)

      case .fetchFavoriteProductList(let result):
        state.fetchFavoriteProductList.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchFavoriteProductList.value = itemList
          state.favoriteProductList = itemList
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapRemoveFavoriteProduct(let favoriteProductId):
        state.fetchRemoveFavoriteProduct.isLoading = true
        return sideEffect
          .removeFavoriteProduct(favoriteProductId)
          .cancellable(pageID: state.id, id: CancelID.requestRemoveFavoriteProduct, cancelInFlight: true)

      case .fetchRemoveFavoriteProduct(let result):
        state.fetchRemoveFavoriteProduct.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "성공")
            return .run { await $0(.getFavoriteProductList) }

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getListenerForAllUserFavoriteProducts: state.fetchListenerForAllUserFavoriteProducts.isLoading = true

        return sideEffect
          .getListenerForAllUserFavoriteProducts()
          .cancellable(pageID: state.id, id: CancelID.requestListenerForAllUserFavoriteProducts, cancelInFlight: true)

      case .fetchListenerForAllUserFavoriteProducts(let result):
        state.fetchListenerForAllUserFavoriteProducts.isLoading = true
        switch result {
        case .success(let itemList):
          state.fetchListenerForAllUserFavoriteProducts.value = itemList
          state.favoriteProductList = itemList
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

}

extension FavoriteReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    var product: ProductEntity.Product.Item? = .none
    var favoriteProductList: [UserEntity.Favorite.Item] = []

    init(id: UUID = .init()) {
      self.id = id
    }

    var fetchFavoriteProductList: FetchState.Data<[UserEntity.Favorite.Item]?> = .init(isLoading: false, value: .none)

    var fetchProduct: FetchState.Data<ProductEntity.Product.Item?> = .init(isLoading: false, value: .none)

    var fetchRemoveFavoriteProduct: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchListenerForAllUserFavoriteProducts: FetchState.Data<[UserEntity.Favorite.Item]?> = .init(
      isLoading: false,
      value: .none)

  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getProduct(String)
    case fetchProduct(Result<ProductEntity.Product.Item, CompositeErrorRepository>)

    case getFavoriteProductList
    case fetchFavoriteProductList(Result<[UserEntity.Favorite.Item], CompositeErrorRepository>)

    case onTapRemoveFavoriteProduct(String)
    case fetchRemoveFavoriteProduct(Result<Bool, CompositeErrorRepository>)

    case getListenerForAllUserFavoriteProducts
    case fetchListenerForAllUserFavoriteProducts(Result<[UserEntity.Favorite.Item], CompositeErrorRepository>)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: FavoriteReducer.CancelID

extension FavoriteReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestProduct
    case requestFavoriteProductList
    case requestRemoveFavoriteProduct
    case requestListenerForAllUserFavoriteProducts
  }
}
