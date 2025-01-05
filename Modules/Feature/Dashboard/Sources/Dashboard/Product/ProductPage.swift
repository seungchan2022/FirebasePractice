import ComposableArchitecture
import SwiftUI

// MARK: - ProductPage

struct ProductPage {
  @Bindable var store: StoreOf<ProductReducer>
}

// MARK: View

extension ProductPage: View {
  var body: some View {
    VStack {
      Text("Product Page")
    }
    .onAppear {
      store.send(.downloadItem)
    }
  }
}
