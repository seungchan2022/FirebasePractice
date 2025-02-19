import Foundation

// MARK: - GroupListEntity.Group

extension GroupListEntity {
  public enum Group { }
}

// MARK: - GroupListEntity.Group.Item

extension GroupListEntity.Group {
  public struct Item: Equatable, Codable, Sendable {

    // MARK: Lifecycle

    public init(
      id: String,
      name: String,
      memberList: [String],
      dateCreated: Date = .now)
    {
      self.id = id
      self.name = name
      self.memberList = memberList
      self.dateCreated = dateCreated
    }

    // MARK: Public

    public let id: String // 그룹 ID
    public let name: String // 그룹 이름
    public let memberList: [String] // 그룹에 속한 유저 리스트
    public let dateCreated: Date

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case id
      case name
      case memberList = "member_list"
      case dateCreated = "date_created"
    }
  }
}
