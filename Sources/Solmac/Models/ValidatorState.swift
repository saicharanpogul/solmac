import SwiftUI

enum ValidatorState: Equatable {
    case stopped
    case prefetching(progress: String)
    case starting
    case running(pid: Int32)
    case stopping
    case error(message: String)

    var isRunning: Bool {
        if case .running = self { return true }
        return false
    }

    var canStart: Bool {
        switch self {
        case .stopped, .error: true
        default: false
        }
    }

    var canStop: Bool {
        isRunning
    }

    var statusText: String {
        switch self {
        case .stopped: "Stopped"
        case .prefetching(let p): "Pre-fetching: \(p)"
        case .starting: "Starting..."
        case .running(let pid): "Running (PID \(pid))"
        case .stopping: "Stopping..."
        case .error(let msg): "Error: \(msg)"
        }
    }

    var iconName: String {
        switch self {
        case .running: "circle.fill"
        case .stopped: "circle"
        case .error: "exclamationmark.circle.fill"
        default: "circle.dotted"
        }
    }

    var iconColor: Color {
        switch self {
        case .running: .green
        case .error: .red
        case .stopped: .gray
        default: .orange
        }
    }
}
