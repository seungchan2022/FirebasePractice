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
  var addCategoryItem: (TodoListEntity.Category.Item) -> Effect<TodoListReducer.Action> {
    { item in
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.todoListUseCase.addCategoryItem(user.uid, item)
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
