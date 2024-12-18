import ComposableArchitecture
import SwiftUI

// MARK: - SignInPage.ResetPasswordComponent

extension SignInPage {
  struct ResetPasswordComponent {
    let viewState: ViewState

    let resetEmail: Binding<String>
    let tapAction: () -> Void
  }
}

extension SignInPage.ResetPasswordComponent { }

// MARK: - SignInPage.ResetPasswordComponent + View

extension SignInPage.ResetPasswordComponent: View {
  var body: some View {
    VStack(spacing: 28) {
      VStack(spacing: 8) {
        Text("비밀번호 재설정")
          .font(.title)
          .fontWeight(.bold)
        Text("계정과 연결된 이메일 주소를 입력하면, 비밀번호 재설정 링크가 해당 이메일로 전송됩니다.")
          .fixedSize(horizontal: false, vertical: true)
          .foregroundStyle(.secondary)
      }
      .multilineTextAlignment(.center)

      TextField("이메일", text: resetEmail)
        .padding(.leading)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(.gray.opacity(0.1))
        .clipShape(.rect(cornerRadius: 16))
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)

      Button(action: { tapAction() }) {
        Text("재설정 링크 전송")
          .foregroundStyle(.white)
          .frame(height: 50)
          .frame(maxWidth: .infinity)
          .background(.blue)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .opacity(resetEmail.wrappedValue.isEmpty ? 0.3 : 1.0)
      }
      .disabled(resetEmail.wrappedValue.isEmpty)
      Spacer()
    }
    .padding()
    .padding(.top, 20)
  }
}

// MARK: - SignInPage.ResetPasswordComponent.ViewState

extension SignInPage.ResetPasswordComponent {
  struct ViewState: Equatable { }
}
