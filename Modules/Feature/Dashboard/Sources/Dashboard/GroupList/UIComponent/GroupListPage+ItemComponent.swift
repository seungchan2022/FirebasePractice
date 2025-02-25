import Domain
import Foundation
import SwiftUI

// MARK: - GroupListPage.ItemComponent

extension GroupListPage {
  struct ItemComponent {
    let viewState: ViewState
    let tapAction: (GroupListEntity.Group.Item) -> Void
  }
}

extension GroupListPage.ItemComponent { }

// MARK: - GroupListPage.ItemComponent + View

extension GroupListPage.ItemComponent: View {
  var body: some View {
    VStack {
      HStack {
        Button(action: { tapAction(viewState.item) }) {
          Text(viewState.item.name)
            .font(.title)
            .foregroundStyle(.black)

          Spacer()
        }

//        Circle()
//          .fill(.clear)
//          .frame(width: 30, height: 30)
//          .overlay {
//            Image(systemName: "ellipsis")
//              .imageScale(.large)
//              .foregroundStyle(.black)
//              .background {
//                Circle()
//                  .fill(.clear)
//                  .frame(width: 30, height: 30)
//              }
//          }
//          .padding(.horizontal, 16)
//          .contextMenu {
//            Button(action: { editAction() }) {
//              HStack {
//                Text("수정")
//                Image(systemName: "square.and.pencil")
//              }
//            }
//
//            Button(action: { shareAction() }) {
//              HStack {
//                Text("공유")
//                Image(systemName: "square.and.arrow.up")
//              }
//            }
//
//            Button(role: .destructive, action: { deleteAction(viewState.item) }) {
//              HStack {
//                Text("삭제")
//                Image(systemName: "trash")
//              }
//            }
//          }
      }
      .padding(.horizontal, 16)

      Divider()
    }
  }
}

// MARK: - GroupListPage.ItemComponent.ViewState

extension GroupListPage.ItemComponent {
  struct ViewState: Equatable {
    let item: GroupListEntity.Group.Item
  }
}
