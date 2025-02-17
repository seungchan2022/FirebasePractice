import Architecture
import Domain
import Foundation

public protocol DashboardSidEffect: Sendable {
  var toastViewModel: ToastViewActionType { get }
  var authUseCase: AuthUseCase { get }
  var userUseCase: UserUseCase { get }
  var productUseCase: ProductUseCase { get }
  var todoListUseCase: TodoListUseCase { get }
  var groupUseCase: GroupUseCase { get }
}
