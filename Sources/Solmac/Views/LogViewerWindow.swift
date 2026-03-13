import SwiftUI

struct LogViewerWindow: View {
    @Environment(LogManager.self) private var logManager
    @State private var autoScroll = true
    @State private var searchText = ""

    private var filteredLines: [String] {
        if searchText.isEmpty { return logManager.lines }
        return logManager.lines.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        @Bindable var lm = logManager

        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Filter logs...", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                Toggle("Hide Slot Noise", isOn: $lm.hideSlotNoise)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .help("Hide repetitive per-slot log lines from the viewer (still written to file)")

                Toggle("Auto-scroll", isOn: $autoScroll)
                    .toggleStyle(.switch)
                    .controlSize(.small)

                Button("Clear") {
                    logManager.clear()
                }

                Button {
                    NSWorkspace.shared.open(SolmacConstants.logFile)
                } label: {
                    Image(systemName: "doc.text")
                }
                .help("Open full log file (includes all lines)")
            }
            .padding(8)

            Divider()

            // Log content
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(filteredLines.enumerated()), id: \.offset) { i, line in
                            Text(line)
                                .font(.system(size: 11, design: .monospaced))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 1)
                                .background(i % 2 == 0 ? Color.clear : Color.primary.opacity(0.03))
                                .id(i)
                        }
                    }
                }
                .onChange(of: logManager.lines.count) {
                    if autoScroll, let last = filteredLines.indices.last {
                        withAnimation {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }

            // Status bar
            HStack {
                Text("\(logManager.lines.count) lines in viewer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if logManager.hideSlotNoise {
                    Text("(slot noise hidden)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.bar)
        }
    }
}
