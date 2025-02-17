import Foundation

// MARK: - Link.Dashboard

extension Link {
  public enum Dashboard { }
}

// MARK: - Link.Dashboard.Path

extension Link.Dashboard {
  public enum Path: String, Equatable {
    case profile
    case signIn
    case signUp
    case product
    case favorite
    case todoList
    case todoListDetail
    case todo
    case group
  }
}
