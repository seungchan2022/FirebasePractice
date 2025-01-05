import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - ProductReducer

@Reducer
struct ProductReducer {
  let sideEffect: ProductSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .downloadItem:
        state.fetchDownlooadItem.isLoading = true
        return sideEffect
          .downloadItem()
          .cancellable(pageID: state.id, id: CancelID.requestDownloadItem, cancelInFlight: true)

      case .fetchDownlooadItem(let result):
        state.fetchDownlooadItem.isLoading = false
        switch result {
        case .success:
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getItemList:
        state.fetchItemList.isLoading = true
        return sideEffect
          .getItemList()
          .cancellable(pageID: state.id, id: CancelID.requestItemList, cancelInFlight: true)

      case .fetchItemList(let result):
        state.fetchItemList.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchItemList.value = itemList
          state.itemList = itemList
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

extension ProductReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    var itemList: [ProductEntity.Product.Item] = []

    init(id: UUID = UUID()) {
      self.id = id
    }

    var fetchDownlooadItem: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchItemList: FetchState.Data<[ProductEntity.Product.Item]?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case downloadItem
    case fetchDownlooadItem(Result<Bool, CompositeErrorRepository>)

    case getItemList
    case fetchItemList(Result<[ProductEntity.Product.Item], CompositeErrorRepository>)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: ProductReducer.CancelID

extension ProductReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestDownloadItem
    case requestItemList
  }
}
