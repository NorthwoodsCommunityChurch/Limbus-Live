import SwiftUI

struct MenuBarView: View {
    let tslListener: TSLListener
    @State private var settings = AppSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Screen Tally")
                    .font(.headline)
                Spacer()
                connectionIndicator
            }

            Divider()

            // Connection Status
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Status:")
                        .foregroundStyle(.secondary)
                    Text(statusText)
                        .foregroundStyle(statusColor)
                }

                if tslListener.isConnected, let peer = tslListener.connectedPeer {
                    Text("Connected: \(peer)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let error = tslListener.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Divider()

            // Current Tally Display
            if settings.monitoredSourceIndex != nil {
                HStack {
                    Text("Tally:")
                        .foregroundStyle(.secondary)
                    Text(tslListener.monitoredTally.label)
                        .foregroundStyle(tslListener.monitoredTally.swiftUIColor)
                        .fontWeight(.semibold)
                }
            }

            // Source Picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Monitor Source:")
                    .foregroundStyle(.secondary)

                Picker("Source", selection: Binding(
                    get: { settings.monitoredSourceIndex ?? -1 },
                    set: { settings.monitoredSourceIndex = $0 == -1 ? nil : $0 }
                )) {
                    Text("None").tag(-1)
                    ForEach(tslListener.sortedSources) { source in
                        HStack {
                            Text(source.displayName)
                            if source.tally != .clear {
                                Circle()
                                    .fill(source.tally.swiftUIColor)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .tag(source.index)
                    }
                }
                .labelsHidden()

                if tslListener.sortedSources.isEmpty && tslListener.isConnected {
                    Text("Waiting for tally data...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !tslListener.isConnected {
                    Text("Connect to see available sources")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Port Configuration
            HStack {
                Text("Port:")
                    .foregroundStyle(.secondary)
                TextField("Port", value: $settings.port, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                Button("Restart") {
                    tslListener.restart()
                }
                .buttonStyle(.bordered)
            }

            Divider()

            // Quick Settings
            Toggle("Show border on Preview", isOn: $settings.showBorderOnPreview)
                .toggleStyle(.checkbox)

            HStack {
                Text("Border thickness:")
                    .foregroundStyle(.secondary)
                Picker("", selection: $settings.borderThickness) {
                    Text("4pt").tag(4)
                    Text("8pt").tag(8)
                    Text("12pt").tag(12)
                    Text("16pt").tag(16)
                }
                .labelsHidden()
                .frame(width: 80)
            }

            // Screen Picker
            HStack {
                Text("Display:")
                    .foregroundStyle(.secondary)
                Picker("", selection: $settings.selectedScreenIndex) {
                    ForEach(Array(NSScreen.screens.enumerated()), id: \.offset) { index, screen in
                        Text(screenName(for: screen, index: index)).tag(index)
                    }
                }
                .labelsHidden()
            }

            Divider()

            // Debug Controls
            VStack(alignment: .leading, spacing: 8) {
                Text("Debug")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Button {
                        settings.debugTallyOverride = .program
                    } label: {
                        Text("Red")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                    Button {
                        settings.debugTallyOverride = .preview
                    } label: {
                        Text("Green")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button {
                        settings.debugTallyOverride = nil
                    } label: {
                        Text("Clear")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if settings.debugTallyOverride != nil {
                    Text("Debug override active")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
        .frame(width: 280)
    }

    private var connectionIndicator: some View {
        Circle()
            .fill(tslListener.isConnected ? Color.green : (tslListener.isListening ? Color.yellow : Color.red))
            .frame(width: 10, height: 10)
    }

    private var statusText: String {
        if tslListener.isConnected {
            return "Connected"
        } else if tslListener.isListening {
            return "Listening..."
        } else {
            return "Not listening"
        }
    }

    private var statusColor: Color {
        if tslListener.isConnected {
            return .green
        } else if tslListener.isListening {
            return .yellow
        } else {
            return .red
        }
    }

    private func screenName(for screen: NSScreen, index: Int) -> String {
        let name = screen.localizedName
        let isMain = screen == NSScreen.main
        if isMain {
            return "\(name) (Main)"
        }
        return name
    }
}
