import Foundation

// MARK: - GroupEntity.Group

extension GroupEntity {
  public enum Group { }
}

// MARK: - GroupEntity.Group.Item

extension GroupEntity.Group {
  public struct Item: Equatable, Codable, Sendable {
    public let id: String // 그룹 ID
    public let name: String // 그룹 이름
    public let memberList: [String] // 그룹에 속한 유저 리스트

    public init(
      id: String = UUID().uuidString,
      name: String,
      memberList: [String])
    {
      self.id = id
      self.name = name
      self.memberList = memberList
    }

    private enum CodingKeys: String, CodingKey {
      case id
      case name
      case memberList = "member_list"
    }
  }
}
