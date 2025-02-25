import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - GroupListReducer

@Reducer
struct GroupListReducer {
  let sideEffect: GroupListSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapCreateGroup(let groupName):
        state.fetchCreateGroup.isLoading = true
        return sideEffect
          .createGroup(groupName)
          .cancellable(pageID: state.id, id: CancelID.requestCreateGroup, cancelInFlight: true)

      case .fetchCreateGroup(let result):
        state.fetchCreateGroup.isLoading = false
        switch result {
        case .success(let item):
          state.fetchCreateGroup.value = item
          state.groupItem = item
          state.groupList = state.groupList + [item]
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getGroupList:
        state.fetchGroupList.isLoading = true
        return sideEffect
          .getGroupList()
          .cancellable(pageID: state.id, id: CancelID.requestGroupList, cancelInFlight: true)

      case .fetchGroupList(let result):
        state.fetchGroupList.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchGroupList.value = itemList
          state.groupList = state.groupList.merge(itemList)
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapGroupItem(let item):
        sideEffect.routeToGroupDetail(item)
        return .none

      case .routeToNewGroup:
        sideEffect.routeToNewGroup()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroupList.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }
}

extension GroupListReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    init(id: UUID = UUID()) {
      self.id = id
    }

    var groupItem: GroupListEntity.Group.Item? = .none

    var groupList: [GroupListEntity.Group.Item] = []

    var fetchCreateGroup: FetchState.Data<GroupListEntity.Group.Item?> = .init(isLoading: false, value: .none)

    var fetchGroupList: FetchState.Data<[GroupListEntity.Group.Item]?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapCreateGroup(String)
    case fetchCreateGroup(Result<GroupListEntity.Group.Item, CompositeErrorRepository>)

    case getGroupList
    case fetchGroupList(Result<[GroupListEntity.Group.Item], CompositeErrorRepository>)

    case onTapGroupItem(GroupListEntity.Group.Item)

    case routeToNewGroup

    case throwError(CompositeErrorRepository)
  }
}

// MARK: GroupListReducer.CancelID

extension GroupListReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestCreateGroup
    case requestGroupList
  }
}

extension [GroupListEntity.Group.Item] {
  /// 중복된게 올라옴
  fileprivate func merge(_ target: Self) -> Self {
    let new = target.reduce(self) { curr, next in
      guard !self.contains(where: { $0.id == next.id }) else { return curr }
      return curr + [next]
    }

    return new
  }
}
