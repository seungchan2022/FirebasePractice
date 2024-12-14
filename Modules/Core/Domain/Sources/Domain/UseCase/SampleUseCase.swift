import Foundation

public protocol SampleUseCase {
  var fire: () async -> SampleEntity { get }
}
