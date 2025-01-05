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
}
