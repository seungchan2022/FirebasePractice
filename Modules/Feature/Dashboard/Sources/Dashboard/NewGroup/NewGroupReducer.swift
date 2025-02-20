import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - NewGroupReducer

@Reducer
struct NewGroupReducer {
  let sideEffect: NewGroupSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .getUserList(let limit, let item):
        state.fetchUserList.isLoading = true
        return sideEffect
          .getUserList(limit, item)
          .cancellable(pageID: state.id, id: CancelID.requestUserList, cancelInFlight: true)

      case .fetchUserList(let result):
        state.fetchUserList.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchUserList.value = itemList
          state.userList = state.userList.merge(itemList)
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToClose:
        sideEffect.routeToClose()
        return .none

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }
}

extension NewGroupReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    init(id: UUID = UUID()) {
      self.id = id
    }

    var groupName = ""
    var selectedUserList: [UserEntity.User.Response] = []

    var lastUser: UserEntity.User.Response? = .none
    var userList: [UserEntity.User.Response] = []

    var fetchUserList: FetchState.Data<[UserEntity.User.Response]?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getUserList(Int, UserEntity.User.Response?)
    case fetchUserList(Result<[UserEntity.User.Response], CompositeErrorRepository>)

    case routeToClose

    case throwError(CompositeErrorRepository)
  }
}

// MARK: NewGroupReducer.CancelID

extension NewGroupReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUserList
  }
}

extension [UserEntity.User.Response] {
  fileprivate func merge(_ target: Self) -> Self {
    let new = target.reduce(self) { curr, next in
      guard !self.contains(where: { $0.uid == next.uid }) else { return curr }
      return curr + [next]
    }

    return new
  }
}
