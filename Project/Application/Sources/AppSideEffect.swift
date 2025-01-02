import Architecture
import Dashboard
import Domain
import Foundation
import LinkNavigator
import Platform

// MARK: - AppSideEffect

struct AppSideEffect: DependencyType, DashboardSidEffect {
  let toastViewModel: ToastViewActionType
  let authUseCase: AuthUseCase
  let userUseCase: UserUseCase
}

extension AppSideEffect {
  static func generate() -> AppSideEffect {
    .init(
      toastViewModel: ToastViewModel(),
      authUseCase: AuthUseCasePlatform(),
      userUseCase: UserUseCasePlatform())
  }
}
