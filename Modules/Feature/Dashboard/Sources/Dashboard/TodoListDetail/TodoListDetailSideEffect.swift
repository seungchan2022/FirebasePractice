import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - TodoListDetailSideEffect

struct TodoListDetailSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension TodoListDetailSideEffect {
  var getCategoryItem: (TodoListEntity.Category.Item) -> Effect<TodoListDetailReducer.Action> {
    { categoryItem in
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.todoListUseCase.getCategoryItem(user.uid, categoryItem.id)
          await send(TodoListDetailReducer.Action.fetchCategoryItem(.success(response)))
        } catch {
          await send(TodoListDetailReducer.Action.fetchCategoryItem(.failure(.other(error))))
        }
      }
    }
  }

  var addTodoItem: (TodoListEntity.TodoItem.Item) -> Effect<TodoListDetailReducer.Action> {
    { item in
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.todoListUseCase.addTodoItem(user.uid, item.categoryId, item)
          await send(TodoListDetailReducer.Action.fetchAddTodoItem(.success(response)))
        } catch {
          await send(TodoListDetailReducer.Action.fetchAddTodoItem(.failure(.other(error))))
        }
      }
    }
  }

  var getTodoItemList: (String) -> Effect<TodoListDetailReducer.Action> {
    { categoryId in
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.todoListUseCase.getTodoItemList(user.uid, categoryId)
          await send(TodoListDetailReducer.Action.fetchTodoItemList(.success(response)))

        } catch {
          await send(TodoListDetailReducer.Action.fetchTodoItemList(.failure(.other(error))))
        }
      }
    }
  }
}
