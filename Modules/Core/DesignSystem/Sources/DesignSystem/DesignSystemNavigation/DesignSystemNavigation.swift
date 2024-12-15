import SwiftUI

// MARK: - DesignSystemNavigation

public struct DesignSystemNavigation<Content: View> {
  let barItem: DesignSystemNavigationBar?
  let largeTitle: String?
  let isShowDivider: Bool?
  let content: Content

  @State private var showInlineTitle = false

  public init(
    barItem: DesignSystemNavigationBar? = .none,
    largeTitle: String? = .none,
    isShowDivider: Bool? = .none,
    @ViewBuilder content: @escaping () -> Content)
  {
    self.barItem = barItem
    self.largeTitle = largeTitle
    self.isShowDivider = isShowDivider
    self.content = content()
  }
}

extension DesignSystemNavigation {
  var titleTopMargin: Double {
    barItem == nil ? 40 : .zero
  }
}

// MARK: View

extension DesignSystemNavigation: View {
  public var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      if let barItem {
        barItem
          .overlay(alignment: .bottom) {
            VStack(spacing: .zero) {
              if showInlineTitle, let largeTitle {
                VStack(spacing: .zero) {
                  Text(largeTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showInlineTitle)
                    .padding(.bottom, 6)

                  Divider()
                }
              }

              if isShowDivider == true {
                Divider()
              }
            }
          }
      }

      ScrollView {
        GeometryReader { geometry in
          Color.clear
            .onAppear {
              showInlineTitle = geometry.frame(in: .global).minY < 50
            }
            .onChange(of: geometry.frame(in: .global).minY) { _, new in
              showInlineTitle = new < 50
            }
        }
        .frame(height: 0)

        if let largeTitle {
          Text(largeTitle)
            .font(.system(size: 30, weight: .bold, design: .default))
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        content
          .padding(.top, 8)
      }
    }
    .frame(minWidth: .zero, maxWidth: .infinity)
    .frame(minHeight: .zero, maxHeight: .infinity)
  }
}
