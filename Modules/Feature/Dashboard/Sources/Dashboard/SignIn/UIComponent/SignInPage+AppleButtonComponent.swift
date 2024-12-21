import AuthenticationServices
import SwiftUI

// MARK: - SignInPage.AppleButtonComponent

extension SignInPage {
  struct AppleButtonComponent {
    let viewState: ViewState
  }
}

// MARK: - SignInPage.AppleButtonComponent + UIViewRepresentable

extension SignInPage.AppleButtonComponent: UIViewRepresentable {
  func makeUIView(context _: Context) -> ASAuthorizationAppleIDButton {
    ASAuthorizationAppleIDButton(type: viewState.type, style: viewState.style)
  }

  func updateUIView(_: ASAuthorizationAppleIDButton, context _: Context) { }
}

// MARK: - SignInPage.AppleButtonComponent.ViewState

extension SignInPage.AppleButtonComponent {
  struct ViewState: Equatable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
  }
}
