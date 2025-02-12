import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - TodoListReducer

@Reducer
struct TodoListReducer {
  let sideEffect: TodoListSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapAddCategoryItem(let item):
        state.fetchAddCategoryItem.isLoading = true
        return sideEffect
          .addCategoryItem(item)
          .cancellable(pageID: state.id, id: CancelID.requestAddCategoryItem, cancelInFlight: true)

      case .fetchAddCategoryItem(let result):
        state.fetchAddCategoryItem.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "성공")
            return .run { await $0(.getCategoryItemList) }

          case false: sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getCategoryItemList:
        state.fetchCategoryItemList.isLoading = true
        return sideEffect
          .getCategoryItemList()
          .cancellable(pageID: state.id, id: CancelID.requestCategoryItemList, cancelInFlight: true)

      case .fetchCategoryItemList(let result):
        state.fetchCategoryItemList.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchCategoryItemList.value = itemList
          state.categoryItemList = itemList
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapDeleteCategoryItem(let item):
        state.fetchDeleteCategoryItem.isLoading = true

        return sideEffect
          .deleteCategoryItem(item)
          .cancellable(pageID: state.id, id: CancelID.requestDeleteCategoryItem, cancelInFlight: true)

      case .fetchDeleteCategoryItem(let result):
        state.fetchDeleteCategoryItem.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "성공")
            return .run { await $0(.getCategoryItemList) }

          case false: sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "실패")
          }

          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapCategoryItem(let item):
        sideEffect.routeToDetail(item)
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }
}

extension TodoListReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    init(id: UUID = UUID()) {
      self.id = id
    }

    var categoryText = ""
    var isShowAlert = false

    var categoryItemList: [TodoListEntity.Category.Item] = []

    var fetchAddCategoryItem: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchCategoryItemList: FetchState.Data<[TodoListEntity.Category.Item]?> = .init(isLoading: false, value: .none)

    var fetchDeleteCategoryItem: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapAddCategoryItem(TodoListEntity.Category.Item)
    case fetchAddCategoryItem(Result<Bool, CompositeErrorRepository>)

    case getCategoryItemList
    case fetchCategoryItemList(Result<[TodoListEntity.Category.Item], CompositeErrorRepository>)

    case onTapDeleteCategoryItem(TodoListEntity.Category.Item)
    case fetchDeleteCategoryItem(Result<Bool, CompositeErrorRepository>)

    case onTapCategoryItem(TodoListEntity.Category.Item)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: TodoListReducer.CancelID

extension TodoListReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestAddCategory
    case requestAddCategoryItem
    case requestCategoryItemList
    case requestDeleteCategoryItem
  }
}
