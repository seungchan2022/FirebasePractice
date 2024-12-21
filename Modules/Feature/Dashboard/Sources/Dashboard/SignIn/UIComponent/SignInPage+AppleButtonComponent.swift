import SwiftUI
import AuthenticationServices

extension SignInPage {
  struct AppleButtonComponent {
    let viewState: ViewState
  }
}

extension SignInPage.AppleButtonComponent: UIViewRepresentable {
  func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
    return ASAuthorizationAppleIDButton(type: viewState.type, style: viewState.style)
  }

  func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {

  }
}

extension SignInPage.AppleButtonComponent {
  struct ViewState: Equatable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
  }
}
