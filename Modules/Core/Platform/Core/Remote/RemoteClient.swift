import Architecture
import Domain
import Foundation

extension Endpoint {
  func fetch<D: Decodable>(
    session: URLSession = .shared,
    isDebug: Bool = false,
    forceIgnoreCache: Bool = false)
    async throws -> D
  {
    let request = try await makeRequest()
    let data = try await session.fetchData(request.apply(ignoreCache: forceIgnoreCache))

    if isDebug {
      Logger.debug(.init(stringLiteral: String(data: data, encoding: .utf8) ?? "nil"))
    }

    return try JSONDecoder().decode(D.self, from: data)
  }

  func fetchData(session: URLSession = .shared) async throws -> Data {
    let request = try await makeRequest()
    return try await session.fetchData(request)
  }
}

extension URLSession {
  fileprivate func fetchData(_ request: URLRequest) async throws -> Data {
    let (data, response) = try await self.data(for: request)

    Logger.debug(.init(stringLiteral: response.url?.absoluteString ?? ""))

    guard let urlResponse = response as? HTTPURLResponse else {
      throw CompositeErrorRepository.invalidTypeCasting
    }

    guard (200...299).contains(urlResponse.statusCode) else {
      if urlResponse.statusCode == 401 {
        throw CompositeErrorRepository.networkUnauthorized
      }

      if let remoteError = try? JSONDecoder().decode(RemoteError.self, from: data) {
        throw CompositeErrorRepository.remoteError(remoteError)
      }

      throw CompositeErrorRepository.networkUnknown
    }

    return data
  }
}

extension Endpoint {
  private func makeRequest() async throws -> URLRequest {
    guard let request else { throw CompositeErrorRepository.invalidTypeCasting }
    return request
  }
}

extension Error {
  private func serialized() -> CompositeErrorRepository {
    guard let error = self as? CompositeErrorRepository else {
      return CompositeErrorRepository.other(self)
    }
    return error
  }
}

extension URLRequest {
  func apply(ignoreCache: Bool) -> URLRequest {
    var new = self
    new.cachePolicy = ignoreCache ? .reloadIgnoringCacheData : .useProtocolCachePolicy
    return new
  }
}
