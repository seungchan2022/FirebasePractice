import Architecture
import Dashboard
import Domain
import Foundation
import LinkNavigator
import Platform

// MARK: - AppSideEffect

struct AppSideEffect: DependencyType, DashboardSidEffect {
  let toastViewModel: ToastViewActionType
  let sampleUseCase: SampleUseCase
}

extension AppSideEffect {
  static func generate() -> AppSideEffect {
    .init(
      toastViewModel: ToastViewModel(),
      sampleUseCase: SampleUseCasePlatform())
  }
}
