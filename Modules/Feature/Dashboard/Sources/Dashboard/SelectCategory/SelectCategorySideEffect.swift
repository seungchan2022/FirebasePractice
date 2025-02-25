import Architecture
import ComposableArchitecture
import Domain
import LinkNavigator

// MARK: - SelectCategorySideEffect

struct SelectCategorySideEffect {
  let useCaseGroup: DashboardSidEffect
  let navigator: RootNavigatorType
}

extension SelectCategorySideEffect {
  var getCategoryItemList: () -> Effect<SelectCategoryReducer.Action> {
    {
      .run { send in
        do {
          let user = try useCaseGroup.authUseCase.me()
          let response = try await useCaseGroup.groupListUseCase.getCategoryItemList(user.uid)
          await send(SelectCategoryReducer.Action.fetchCategoryItemList(.success(response)))
        } catch {
          await send(SelectCategoryReducer.Action.fetchCategoryItemList(.failure(.other(error))))
        }
      }
    }
  }

  var addCategoryItemList: (String, [String]) -> Effect<SelectCategoryReducer.Action> {
    { groupId, categoryIdList in
      .run { send in
        do {
          let response = try await useCaseGroup.groupListUseCase.addCategoryItemList(groupId, categoryIdList)
          await send(SelectCategoryReducer.Action.fetchAddCategoryItemList(.success(response)))
        } catch {
          await send(SelectCategoryReducer.Action.fetchAddCategoryItemList(.failure(.other(error))))
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
