import Domain
import Foundation
import SwiftUI

// MARK: - TodoListDetailPage.ItemComponent

extension TodoListDetailPage {
  struct ItemComponent {
    let viewState: ViewState
    let tapAction: (TodoListEntity.TodoItem.Item) -> Void

    let deleteAction: () -> Void
    let updateAction: () -> Void
    let shareAction: () -> Void
  }
}

extension TodoListDetailPage.ItemComponent { }

// MARK: - TodoListDetailPage.ItemComponent + View

extension TodoListDetailPage.ItemComponent: View {
  var body: some View {
    VStack {
      HStack {
        Button(action: { tapAction(viewState.item) }) {
          Text(viewState.item.title)
            .font(.title)
            .foregroundStyle(.black)

          Spacer()
        }

        Image(systemName: "ellipsis")
          .imageScale(.large)
          .foregroundStyle(.black)
          .background {
            Circle()
              .fill(.clear)
              .frame(width: 30, height: 30)
          }
          .padding(.horizontal, 16)
          .contextMenu {
            Button(action: { updateAction() }) {
              HStack {
                Text("수정")
                Image(systemName: "square.and.pencil")
              }
            }

            Button(action: { shareAction() }) {
              HStack {
                Text("공유")
                Image(systemName: "square.and.arrow.up")
              }
            }

            Button(role: .destructive, action: { deleteAction() }) {
              HStack {
                Text("삭제")
                Image(systemName: "trash")
              }
            }
          }
      }
      .padding(.horizontal, 16)

      Divider()
    }
  }
}

// MARK: - TodoListDetailPage.ItemComponent.ViewState

extension TodoListDetailPage.ItemComponent {
  struct ViewState: Equatable {
    let item: TodoListEntity.TodoItem.Item
  }
}
