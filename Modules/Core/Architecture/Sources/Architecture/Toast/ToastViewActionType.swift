import Foundation

public protocol ToastViewActionType: Sendable {
  func send(message: String)
  func send(errorMessage: String)
  func clear()
}
