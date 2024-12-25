import ComposableArchitecture
import DesignSystem
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

// MARK: - SignInPage

struct SignInPage {
  @Bindable var store: StoreOf<SignInReducer>
}

extension SignInPage {
  @MainActor
  private var isActiveSignIn: Bool {
    !store.emailText.isEmpty && !store.passwordText.isEmpty
  }

  @MainActor
  private var isLoading: Bool {
    store.fetchSignIn.isLoading
      || store.fetchSignInApple.isLoading
      || store.fetchSignInKakao.isLoading
      || store.fetchSignInGoogle.isLoading
  }
}

// MARK: View

extension SignInPage: View {
  var body: some View {
    ScrollView {
      VStack(spacing: 40) {
        CustomTextField(
          placeholder: "이메일",
          errorMessage: .none,
          isSecure: false,
          text: $store.emailText,
          isShowText: .constant(false))

        CustomTextField(
          placeholder: "비밀번호",
          errorMessage: .none,
          isSecure: true,
          text: $store.passwordText,
          isShowText: $store.isShowPassword)

        Button(action: { store.send(.onTapSignIn) }) {
          Text("로그인")
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(isActiveSignIn ? 1.0 : 0.3)
        }
        .disabled(!isActiveSignIn)

        HStack {
          Spacer()
          Button(action: {
            store.resetEmailText = ""
            store.isShowResetPassword = true
          }) {
            Text("비밀번호 재설정")
          }

          Spacer()

          Divider()

          Spacer()

          Button(action: {
            store.emailText = ""
            store.passwordText = ""
            store.send(.onTapSignUp)
          }) {
            Text("회원 가입")
          }

          Spacer()
        }
        .padding(.top, 8)

        GoogleSignInButton(
          viewModel: .init(scheme: .dark, style: .wide, state: .normal),
          action: { store.send(.onTapSignInGoogle) })

        Button(action: { store.send(.onTapSignInApple) }) {
          AppleButtonComponent(
            viewState: .init(type: .default, style: .black))
            .frame(height: 50)
        }

        Button(action: {
          store.send(.onTapSignInKakao)
        }) {
          Text("카카오 로그인")
        }
      }
      .padding(.top, 36)
      .padding(.horizontal, 16)
    }
    .background(store.isShowResetPassword ? .gray : .white)
    .disabled(store.isShowResetPassword)
    .overlay(content: {
      if store.isShowResetPassword {
        ResetPasswordComponent(
          viewState: .init(),
          resetEmail: $store.resetEmailText,
          tapAction: { store.send(.onTapResetPassword) },
          cancelAction: { store.isShowResetPassword = false })
      }
    })

    .onAppear { }
    .setRequestFlightView(isLoading: isLoading)
    .onDisappear {
      store.send(.teardown)
    }
  }
}
