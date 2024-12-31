import ComposableArchitecture
import DesignSystem
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

  @MainActor
  private var isLoading: Bool {
    store.fetchSignUp.isLoading
  }
}

// MARK: View

extension SignUpPage: View {
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

        Button(action: { store.send(.onTapSignUp) }) {
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
    .setRequestFlightView(isLoading: isLoading)
    .onAppear { }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
