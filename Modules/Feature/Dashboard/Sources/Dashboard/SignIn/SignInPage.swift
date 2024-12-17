import ComposableArchitecture
import DesignSystem
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
}

// MARK: View

extension SignInPage: View {
  var body: some View {
    ScrollView {
      VStack(spacing: 40) {
        TextFieldComponent(
          viewState: .init(),
          text: $store.emailText,
          isShowText: .constant(false),
          placeholder: "이메일",
          isSecure: false)

        TextFieldComponent(
          viewState: .init(),
          text: $store.passwordText,
          isShowText: $store.isShowPassword,
          placeholder: "비밀번호",
          isSecure: true)

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
          Button(action: { }) {
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
      }
      .padding(.top, 36)
      .padding(.horizontal, 16)
    }
    .onAppear { }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
