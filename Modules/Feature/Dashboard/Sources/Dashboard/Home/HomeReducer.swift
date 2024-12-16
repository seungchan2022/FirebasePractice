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

      case .getUser:
        state.fetchUser.isLoading = true
        return sideEffect
          .getUser()
          .cancellable(pageID: state.id, id: CanelID.requestUser, cancelInFlight: true)

      case .fetchUser(let result):
        state.fetchUser.isLoading = false
        switch result {
        case .success(let item):
          state.user = item
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapSignOut:
        state.fetchSignOut.isLoading = false
        return sideEffect
          .signOut()
          .cancellable(pageID: state.id, id: CanelID.requestSignOut, cancelInFlight: true)

      case .fetchSignOut(let result):
        state.fetchSignOut.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.routeSignIn()
            sideEffect.useCaseGroup.toastViewModel.send(message: "로그아웃 성공")

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "로그아웃 실패")
          }
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

extension HomeReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {
    let id: UUID

    var user: AuthEntity.Me.Response = .init(uid: "", email: "", photoURL: "")

    var fetchUser: FetchState.Data<AuthEntity.Me.Response?> = .init(isLoading: false, value: .none)
    var fetchSignOut: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    init(id: UUID = .init()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getUser
    case fetchUser(Result<AuthEntity.Me.Response, CompositeErrorRepository>)

    case onTapSignOut
    case fetchSignOut(Result<Bool, CompositeErrorRepository>)

    case throwError(CompositeErrorRepository)
  }

}

// MARK: HomeReducer.CanelID

extension HomeReducer {
  enum CanelID: Equatable, CaseIterable {
    case teardown
    case requestUser
    case requestSignOut
  }
}
