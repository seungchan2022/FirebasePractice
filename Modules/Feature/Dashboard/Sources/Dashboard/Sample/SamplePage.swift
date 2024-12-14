import ComposableArchitecture
import SwiftUI

// MARK: - SamplePage

struct SamplePage {
  @Bindable var store: StoreOf<SampleReducer>
}

// MARK: View

extension SamplePage: View {
  var body: some View {
    VStack(spacing: 40) {
      Spacer()
      Text("First Page")

      Button(action: { store.send(.onTapNext) }) {
        Text("Go To Next")
      }
      Spacer()
    }
  }
}
