import ComposableArchitecture
import SwiftUI

// MARK: - SignUpPage

struct SignUpPage {
  @Bindable var store: StoreOf<SignUpReducer>
}

extension SignUpPage {
  @MainActor
  private var isActiveSignUp: Bool {
    !store.emailText.isEmpty && !store.passwordText.isEmpty
  }
}

// MARK: View

extension SignUpPage: View {
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

        Button(action: { }) {
          Text("회원 가입")
            .foregroundStyle(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(isActiveSignUp ? 1.0 : 0.3)
        }
        .disabled(!isActiveSignUp)
      }
      .padding(.top, 36)
      .padding(.horizontal, 16)
    }
    .onAppear { }
  }
}
