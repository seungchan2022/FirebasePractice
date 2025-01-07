import Architecture
import ComposableArchitecture
import Foundation
import LinkNavigator

// MARK: - ProductSideEffect

struct ProductSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension ProductSideEffect {
  var downloadItem: () -> Effect<ProductReducer.Action> {
    {
      .run { send in
        do {
          try await useCaseGroup.productUseCase.downloadItemAndUploadToFirebase()
          await send(ProductReducer.Action.fetchDownlooadItem(.success(true)))
        } catch {
          await send(ProductReducer.Action.fetchDownlooadItem(.failure(.other(error))))
        }
      }
    }
  }

  var getItemList: () -> Effect<ProductReducer.Action> {
    {
      .run { send in
        do {
          let itemList = try await useCaseGroup.productUseCase.getItemList()
          await send(ProductReducer.Action.fetchItemList(.success(itemList)))
        } catch {
          await send(ProductReducer.Action.fetchItemList(.failure(.other(error))))
        }
      }
    }
  }

  var getItemListSortedByPrice: (Bool) -> Effect<ProductReducer.Action> {
    { descending in
      .run { send in
        do {
          let itemList = try await useCaseGroup.productUseCase.getItemListSortedByPrice(descending)
          await send(ProductReducer.Action.fetchItemListSortedByPrice(.success(itemList)))
        } catch {
          await send(ProductReducer.Action.fetchItemListSortedByPrice(.failure(.other(error))))
        }
      }
    }
  }

  var getItemListForCategory: (String) -> Effect<ProductReducer.Action> {
    { category in
      .run { send in
        do {
          let itemList = try await useCaseGroup.productUseCase.getItemListForCategory(category)
          await send(ProductReducer.Action.fetchItemListForCategory(.success(itemList)))
        } catch {
          await send(ProductReducer.Action.fetchItemListForCategory(.failure(.other(error))))
        }
      }
    }
  }

  var getAllItemList: (Bool?, String?) -> Effect<ProductReducer.Action> {
    { descending, category in
      .run { send in
        do {
          let itemList = try await useCaseGroup.productUseCase.getAllItemList(descending, category)
          await send(ProductReducer.Action.fetchAllItemList(.success(itemList)))
        } catch {
          await send(ProductReducer.Action.fetchAllItemList(.failure(.other(error))))
        }
      }
    }
  }

}
