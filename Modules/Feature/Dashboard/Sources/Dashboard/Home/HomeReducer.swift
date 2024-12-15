import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - HomeReducer

@Reducer
struct HomeReducer {
  let sideEffect: HomeSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CanelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapBack:
        sideEffect.routeToBack()
        return .none

      case .throwError(let error):
//        print(error)
        sideEffect.useCaseGroup.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

}

extension HomeReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    init(id: UUID = .init()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapBack

    case throwError(CompositeErrorRepository)
  }

}

// MARK: HomeReducer.CanelID

extension HomeReducer {
  enum CanelID: Equatable, CaseIterable {
    case teardown
  }
}
