import Domain
import SwiftUI

// MARK: - SelectCategoryPage.ItemComponent

extension SelectCategoryPage {
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

extension SelectCategoryPage.ItemComponent {
  var body: some View {
    Button(action: { tapAction() }) {
      VStack {
        HStack {
          Text(viewState.item.title)
            .font(.title)
            .foregroundStyle(.black)

          trailingItems
        }
        .padding(.horizontal, 12)

        Divider()
      }
    }
  }
}

// MARK: - SelectCategoryPage.ItemComponent.ViewState

extension SelectCategoryPage.ItemComponent {
  struct ViewState: Equatable {
    let item: TodoListEntity.Category.Item
  }
}
