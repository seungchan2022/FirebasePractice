import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - TodoListSideEffect

struct TodoListSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension TodoListSideEffect {

  var addCategoryItem: (String) -> Effect<TodoListReducer.Action> {
    { categoryName in
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.todoListUseCase.addCategoryItem(user.uid, categoryName)
          await send(TodoListReducer.Action.fetchAddCategoryItem(.success(response)))
        } catch {
          await send(TodoListReducer.Action.fetchAddCategoryItem(.failure(.other(error))))
        }
      }
    }
  }

  var getCategoryItemList: () -> Effect<TodoListReducer.Action> {
    {
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.todoListUseCase.getCategoryItemList(user.uid)
          await send(TodoListReducer.Action.fetchCategoryItemList(.success(response)))
        } catch {
          await send(TodoListReducer.Action.fetchCategoryItemList(.failure(.other(error))))
        }
      }
    }
  }

  var deleteCategoryItem: (TodoListEntity.Category.Item) -> Effect<TodoListReducer.Action> {
    { item in
      .run { send in
        do {
          let response = try await useCaseGroup.todoListUseCase.deleteCategoryItem(item)
          await send(TodoListReducer.Action.fetchDeleteCategoryItem(.success(response)))
        } catch {
          await send(TodoListReducer.Action.fetchDeleteCategoryItem(.failure(.other(error))))
        }
      }
    }
  }

  var editCategoryItemTitle: (TodoListEntity.Category.Item, String) -> Effect<TodoListReducer.Action> {
    { item, newTitle in
      .run { send in
        do {
          let response = try await useCaseGroup.todoListUseCase.editCategoryItemTitle(item, newTitle)
          await send(TodoListReducer.Action.fetchEditCategoryItemTitle(.success(response)))
        } catch {
          await send(TodoListReducer.Action.fetchEditCategoryItemTitle(.failure(.other(error))))
        }
      }
    }
  }

  var routeToDetail: (TodoListEntity.Category.Item) -> Void {
    { item in
      navigator.next(
        linkItem: .init(
          path: Link.Dashboard.Path.todoListDetail.rawValue,
          items: item),
        isAnimated: true)
    }
  }

}
