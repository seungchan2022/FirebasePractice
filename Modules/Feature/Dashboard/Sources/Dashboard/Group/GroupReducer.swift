import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - GroupReducer

@Reducer
struct GroupReducer {
  let sideEffect: GroupSideEffect

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
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .throwError(let error):
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }
}

extension GroupReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    init(id: UUID = UUID()) {
      self.id = id
    }

    var groupItem: GroupEntity.Group.Item? = .none

    var fetchCreateGroup: FetchState.Data<GroupEntity.Group.Item?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapCreateGroup(String)
    case fetchCreateGroup(Result<GroupEntity.Group.Item, CompositeErrorRepository>)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: GroupReducer.CancelID

extension GroupReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestCreateGroup
  }
}
