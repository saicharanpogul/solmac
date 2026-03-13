import Foundation

@Observable
@MainActor
final class LogManager {
    private(set) var lines: [String] = []
    var hideSlotNoise: Bool = true

    private let logFileURL: URL
    private var fileHandle: FileHandle?
    private let maxLines = 5_000
    private let maxFileSize: UInt64 = 50 * 1024 * 1024 // 50 MB

    /// Patterns that indicate noisy per-slot log lines
    private static let noisePatterns: [String] = [
        "slot ",
        "Slot ",
        "SLOT ",
        "shred ",
        "leader_slot",
        "banking_stage",
        "retransmit_stage",
        "fetch_stage",
        "confirmed_block",
        "optimistically_confirmed",
        "new root",
        "replay_stage-mark_root",
    ]

    init(logFileURL: URL = SolmacConstants.logFile) {
        self.logFileURL = logFileURL
        SolmacConstants.ensureDirectories()
        openFileHandle()
    }

    func append(_ line: String) {
        // Always write to file
        writeToFile(line)

        // Filter noisy lines from in-memory buffer
        if hideSlotNoise && Self.isNoise(line) {
            return
        }

        lines.append(line)
        if lines.count > maxLines {
            lines.removeFirst(lines.count - maxLines)
        }
    }

    func clear() {
        lines.removeAll()
    }

    /// Read lines from a pipe on a background thread and append them
    func startReading(pipe: Pipe) {
        let handle = pipe.fileHandleForReading
        handle.readabilityHandler = { [weak self] fileHandle in
            let data = fileHandle.availableData
            guard !data.isEmpty else {
                fileHandle.readabilityHandler = nil
                return
            }
            if let text = String(data: data, encoding: .utf8) {
                let newLines = text.components(separatedBy: .newlines)
                    .filter { !$0.isEmpty }
                Task { @MainActor [weak self] in
                    for line in newLines {
                        self?.append(line)
                    }
                }
            }
        }
    }

    private static func isNoise(_ line: String) -> Bool {
        for pattern in noisePatterns {
            if line.localizedCaseInsensitiveContains(pattern) {
                return true
            }
        }
        return false
    }

    private func openFileHandle() {
        let fm = FileManager.default
        if !fm.fileExists(atPath: logFileURL.path) {
            fm.createFile(atPath: logFileURL.path, contents: nil)
        }
        fileHandle = try? FileHandle(forWritingTo: logFileURL)
        fileHandle?.seekToEndOfFile()
    }

    private func writeToFile(_ line: String) {
        guard let data = "\(line)\n".data(using: .utf8) else { return }
        fileHandle?.write(data)
        rotateIfNeeded()
    }

    private func rotateIfNeeded() {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: logFileURL.path),
              let size = attrs[.size] as? UInt64,
              size > maxFileSize else { return }

        fileHandle?.closeFile()
        try? FileManager.default.removeItem(at: logFileURL)
        FileManager.default.createFile(atPath: logFileURL.path, contents: nil)
        openFileHandle()
        append("[LOG] Log file rotated (exceeded \(maxFileSize / 1024 / 1024)MB)")
    }
}
