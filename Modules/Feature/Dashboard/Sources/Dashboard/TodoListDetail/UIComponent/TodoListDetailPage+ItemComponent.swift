import Domain
import Foundation
import SwiftUI

// MARK: - TodoListDetailPage.ItemComponent

extension TodoListDetailPage {
  struct ItemComponent {
    let viewState: ViewState
    let tapAction: (TodoListEntity.TodoItem.Item) -> Void

    let updateAction: () -> Void

    let deleteAction: () -> Void
    let editAction: () -> Void
    let shareAction: () -> Void
  }
}

extension TodoListDetailPage.ItemComponent { }

// MARK: - TodoListDetailPage.ItemComponent + View

extension TodoListDetailPage.ItemComponent: View {
  var body: some View {
    VStack {
      HStack(spacing: 12) {
        Button(action: { updateAction() }) {
          if viewState.item.isCompleted ?? false {
            Image(systemName: "checkmark.square")
              .imageScale(.large)
              .foregroundStyle(.black)
              .background {
                Circle()
                  .fill(.clear)
                  .frame(width: 30, height: 30)
              }
          } else {
            Image(systemName: "square")
              .imageScale(.large)
              .foregroundStyle(.black)
              .background {
                Circle()
                  .fill(.clear)
                  .frame(width: 30, height: 30)
              }
          }
        }

        Button(action: { tapAction(viewState.item) }) {
          Text(viewState.item.title)
            .font(.title)
            .foregroundStyle(.black)

          Spacer()
        }

        Circle()
          .fill(.clear)
          .frame(width: 30, height: 30)
          .overlay {
            Image(systemName: "ellipsis")
              .imageScale(.large)
              .foregroundStyle(.black)
              .background {
                Circle()
                  .fill(.clear)
                  .frame(width: 30, height: 30)
              }
          }
          .padding(.horizontal, 16)
          .contextMenu {
            Button(action: { editAction() }) {
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
