import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - TodoListDetailReducer

@Reducer
struct TodoListDetailReducer {
  let sideEffect: TodoListDetailSideEffect

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

      case .onTapAddTodoItem(let item):
        state.fetchAddTodoItem.isLoading = true
        return sideEffect
          .addTodoItem(item)
          .cancellable(pageID: state.id, id: CancelID.requestAddTodoItem, cancelInFlight: true)

      case .fetchAddTodoItem(let result):
        state.fetchAddTodoItem.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "성공")
            return .run { await $0(.getTodoItemList) }

          case false: sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getTodoItemList:
        state.fetchTodoItemList.isLoading = true
        return sideEffect
          .getTodoItemList(state.categoryItem.id)
          .cancellable(pageID: state.id, id: CancelID.requestTodoItemList, cancelInFlight: true)

      case .fetchTodoItemList(let result):
        state.fetchTodoItemList.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchTodoItemList.value = itemList
          state.todoItemList = itemList
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapUpdateItemStatus(let item):
        state.fetchUpdateTodoItemStatus.isLoading = true
        return sideEffect
          .updateTodoItemStatus(item)
          .cancellable(pageID: state.id, id: CancelID.requestUpdateToItemStatus, cancelInFlight: true)

      case .fetchUpdateTodoItemStatus(let result):
        state.fetchUpdateTodoItemStatus.isLoading = false
        switch result {
        case .success(let item):
          state.todoItemList = state.todoItemList.mutate(item: item)
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapEditTodoItemTitle(let item):
        state.fetchEditTodoItemTitle.isLoading = true
        return sideEffect
          .editTodoItemTitle(item, state.newTodoTitleText)
          .cancellable(pageID: state.id, id: CancelID.requestEditTodoTitle, cancelInFlight: true)

      case .fetchEditTodoItemTitle(let result):
        state.fetchEditTodoItemTitle.isLoading = false
        switch result {
        case .success(let item):
          state.fetchEditTodoItemTitle.value = item
          state.todoItemList = state.todoItemList.mutate(item: item)
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapDeleteTodoItem(let item):
        state.fetchDeleteTodoItem.isLoading = true
        return sideEffect
          .deleteTodoItem(item)
          .cancellable(pageID: state.id, id: CancelID.requestDeleteTodoItem, cancelInFlight: true)

      case .fetchDeleteTodoItem(let result):
        state.fetchDeleteTodoItem.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "성공")
            return .run { await $0(.getTodoItemList) }

          case false: sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapTodoItem(let item):
        sideEffect.routeTodo(item)
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

}

extension TodoListDetailReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {

    // MARK: Lifecycle

    init(
      id: UUID = UUID(),
      categoryItem: TodoListEntity.Category.Item)
    {
      self.id = id
      self.categoryItem = categoryItem
    }

    // MARK: Internal

    let id: UUID

    let categoryItem: TodoListEntity.Category.Item

    var todoTitleText = ""
    var isShowAlert = false

    var todoItem: TodoListEntity.TodoItem.Item? = .none
    var newTodoTitleText = ""
    var isShowEditAlert = false

    var todoItemList: [TodoListEntity.TodoItem.Item] = []

    var fetchCategoryItem: FetchState.Data<TodoListEntity.Category.Item?> = .init(isLoading: false, value: .none)

    var fetchAddTodoItem: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchTodoItemList: FetchState.Data<[TodoListEntity.TodoItem.Item]?> = .init(isLoading: false, value: .none)

    var fetchUpdateTodoItemStatus: FetchState.Data<TodoListEntity.TodoItem.Item?> = .init(isLoading: false, value: .none)
    var fetchEditTodoItemTitle: FetchState.Data<TodoListEntity.TodoItem.Item?> = .init(isLoading: false, value: .none)

    var fetchDeleteTodoItem: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getCategoryItem(TodoListEntity.Category.Item)
    case fetchCategoryItem(Result<TodoListEntity.Category.Item, CompositeErrorRepository>)

    case onTapAddTodoItem(TodoListEntity.TodoItem.Item)
    case fetchAddTodoItem(Result<Bool, CompositeErrorRepository>)

    case getTodoItemList
    case fetchTodoItemList(Result<[TodoListEntity.TodoItem.Item], CompositeErrorRepository>)

    case onTapUpdateItemStatus(TodoListEntity.TodoItem.Item)
    case fetchUpdateTodoItemStatus(Result<TodoListEntity.TodoItem.Item, CompositeErrorRepository>)

    case onTapEditTodoItemTitle(TodoListEntity.TodoItem.Item)
    case fetchEditTodoItemTitle(Result<TodoListEntity.TodoItem.Item, CompositeErrorRepository>)

    case onTapDeleteTodoItem(TodoListEntity.TodoItem.Item)
    case fetchDeleteTodoItem(Result<Bool, CompositeErrorRepository>)

    case onTapTodoItem(TodoListEntity.TodoItem.Item)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: TodoListDetailReducer.CancelID

extension TodoListDetailReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestCategoryItem
    case requestAddTodoItem
    case requestTodoItemList
    case requestUpdateToItemStatus
    case requestDeleteTodoItem
    case requestEditTodoTitle
  }
}

extension [TodoListEntity.TodoItem.Item] {
  fileprivate func mutate(item: TodoListEntity.TodoItem.Item) -> Self {
    self.map { $0.id == item.id ? item : $0 }
  }
}
