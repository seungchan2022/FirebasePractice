import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - TodoDetailSideEffect

struct TodoDetailSideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension TodoDetailSideEffect {
  var getCategoryItem: (TodoListEntity.Category.Item) -> Effect<TodoDetailReducer.Action> {
    { categoryItem in
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.todoListUseCase.getCategoryItem(user.uid, categoryItem.id)
          await send(TodoDetailReducer.Action.fetchCategoryItem(.success(response)))
        } catch {
          await send(TodoDetailReducer.Action.fetchCategoryItem(.failure(.other(error))))
        }
      }
    }
  }
}
