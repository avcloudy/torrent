import AppKit
import SwiftUI

//private let controlBarHeight: CGFloat = 10
//private let defaultOpacity: CGFloat = 0.3
//private let darkOpacity: CGFloat = 0.85

// a way to access an NSWindow's internal properties
struct WindowAccessor: NSViewRepresentable {
  let callback: (NSWindow) -> Void

  func makeNSView(context: Context) -> NSView {
    let view = NSView()
    DispatchQueue.main.async {
      if let window = view.window {
        callback(window)
      }
    }
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {}
}

struct ContentView: View {

  @State private var searchText: String = ""
  @State private var selectedTorrent: Int?
  @State private var isControlBarVisible: Bool = false
  @State private var isActive: Bool = false

  var body: some View {
    ZStack(alignment: .top) {
      HostingScrollView {
        VStack(spacing: 0) {
          //          TorrentList(selectedTorrent: $selectedTorrent)
          //            .offset(y: isControlBarVisible ? controlBarHeight + 5 : 0)
          //            .animation(.easeInOut, value: isControlBarVisible)
        }
      }
      .ignoresSafeArea(edges: .top)
      if isControlBarVisible {
        ControlRow()
          .frame(height: controlBarHeight)
          // unnecessary duplication
          //                    .background(.ultraThinMaterial.opacity(defaultOpacity))
          .frame(maxWidth: .infinity)
          .transition(.move(edge: .top).combined(with: .opacity))
          .zIndex(1)
          .accessibilityIdentifier("ControlBarIdentifier")
      }
    }
    .background(
      WindowAccessor { window in
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.title = ""
      }
    )
    // attached to topmost Stack
    .toolbarBackground(.ultraThinMaterial.opacity(defaultOpacity), for: .windowToolbar)
    .toolbarBackgroundVisibility(.visible, for: .windowToolbar)
    .searchable(text: $searchText)
    .toolbar(removing: .title)
    .toolbar {
      ToolbarItemGroup(placement: .automatic) {
        Button("New Torrent", systemImage: "document.badge.plus") {}
        Button("Open Torrent File", systemImage: "folder") {}
        Button("Delete Torrent", systemImage: "circle.slash") {}
        Spacer()
        Toggle("Active", isOn: $isActive).toggleStyle(.switch).controlSize(.regular)
        // old pause/resume buttons, replaced by toggle
        //                ControlGroup {
        //                    Button("Pause All", systemImage: "pause") {}
        //                    Button("Resume All", systemImage: "play") {}
        //                }.controlGroupStyle(.automatic)
        Spacer()
      }
      ToolbarItemGroup(placement: .primaryAction) {
        Button("Share", systemImage: "pause.circle.fill") {}
        Button("Quick Look", systemImage: "eye") {}
        Button("Inspector", systemImage: "i.circle") {}
        Toggle(
          "Toggle Control Bar",
          systemImage: "chevron.up.chevron.down",
          isOn: $isControlBarVisible
        )
        .toggleStyle(.button)
        .accessibilityIdentifier("ControlBarToggle")
        Spacer()
      }
    }

  }
}
