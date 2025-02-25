import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - GroupListDetailReducer

@Reducer
struct GroupListDetailReducer {
  let sideEffect: GroupListDetailSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .getTodoItemList:
        state.fetchTodoItemList.isLoading = true
        return sideEffect
          .getTodoItemList(state.groupItem.id)
          .cancellable(pageID: state.id, id: CancelID.requestGetTodoItemList, cancelInFlight: true)

      case .fetchTodoItemList(let result):
        state.fetchTodoItemList.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchTodoItemList.value = itemList
//          state.todoItemList = state.todoItemList + itemList
          state.todoItemList = state.todoItemList.merged(with: itemList)

          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToSelectCategory(let item):
        sideEffect.routeToSelectCategory(item)
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }
}

extension GroupListDetailReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID
    let groupItem: GroupListEntity.Group.Item

    init(
      id: UUID = UUID(),
      groupItem: GroupListEntity.Group.Item)
    {
      self.id = id
      self.groupItem = groupItem
    }

    var todoItemList: [String: [TodoListEntity.TodoItem.Item]] = [:]
    var fetchTodoItemList: FetchState.Data<[String: [TodoListEntity.TodoItem.Item]]?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getTodoItemList
    case fetchTodoItemList(Result<[String: [TodoListEntity.TodoItem.Item]], CompositeErrorRepository>)

    case routeToSelectCategory(GroupListEntity.Group.Item)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: GroupListDetailReducer.CancelID

extension GroupListDetailReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestGetTodoItemList
  }
}

extension [String: [TodoListEntity.TodoItem.Item]] {
  /// 중복 검사 후 항목을 병합하는 메서드
  func merged(with target: Self) -> Self {
    merging(target) { existing, new in
      existing + new.filter { newItem in
        !existing.contains(where: { $0.id == newItem.id })
      }
    }
  }
}
