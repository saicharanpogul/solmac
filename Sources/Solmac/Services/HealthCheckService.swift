import Foundation

struct ValidatorHealth: Sendable {
    var slotHeight: UInt64 = 0
    var tps: Double = 0
    var uptime: TimeInterval = 0
    var isHealthy: Bool = false
}

@Observable
@MainActor
final class HealthCheckService {
    private(set) var health = ValidatorHealth()
    private var pollTask: Task<Void, Never>?
    private var startTime: Date?
    private var lastSlot: UInt64 = 0
    private var lastSlotTime: Date?

    var uptimeFormatted: String {
        let seconds = Int(health.uptime)
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%dh %02dm %02ds", h, m, s)
        } else if m > 0 {
            return String(format: "%dm %02ds", m, s)
        }
        return "\(s)s"
    }

    func startPolling(rpcPort: Int) {
        stopPolling()
        startTime = Date()
        pollTask = Task { @MainActor in
            while !Task.isCancelled {
                await poll(rpcPort: rpcPort)
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
        health = ValidatorHealth()
        startTime = nil
        lastSlot = 0
        lastSlotTime = nil
    }

    private func poll(rpcPort: Int) async {
        let url = URL(string: "http://127.0.0.1:\(rpcPort)")!

        // Get slot height
        if let slot = await rpcCall(url: url, method: "getSlot") {
            let now = Date()
            if let prevTime = lastSlotTime, lastSlot > 0 && slot > lastSlot {
                let elapsed = now.timeIntervalSince(prevTime)
                if elapsed > 0 {
                    health.tps = Double(slot - lastSlot) / elapsed
                }
            }
            lastSlot = slot
            lastSlotTime = now
            health.slotHeight = slot
            health.isHealthy = true
        } else {
            health.isHealthy = false
        }

        if let start = startTime {
            health.uptime = Date().timeIntervalSince(start)
        }
    }

    private func rpcCall(url: URL, method: String) async -> UInt64? {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = """
        {"jsonrpc":"2.0","id":1,"method":"\(method)"}
        """.data(using: .utf8)
        request.timeoutInterval = 3

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = json["result"] as? UInt64 {
                return result
            }
            // Try Int first then convert
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = json["result"] as? Int {
                return UInt64(result)
            }
        } catch {}
        return nil
    }
}
