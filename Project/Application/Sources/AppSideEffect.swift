import Architecture
import Dashboard
import Domain
import Foundation
import LinkNavigator
import Platform

// MARK: - AppSideEffect

struct AppSideEffect: DependencyType {
  let sampleUseCase: SampleUseCase
}

extension AppSideEffect {
  static func generate() -> AppSideEffect {
    .init(sampleUseCase: SampleUseCasePlatform())
  }
}
