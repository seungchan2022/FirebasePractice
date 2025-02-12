import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - TodoReducer

@Reducer
struct TodoReducer {
  let sideEffect: TodoSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .getTodoItem(let item):
        state.fetchTodoItem.isLoading = true
        return sideEffect
          .getTodoItem(item)
          .cancellable(pageID: state.id, id: CancelID.requestTodoItem, cancelInFlight: true)

      case .fetchTodoItem(let result):
        state.fetchTodoItem.isLoading = false
        switch result {
        case .success(let item):
          state.fetchTodoItem.value = item
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapUpdateMemo(let item):
        state.fetchUpdateMemo.isLoading = true
        return sideEffect
          .updateMemo(item, state.memoText)
          .cancellable(pageID: state.id, id: CancelID.requestUpdateMemo, cancelInFlight: true)

      case .fetchUpdateMemo(let result):
        state.fetchUpdateMemo.isLoading = false
        switch result {
        case .success(let item):
          state.fetchUpdateMemo.value = item
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapClose:
        sideEffect.routeToClose()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }
}

extension TodoReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID
    let todoItem: TodoListEntity.TodoItem.Item

    init(
      id: UUID = UUID(),
      todoItem: TodoListEntity.TodoItem.Item)
    {
      self.id = id
      self.todoItem = todoItem
    }

    var memoText = ""
    var isShowAlert = false

    var fetchTodoItem: FetchState.Data<TodoListEntity.TodoItem.Item?> = .init(isLoading: false, value: .none)

    var fetchUpdateMemo: FetchState.Data<TodoListEntity.TodoItem.Item?> = .init(isLoading: false, value: .none)

  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getTodoItem(TodoListEntity.TodoItem.Item)
    case fetchTodoItem(Result<TodoListEntity.TodoItem.Item, CompositeErrorRepository>)

    case onTapUpdateMemo(TodoListEntity.TodoItem.Item)
    case fetchUpdateMemo(Result<TodoListEntity.TodoItem.Item, CompositeErrorRepository>)

    case onTapClose

    case throwError(CompositeErrorRepository)
  }
}

// MARK: TodoReducer.CancelID

extension TodoReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestTodoItem
    case requestUpdateMemo
  }
}
