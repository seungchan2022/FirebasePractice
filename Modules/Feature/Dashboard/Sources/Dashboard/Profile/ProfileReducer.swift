import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - ProfileReducer

@Reducer
struct ProfileReducer {
  let sideEffect: ProfileSideEffect

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
        case .success(let user):
          state.fetchUser.value = user
          state.user = user
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .getDBUser:
        state.fetchDBUser.isLoading = true
        return sideEffect
          .getDBUser()
          .cancellable(pageID: state.id, id: CancelID.requestDBUser, cancelInFlight: true)

      case .fetchDBUser(let result):
        state.fetchDBUser.isLoading = false
        switch result {
        case .success(let user):
          state.fetchDBUser.value = user
          state.dbUser = user
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

      case .onTapDeleteGoogleUser:
        state.fetchDeleteGoogleUser.isLoading = true
        return sideEffect
          .deleteGoogleUser()
          .cancellable(pageID: state.id, id: CancelID.requestDeleteGoogleUser, cancelInFlight: true)

      case .fetchDeleteGoogleUser(let result):
        state.fetchDeleteGoogleUser.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "구글 계정이 탈퇴되었습니다!")
            sideEffect.routeToSignIn()

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "구글 계정 탈퇴중 오류가 발생했습니다.")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapDeleteAppleUser:
        state.fetchDeleteAppleUser.isLoading = true
        return sideEffect
          .deleteAppleUser()
          .cancellable(pageID: state.id, id: CancelID.requestDeleteAppleUser, cancelInFlight: true)

      case .fetchDeleteAppleUser(let result):
        state.fetchDeleteAppleUser.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "애플 계정이 탈퇴되었습니다!")
            sideEffect.routeToSignIn()

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "애플 계정 탈퇴중 오류가 발생했습니다.")
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

      case .onTapUpdateStatus:
        state.fetchUpdateStatus.isLoading = true
        return sideEffect
          .updateStatus()
          .cancellable(pageID: state.id, id: CancelID.requestUpdatStatus, cancelInFlight: true)

      case .fetchUpdateStatus(let result):
        state.fetchUpdateStatus.isLoading = false
        switch result {
        case .success(let user):
          state.fetchUpdateStatus.value = user
          state.dbUser = user
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapWishItem(let item):
        state.fetchWishItem.isLoading = true
        return sideEffect
          .addWishItem(item)
          .cancellable(pageID: state.id, id: CancelID.requestAddWishItem, cancelInFlight: true)

      case .fetchWishItem(let result):
        state.fetchWishItem.isLoading = false
        switch result {
        case .success(let user):
          state.fetchWishItem.value = user
          state.dbUser = user
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapRemoveItem(let item):
        state.fetchRemoveItem.isLoading = true
        return sideEffect
          .removeWishItem(item)
          .cancellable(pageID: state.id, id: CancelID.requestRemoveWishItem, cancelInFlight: true)

      case .fetchRemoveItem(let result):
        state.fetchRemoveItem.isLoading = false
        switch result {
        case .success(let user):
          state.fetchRemoveItem.value = user
          state.dbUser = user
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapAddMovieItem:
        state.fetchAddMovidItem.isLoading = true
        return sideEffect
          .addMovieItem()
          .cancellable(pageID: state.id, id: CancelID.requestAddMovieItem, cancelInFlight: true)

      case .fetchAddMovieItem(let result):
        state.fetchAddMovidItem.isLoading = false
        switch result {
        case .success(let user):
          state.fetchAddMovidItem.value = user
          state.dbUser = user
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapRemoveMovieItem:
        state.fetchRemoveMovieItem.isLoading = true
        return sideEffect
          .removeMovieItem()
          .cancellable(pageID: state.id, id: CancelID.requestRemoveMovieItem, cancelInFlight: true)

      case .fetchRemoveMovieItem(let result):
        state.fetchRemoveMovieItem.isLoading = false
        switch result {
        case .success(let user):
          state.fetchRemoveMovieItem.value = user
          state.dbUser = user
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

extension ProfileReducer {
  @ObservableState
  struct State: Equatable, Identifiable, Sendable {

    // MARK: Lifecycle

    init(id: UUID = .init()) {
      self.id = id
    }

    // MARK: Internal

    let id: UUID

    var user: AuthEntity.Me.Response? = .none
    var dbUser: UserEntity.User.Response? = .none

    let wishList: [String] = ["영화", "스포츠", "독서"]

    var providerList: [AuthEntity.ProviderOption.Option] = []
    var fetchProvider: FetchState.Data<[AuthEntity.ProviderOption.Option]?> = .init(isLoading: false, value: .none)

    var isShowUpdatePassword = false
    var isShowCurrPassword = false
    var isShowNewPassword = false
    var isShowDeleteUserAlert = false
    var isShowDeleteKakaoUserAlert = false
    var isShowDeleteGoogleUserAlert = false
    var isShowDeleteAppleUserAlert = false
    var isShowSignOutAlert = false

    var currPasswordText = ""
    var newPasswordText = ""
    var passwordText = ""

    var fetchUser: FetchState.Data<AuthEntity.Me.Response?> = .init(isLoading: false, value: .none)
    var fetchSignOut: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchUpdatePassword: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchDeleteUser: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteKakaoUser: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteGoogleUser: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchDeleteAppleUser: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchDBUser: FetchState.Data<UserEntity.User.Response?> = .init(isLoading: false, value: .none)

    var fetchUpdateStatus: FetchState.Data<UserEntity.User.Response?> = .init(isLoading: false, value: .none)

    var fetchWishItem: FetchState.Data<UserEntity.User.Response?> = .init(isLoading: false, value: .none)
    var fetchRemoveItem: FetchState.Data<UserEntity.User.Response?> = .init(isLoading: false, value: .none)

    var fetchAddMovidItem: FetchState.Data<UserEntity.User.Response?> = .init(isLoading: false, value: .none)
    var fetchRemoveMovieItem: FetchState.Data<UserEntity.User.Response?> = .init(isLoading: false, value: .none)

  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getUser
    case fetchUser(Result<AuthEntity.Me.Response, CompositeErrorRepository>)

    case getDBUser
    case fetchDBUser(Result<UserEntity.User.Response, CompositeErrorRepository>)

    case onTapSignOut
    case fetchSignOut(Result<Bool, CompositeErrorRepository>)

    case onTapUpdatePassword
    case fetchUpdatePassword(Result<Bool, CompositeErrorRepository>)

    case onTapDeleteUser
    case fetchDeleteUser(Result<Bool, CompositeErrorRepository>)

    case onTapDeleteKakaoUser
    case fetchDeleteKakaoUser(Result<Bool, CompositeErrorRepository>)

    case onTapDeleteGoogleUser
    case fetchDeleteGoogleUser(Result<Bool, CompositeErrorRepository>)

    case onTapDeleteAppleUser
    case fetchDeleteAppleUser(Result<Bool, CompositeErrorRepository>)

    case getProvider
    case fetchProvider(Result<[AuthEntity.ProviderOption.Option], CompositeErrorRepository>)

    case onTapUpdateStatus
    case fetchUpdateStatus(Result<UserEntity.User.Response, CompositeErrorRepository>)

    case onTapWishItem(String)
    case fetchWishItem(Result<UserEntity.User.Response, CompositeErrorRepository>)

    case onTapRemoveItem(String)
    case fetchRemoveItem(Result<UserEntity.User.Response, CompositeErrorRepository>)

    case onTapAddMovieItem
    case fetchAddMovieItem(Result<UserEntity.User.Response, CompositeErrorRepository>)

    case onTapRemoveMovieItem
    case fetchRemoveMovieItem(Result<UserEntity.User.Response, CompositeErrorRepository>)

    case throwError(CompositeErrorRepository)
  }

}

// MARK: ProfileReducer.CancelID

extension ProfileReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestUser
    case requestSignOut
    case requestUpdatePassword
    case requestDeleteUser
    case requestDeleteKakaoUser
    case requestDeleteGoogleUser
    case requestDeleteAppleUser
    case requestGetProvider
    case requestDBUser
    case requestUpdatStatus
    case requestAddWishItem
    case requestRemoveWishItem
    case requestAddMovieItem
    case requestRemoveMovieItem
  }
}
