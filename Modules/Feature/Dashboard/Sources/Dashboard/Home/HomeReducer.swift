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
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .getUser:
        state.fetchUser.isLoading = true
        return sideEffect
          .getUser()
          .cancellable(pageID: state.id, id: CancelID.requestUser, cancelInFlight: true)

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
          .cancellable(pageID: state.id, id: CancelID.requestSignOut, cancelInFlight: true)

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

      case .onTapUpdatePassword:
        if state.currPasswordText == state.newPasswordText {
          sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "현재 비밀번호와 다르게 설정해주세요")
          state.fetchUpdatePassword.isLoading = false
          return .none
        }

        state.fetchUpdatePassword.isLoading = true
        return sideEffect
          .updatePassword(state.currPasswordText, state.newPasswordText)
          .cancellable(pageID: state.id, id: CancelID.requestUpdatePassword, cancelInFlight: true)

      case .fetchUpdatePassword(let result):
        state.fetchUpdatePassword.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            state.isShowUpdatePassword = false
            sideEffect.useCaseGroup.toastViewModel.send(message: "비밀번호 변경이 완료되었습니다.")

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(message: "비밀번호 변경도중 에러가 발생했습니다.")
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

    var isShowUpdatePassword = false

    var isShowCurrPassword = false
    var isShowNewPassword = false

    var currPasswordText = ""
    var newPasswordText = ""

    var fetchUser: FetchState.Data<AuthEntity.Me.Response?> = .init(isLoading: false, value: .none)
    var fetchSignOut: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchUpdatePassword: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

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

    case onTapUpdatePassword

    case fetchUpdatePassword(Result<Bool, CompositeErrorRepository>)

    case throwError(CompositeErrorRepository)
  }

}

// MARK: HomeReducer.CancelID

extension HomeReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUser
    case requestSignOut
    case requestUpdatePassword
  }
}
