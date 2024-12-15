import Architecture
import Domain
import Foundation

public protocol DashboardSidEffect {
  var toastViewModel: ToastViewActionType { get }
  var sampleUseCase: SampleUseCase { get }
}
