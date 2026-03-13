import Foundation

@Observable
@MainActor
final class ConfigManager {
    var config: SolmacConfig {
        didSet { scheduleSave() }
    }

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var saveTask: Task<Void, Never>?

    init(fileURL: URL = SolmacConstants.configFile) {
        self.fileURL = fileURL
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.decoder = JSONDecoder()
        self.config = .default

        SolmacConstants.ensureDirectories()
        load()
    }

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            config = try decoder.decode(SolmacConfig.self, from: data)
        } catch {
            print("[ConfigManager] Failed to load config: \(error)")
        }
    }

    func save() {
        do {
            let data = try encoder.encode(config)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[ConfigManager] Failed to save config: \(error)")
        }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            save()
        }
    }

    // MARK: - Programs

    func addProgram(_ program: CloneableProgram) {
        config.programs.append(program)
    }

    func removeProgram(id: UUID) {
        config.programs.removeAll { $0.id == id }
    }

    func updateProgram(_ program: CloneableProgram) {
        if let idx = config.programs.firstIndex(where: { $0.id == program.id }) {
            config.programs[idx] = program
        }
    }

    // MARK: - Accounts

    func addAccount(_ account: CloneableAccount) {
        config.accounts.append(account)
    }

    func removeAccount(id: UUID) {
        config.accounts.removeAll { $0.id == id }
    }

    func updateAccount(_ account: CloneableAccount) {
        if let idx = config.accounts.firstIndex(where: { $0.id == account.id }) {
            config.accounts[idx] = account
        }
    }
}
