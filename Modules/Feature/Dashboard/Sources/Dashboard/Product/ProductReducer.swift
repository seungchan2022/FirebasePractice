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

      case .getItemListSortedByPrice(let descending):
        state.fetchItemListSortedByPrice.isLoading = true
        return sideEffect
          .getItemListSortedByPrice(descending)
          .cancellable(pageID: state.id, id: CancelID.requestItemListSortedByPrice, cancelInFlight: true)

      case .fetchItemListSortedByPrice(let result):
        state.fetchItemListSortedByPrice.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchItemListSortedByPrice.value = itemList
          state.itemList = itemList
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getItemListForCategory(let category):
        state.fetchItemListForCategory.isLoading = true
        return sideEffect
          .getItemListForCategory(category)
          .cancellable(pageID: state.id, id: CancelID.requestItemListForCategory, cancelInFlight: true)

      case .fetchItemListForCategory(let result):
        state.fetchItemListForCategory.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchItemListForCategory.value = itemList
          state.itemList = itemList
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getAllItemList(let descending, let category):
        state.fetchAllItemList.isLoading = true
        return sideEffect
          .getAllItemList(descending, category)
          .cancellable(pageID: state.id, id: CancelID.requestAllItemList, cancelInFlight: true)

      case .fetchAllItemList(let result):
        state.fetchAllItemList.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchAllItemList.value = itemList
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

    // MARK: Lifecycle

    init(id: UUID = UUID()) {
      self.id = id
    }

    // MARK: Internal

    let id: UUID

    var itemList: [ProductEntity.Product.Item] = []

    var selectedOption: FilterOption? = .none
    var selectedCategory: CategoryOption? = .none

    var fetchDownlooadItem: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchItemList: FetchState.Data<[ProductEntity.Product.Item]?> = .init(isLoading: false, value: .none)

    var fetchItemListSortedByPrice: FetchState.Data<[ProductEntity.Product.Item]?> = .init(isLoading: false, value: .none)

    var fetchItemListForCategory: FetchState.Data<[ProductEntity.Product.Item]?> = .init(isLoading: false, value: .none)

    var fetchAllItemList: FetchState.Data<[ProductEntity.Product.Item]?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case downloadItem
    case fetchDownlooadItem(Result<Bool, CompositeErrorRepository>)

    case getItemList
    case fetchItemList(Result<[ProductEntity.Product.Item], CompositeErrorRepository>)

    case getItemListSortedByPrice(Bool)
    case fetchItemListSortedByPrice(Result<[ProductEntity.Product.Item], CompositeErrorRepository>)

    case getItemListForCategory(String)
    case fetchItemListForCategory(Result<[ProductEntity.Product.Item], CompositeErrorRepository>)

    case getAllItemList(Bool?, String?)
    case fetchAllItemList(Result<[ProductEntity.Product.Item], CompositeErrorRepository>)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: ProductReducer.CancelID

extension ProductReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestDownloadItem
    case requestItemList
    case requestItemListSortedByPrice
    case requestItemListForCategory
    case requestAllItemList
  }
}

// MARK: - FilterOption

enum FilterOption: String, CaseIterable {
  case normal
  case priceHigh
  case priceLow

  var descending: Bool? {
    switch self {
    case .normal:
      .none
    case .priceHigh:
      true
    case .priceLow:
      false
    }
  }
}

// MARK: - CategoryOption

enum CategoryOption: String, CaseIterable {
  case normal
  case beauty
  case fragrances
  case furniture
  case groceries

  var category: String? {
    switch self {
    case .normal:
      .none
    case .beauty, .fragrances, .furniture, .groceries:
      rawValue
    }
  }
}
