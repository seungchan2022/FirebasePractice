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
}
