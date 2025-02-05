import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - TodoDetailReducer

@Reducer
struct TodoDetailReducer {
  let sideEffect: TodoDetailSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .getCategoryItem(let item):
        state.fetchCategoryItem.isLoading = true
        return sideEffect
          .getCategoryItem(item)
          .cancellable(pageID: state.id, id: CancelID.requestCategoryItem, cancelInFlight: true)

      case .fetchCategoryItem(let result):
        state.fetchCategoryItem.isLoading = false
        switch result {
        case .success(let item):
          state.fetchCategoryItem.value = item
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

extension TodoDetailReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    let categoryItem: TodoListEntity.Category.Item

    init(
      id: UUID = UUID(),
      categoryItem: TodoListEntity.Category.Item)
    {
      self.id = id
      self.categoryItem = categoryItem
    }

    var fetchCategoryItem: FetchState.Data<TodoListEntity.Category.Item?> = .init(isLoading: false, value: .none)

  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getCategoryItem(TodoListEntity.Category.Item)
    case fetchCategoryItem(Result<TodoListEntity.Category.Item, CompositeErrorRepository>)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: TodoDetailReducer.CancelID

extension TodoDetailReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestCategoryItem
  }
}
