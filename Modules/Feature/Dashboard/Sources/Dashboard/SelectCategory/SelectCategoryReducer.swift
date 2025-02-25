import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SelectCategoryReducer

@Reducer
struct SelectCategoryReducer {
  let sideEffect: SelectCategorySideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

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

      case .onTapAddCategoryItemList:
        state.fetchAddCategoryItemList.isLoading = true
        return sideEffect
          .addCategoryItemList(state.groupItem.id, state.selectedItemList.map { $0.id })
          .cancellable(pageID: state.id, id: CancelID.requestAddCategoryItemList, cancelInFlight: true)

      case .fetchAddCategoryItemList(let result):
        state.fetchAddCategoryItemList.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "성공")
            sideEffect.routeToClose()

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "실페")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToClose:
        sideEffect.routeToClose()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }
}

extension SelectCategoryReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {

    // MARK: Lifecycle

    init(
      id: UUID = UUID(),
      groupItem: GroupListEntity.Group.Item)
    {
      self.id = id
      self.groupItem = groupItem
    }

    // MARK: Internal

    let id: UUID

    let groupItem: GroupListEntity.Group.Item

    var selectedItemList: [TodoListEntity.Category.Item] = []
    var lastItem: TodoListEntity.Category.Item? = .none

    var categoryItemList: [TodoListEntity.Category.Item] = []

    var fetchCategoryItemList: FetchState.Data<[TodoListEntity.Category.Item]?> = .init(isLoading: false, value: .none)

    var fetchAddCategoryItemList: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getCategoryItemList
    case fetchCategoryItemList(Result<[TodoListEntity.Category.Item], CompositeErrorRepository>)

    case onTapAddCategoryItemList
    case fetchAddCategoryItemList(Result<Bool, CompositeErrorRepository>)

    case routeToClose

    case throwError(CompositeErrorRepository)
  }
}

// MARK: SelectCategoryReducer.CancelID

extension SelectCategoryReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestCategoryItemList
    case requestAddCategoryItemList
  }
}
