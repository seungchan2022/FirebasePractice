import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigator

// MARK: - TodoSideEffect

struct TodoSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension TodoSideEffect {
  var getTodoItem: (TodoListEntity.TodoItem.Item) -> Effect<TodoReducer.Action> {
    { item in
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()

          let response = try await useCaseGroup.todoListUseCase.getTodoItem(user.uid, item.categoryId, item.id)

          await send(TodoReducer.Action.fetchTodoItem(.success(response)))
        } catch {
          await send(TodoReducer.Action.fetchTodoItem(.failure(.other(error))))
        }
      }
    }
  }

  var updateMemo: (TodoListEntity.TodoItem.Item, String) -> Effect<TodoReducer.Action> {
    { item, memoText in
      .run { send in
        do {
          let response = try await useCaseGroup.todoListUseCase.updateMemo(item, memoText)
          await send(TodoReducer.Action.fetchUpdateMemo(.success(response)))
        } catch {
          await send(TodoReducer.Action.fetchUpdateMemo(.failure(.other(error))))
        }
      }
    }
  }

  var routeToClose: () -> Void {
    {
      navigator.close(isAnimated: true, completeAction: { })
    }
  }
}
