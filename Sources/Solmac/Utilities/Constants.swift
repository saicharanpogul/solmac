import Foundation

enum SolmacConstants {
    static let configDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/solmac")
    static let configFile = configDir.appendingPathComponent("config.json")
    static let logDir = configDir.appendingPathComponent("logs")
    static let logFile = logDir.appendingPathComponent("validator.log")
    static let cacheDir = configDir.appendingPathComponent("cache")
    static let accountsCacheDir = cacheDir.appendingPathComponent("accounts")
    static let programsCacheDir = cacheDir.appendingPathComponent("programs")

    static let profilesDir = configDir.appendingPathComponent("profiles")

    static let allDirectories: [URL] = [
        configDir, logDir, cacheDir, accountsCacheDir, programsCacheDir, profilesDir
    ]

    static func ensureDirectories() {
        let fm = FileManager.default
        for dir in allDirectories {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }
}
