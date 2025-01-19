import Combine
import Foundation

public protocol UserUseCase: Sendable {
  var getUser: (String) async throws -> UserEntity.User.Response { get }

  var updateUserStatus: (String, Bool) async throws -> UserEntity.User.Response { get }

  var addWishItem: (String, String) async throws -> UserEntity.User.Response { get }

  var removeWishItem: (String, String) async throws -> UserEntity.User.Response { get }

  var addMovie: (String, UserEntity.Movie.Item) async throws -> UserEntity.User.Response { get }

  var removeMovieItem: (String) async throws -> UserEntity.User.Response { get }

  var addFavoriteProduct: (Int) async throws -> Bool { get }

  var removeFavoriteProduct: (String) async throws -> Bool { get }

  var getFavoriteProduct: () async throws -> [UserEntity.Favorite.Item] { get }

  var addListenerForAllUserFavoriteProducts: () -> AnyPublisher<[UserEntity.Favorite.Item], CompositeErrorRepository> { get }

}
