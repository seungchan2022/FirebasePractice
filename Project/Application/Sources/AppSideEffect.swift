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
  let productUseCase: ProductUseCase
  let todoListUseCase: TodoListUseCase
}
