import Domain
import SwiftUI

// MARK: - NewGroupPage.ItemComponent

extension NewGroupPage {
  struct ItemComponent<Content: View>: View {
    let viewState: ViewState
    let tapAction: () -> Void

    private let trailingItems: Content

    init(
      viewState: ViewState,
      tapAction: @escaping () -> Void,
      @ViewBuilder trailingItems: () -> Content = { EmptyView() })
    {
      self.viewState = viewState
      self.tapAction = tapAction
      self.trailingItems = trailingItems()
    }
  }
}

extension NewGroupPage.ItemComponent {
  var body: some View {
    Button(action: { tapAction() }) {
      VStack {
        HStack {
          Circle()
            .frame(width: 40, height: 40)

          VStack(alignment: .leading) {
            Text(viewState.user.userName ?? "")
              .bold()
              .foregroundStyle(.black)

            Text(viewState.user.email ?? "")
              .font(.caption)
              .foregroundStyle(.gray)
          }

          trailingItems
        }
        .padding(.horizontal, 12)

        Divider()
          .padding(.leading, 64)
      }
    }
  }
}

// MARK: - NewGroupPage.ItemComponent.ViewState

extension NewGroupPage.ItemComponent {
  struct ViewState: Equatable {
    let user: UserEntity.User.Response
  }
}
