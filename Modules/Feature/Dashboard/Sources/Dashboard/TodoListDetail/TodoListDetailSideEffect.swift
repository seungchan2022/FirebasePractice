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

  var updateTodoItemStatus: (TodoListEntity.TodoItem.Item) -> Effect<TodoListDetailReducer.Action> {
    { item in
      .run { send in
        do {
          let response = try await useCaseGroup.todoListUseCase.updateTodoItemStatus(item, !(item.isCompleted ?? false))
          await send(TodoListDetailReducer.Action.fetchUpdateTodoItemStatus(.success(response)))
        } catch {
          await send(TodoListDetailReducer.Action.fetchUpdateTodoItemStatus(.failure(.other(error))))
        }
      }
    }
  }

  var editTodoItemTitle: (TodoListEntity.TodoItem.Item, String) -> Effect<TodoListDetailReducer.Action> {
    { item, newTitle in
      .run { send in
        do {
          let response = try await useCaseGroup.todoListUseCase.editTodoItemTitle(item, newTitle)
          await send(TodoListDetailReducer.Action.fetchEditTodoItemTitle(.success(response)))
        } catch {
          await send(TodoListDetailReducer.Action.fetchEditTodoItemTitle(.failure(.other(error))))
        }
      }
    }
  }

  var deleteTodoItem: (TodoListEntity.TodoItem.Item) -> Effect<TodoListDetailReducer.Action> {
    { item in
      .run { send in
        do {
          let response = try await useCaseGroup.todoListUseCase.deleteTodoItem(item)
          await send(TodoListDetailReducer.Action.fetchDeleteTodoItem(.success(response)))
        } catch {
          await send(TodoListDetailReducer.Action.fetchDeleteTodoItem(.failure(.other(error))))
        }
      }
    }
  }

  var routeTodo: (TodoListEntity.TodoItem.Item) -> Void {
    { item in
      navigator.fullSheet(
        linkItem: .init(
          path: Link.Dashboard.Path.todo.rawValue,
          items: item),
        isAnimated: true,
        prefersLargeTitles: false)
    }
  }
}
