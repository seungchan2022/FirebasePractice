import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SignInReducer

@Reducer
struct SignInReducer {

  let sideEffect: SignInSideEffect

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .onTapSignIn:
        state.fetchSignIn.isLoading = true
        return sideEffect
          .signInEmail(.init(email: state.emailText, password: state.passwordText))
          .cancellable(pageID: state.id, id: CancelID.requestSignIn, cancelInFlight: true)

      case .fetchSignIn(let result):
        state.fetchSignIn.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.useCaseGroup.toastViewModel.send(message: "로그인 성공")
            sideEffect.routeToHome()

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "로그인 실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapSignUp:
        sideEffect.routeToSignUp()
        return .none

      case .onTapResetPassword:
        state.fetchResetPassword.isLoading = true
        return sideEffect
          .resetPassword(state.resetEmailText)
          .cancellable(pageID: state.id, id: CancelID.requestResetPassword, cancelInFlight: true)

      case .fetchResetPassword(let result):
        state.fetchResetPassword.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            state.isShowResetPassword = false
            sideEffect.useCaseGroup.toastViewModel.send(message: "입력하신 이메일로 비밀번호 재설정 링크를 보냈습니다.")

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "에러가 발생했습니다.")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapSignInGoogle:
        state.fetchSignInGoogle.isLoading = true
        return sideEffect
          .googleSignIn()
          .cancellable(pageID: state.id, id: CancelID.requestGoogleSignIn, cancelInFlight: true)

      case .fetchSignInGoogle(let result):
        state.fetchSignInGoogle.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.routeToHome()
            sideEffect.useCaseGroup.toastViewModel.send(message: "구글 로그인 성공")

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "구글 로그인 실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapSignInApple:
        state.fetchSignInApple.isLoading = false
        return sideEffect
          .appleSignIn()
          .cancellable(pageID: state.id, id: CancelID.requestAppleSignIn, cancelInFlight: true)

      case .fetchSignInApple(let result):
        state.fetchSignInApple.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.routeToHome()
            sideEffect.useCaseGroup.toastViewModel.send(message: "애플 로그인 성공")

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "애플 로그인 실패")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .onTapSignInKakao:
        state.fetchSignInKakao.isLoading = true
        return sideEffect
          .kakaoSignIn()
          .cancellable(pageID: state.id, id: CancelID.requestKakaoSignIn, cancelInFlight: true)

      case .fetchSignInKakao(let result):
        state.fetchSignInKakao.isLoading = false
        switch result {
        case .success(let status):
          switch status {
          case true:
            sideEffect.routeToHome()
            sideEffect.useCaseGroup.toastViewModel.send(message: "카카오 로그인 성공")

          case false:
            sideEffect.useCaseGroup.toastViewModel.send(errorMessage: "카카오 로그인 실패")
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

extension SignInReducer {

  @ObservableState
  struct State: Equatable, Identifiable, Sendable {

    // MARK: Lifecycle

    init(id: UUID = UUID()) {
      self.id = id
    }

    // MARK: Internal

    let id: UUID

    var emailText = ""
    var passwordText = ""

    var resetEmailText = ""

    var isShowPassword = false

    var isShowResetPassword = false

    var fetchSignIn: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchResetPassword: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchSignInGoogle: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)

    var fetchSignInApple: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
    var fetchSignInKakao: FetchState.Data<Bool?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case onTapSignIn
    case fetchSignIn(Result<Bool, CompositeErrorRepository>)

    case onTapSignUp

    case onTapResetPassword
    case fetchResetPassword(Result<Bool, CompositeErrorRepository>)

    case onTapSignInGoogle
    case fetchSignInGoogle(Result<Bool, CompositeErrorRepository>)

    case onTapSignInApple
    case fetchSignInApple(Result<Bool, CompositeErrorRepository>)

    case onTapSignInKakao
    case fetchSignInKakao(Result<Bool, CompositeErrorRepository>)

    case throwError(CompositeErrorRepository)
  }
}

// MARK: SignInReducer.CancelID

extension SignInReducer {
  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestSignIn
    case requestResetPassword
    case requestGoogleSignIn
    case requestAppleSignIn
    case requestKakaoSignIn
  }
}
