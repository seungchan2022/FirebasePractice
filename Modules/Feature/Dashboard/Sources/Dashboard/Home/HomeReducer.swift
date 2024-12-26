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
            sideEffect.routeToSignIn()
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
            sideEffect.useCaseGroup.toastViewModel.send(message: "비밀번호 변경이 완료되었습니다. 변경된 비밀번호로 로그인 해주세요.")

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(message: "비밀번호 변경도중 에러가 발생했습니다.")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapDeleteUser:
        state.fetchDeleteUser.isLoading = true
        return sideEffect
          .deleteUser(state.passwordText)
          .cancellable(pageID: state.id, id: CancelID.requestDeleteUser, cancelInFlight: true)

      case .fetchDeleteUser(let result):
        state.fetchDeleteUser.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "계정이 탈퇴되었습니다!")
            sideEffect.routeToSignIn()

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "계정 탈퇴중 오류가 발생했습니다.")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapDeleteKakaoUser:
        state.fetchDeleteKakaoUser.isLoading = true
        return sideEffect
          .deleteKakaoUser()
          .cancellable(pageID: state.id, id: CancelID.requestDeleteKakaoUser, cancelInFlight: true)

      case .fetchDeleteKakaoUser(let result):
        state.fetchDeleteKakaoUser.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "카카오 계정이 탈퇴되었습니다!")
            sideEffect.routeToSignIn()

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "카카오 계정 탈퇴중 오류가 발생했습니다.")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getProvider:
        state.fetchProvider.isLoading = true
        return sideEffect
          .getProvider()
          .cancellable(pageID: state.id, id: CancelID.requestGetProvider, cancelInFlight: true)

      case .fetchProvider(let result):
        state.fetchProvider.isLoading = false
        switch result {
        case .success(let itemList):
          state.fetchProvider.value = itemList
          state.providerList = state.providerList + itemList
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

    // MARK: Lifecycle

    init(id: UUID = .init()) {
      self.id = id
    }

    // MARK: Internal

    let id: UUID

    var user: AuthEntity.Me.Response = .init(uid: "", email: "", userName: "", photoURL: "")

    var providerList: [AuthEntity.ProviderOption.Option] = []
    var fetchProvider: FetchState.Data<[AuthEntity.ProviderOption.Option]?> = .init(isLoading: false, value: .none)

    var isShowUpdatePassword = false
    var isShowCurrPassword = false
    var isShowNewPassword = false
    var isShowDeleteUserAlert = false
    var isShowDeleteKakaoUserAlert = false
    var isShowSignOutAlert = false

    var currPasswordText = ""
    var newPasswordText = ""
    var passwordText = ""

    var fetchUser: FetchState.Data<AuthEntity.Me.Response?> = .init(isLoading: false, value: .none)
    var fetchSignOut: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchUpdatePassword: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchDeleteUser: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteKakaoUser: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

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

    case onTapDeleteUser
    case fetchDeleteUser(Result<Bool, CompositeErrorRepository>)

    case onTapDeleteKakaoUser
    case fetchDeleteKakaoUser(Result<Bool, CompositeErrorRepository>)

    case getProvider
    case fetchProvider(Result<[AuthEntity.ProviderOption.Option], CompositeErrorRepository>)

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
    case requestDeleteUser
    case requestDeleteKakaoUser
    case requestGetProvider
  }
}
