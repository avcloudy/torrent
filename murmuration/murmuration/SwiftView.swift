import SwiftUI

public let defaultOpacity: CGFloat = 0.35
public let darkOpacity: CGFloat = 0.85

struct SwiftView: View {

  @State private var search: String = ""
  @State public var isControlBarVisible: Bool = false
  @State private var isActive: Bool = true

  var body: some View {
    VStack(spacing: 0) {
      //            TorrentList()
      //                .frame(maxWidth: .infinity)
      //                .safeAreaInset(edge: .top) {
      //                if isControlBarVisible {
      //                    ControlRow()
      //                        .background(.ultraThinMaterial.opacity(0.15))
      //                }
      //            }
      //                .frame(maxWidth: .infinity)
      ZStack(alignment: .top) {
        TorrentList(isControlBarVisible: $isControlBarVisible)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

        if isControlBarVisible {
          ControlRow()
            .id("ControlRow")
            .background(.ultraThinMaterial.opacity(0.15))
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1)
            .padding(.top, 4)
            .animation(.easeInOut, value: isControlBarVisible)
        }
      }
    }
    .frame(maxWidth: .infinity).toolbar(removing: .title)
    .toolbarBackground(.ultraThinMaterial.opacity(0.15), for: .windowToolbar)
    //            .toolbarBackgroundVisibility(.visible, for: .windowToolbar)
    .searchable(text: $search)
    .toolbar {
      ToolbarItemGroup(placement: .automatic) {
        Button("New Torrent", systemImage: "document.badge.plus") {}
        Button("Open Torrent File", systemImage: "folder") {}
        Button("Delete Torrent", systemImage: "circle.slash") {}
        Spacer()
        Toggle("Active", isOn: $isActive).toggleStyle(.switch).controlSize(.regular)
        Spacer()
      }
      ToolbarItemGroup(placement: .primaryAction) {
        Button("Share", systemImage: "pause.circle.fill") {}
        Button("Quick Look", systemImage: "eye") {}
        Button("Inspector", systemImage: "i.circle") {}
        Toggle(
          "Toggle Control Bar",
          systemImage: "chevron.up.chevron.down",
          isOn: Binding(
            get: { isControlBarVisible },
            set: { newValue in
              withAnimation(.easeInOut) {
                isControlBarVisible = newValue
              }
            }
          )
        )
        .onChange(of: isControlBarVisible) {
          withAnimation(.easeInOut(duration: 0.25)) {
          }
        }
        .toggleStyle(.button)
        .accessibilityIdentifier("ControlBarToggle")
        Spacer()

      }
    }
  }
}

#Preview {
  SwiftView()
}
