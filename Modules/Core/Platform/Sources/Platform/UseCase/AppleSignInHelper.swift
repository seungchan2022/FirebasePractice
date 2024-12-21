import Foundation
import AuthenticationServices
import CryptoKit
import Domain

@MainActor
final class AppleAuthHelper: NSObject,  ASAuthorizationControllerPresentationContextProviding {

  fileprivate var currentNonce: String?
  private var completionHandler: ((Result<AuthEntity.Apple.Response, CompositeErrorRepository>) -> Void)? = .none

  // MARK: ASAuthorizationControllerPresentationContextProviding
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

    return UIApplication.shared.firstKeyWindow ?? UIWindow()
  }

  func startSignInWithAppleFlow() async throws ->  AuthEntity.Apple.Response {
    try await withCheckedThrowingContinuation { continuation in
      startSignInWithAppleFlow { result in
        switch result {
        case .success(let signInAppleResult):
          continuation.resume(returning: signInAppleResult)
          return
        case .failure(let error):
          continuation.resume(throwing: error)
          return
        }
      }
    }
  }

  func startSignInWithAppleFlow(completion: @escaping (Result<AuthEntity.Apple.Response, CompositeErrorRepository>) -> Void) {

    let nonce = randomNonceString()
    currentNonce = nonce
    completionHandler = completion

    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }

  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
      fatalError(
        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
      )
    }

    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

    let nonce = randomBytes.map { byte in
      charset[Int(byte) % charset.count]
    }

    return String(nonce)
  }


  @available(iOS 13, *)
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()

    return hashString
  }

}


extension AppleAuthHelper: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

    guard
      let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
      let nonce = currentNonce,
      let appleIDToken = appleIDCredential.identityToken,
      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
      completionHandler?(.failure(.invalidTypeCasting))
      return
    }

    let name = appleIDCredential.fullName?.givenName

    let tokens = AuthEntity.Apple.Response(token: idTokenString, nonce: nonce, name: name)

    completionHandler?(.success(tokens))
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    completionHandler?(.failure(.other(error)))
  }

}


extension UIApplication {
  fileprivate var firstKeyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .filter { $0.activationState == .foregroundActive }
      .first?.windows
      .first(where: \.isKeyWindow)
  }
}

