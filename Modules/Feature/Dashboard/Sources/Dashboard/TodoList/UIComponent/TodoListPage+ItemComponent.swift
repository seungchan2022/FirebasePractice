import Domain
import Foundation
import SwiftUI

// MARK: - TodoListPage.ItemComponent

extension TodoListPage {
  struct ItemComponent {
    let viewState: ViewState
    let tapAction: (TodoListEntity.Category.Item) -> Void

    let deleteAction: () -> Void
    let editAction: () -> Void
    let shareAction: () -> Void
  }
}

extension TodoListPage.ItemComponent { }

// MARK: - TodoListPage.ItemComponent + View

extension TodoListPage.ItemComponent: View {
  var body: some View {
    VStack {
      HStack {
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

// MARK: - TodoListPage.ItemComponent.ViewState

extension TodoListPage.ItemComponent {
  struct ViewState: Equatable {
    let item: TodoListEntity.Category.Item
  }
}
