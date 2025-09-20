import Foundation
import Yams

public enum ConfigError: Error, LocalizedError {
    case fileNotFound(URL)
    case decodingFailed(String)

    public var errorDescription: String? {
        switch self {
        case let .fileNotFound(url):
            return "Configuration file not found at \(url.path)"
        case let .decodingFailed(message):
            return "Failed to decode configuration: \(message)"
        }
    }
}

private struct RawConfig: Decodable {
    let host: String
    let user: String
    let identity_file: String?
    let local_dir: String
    let remote_dir: String
    let build_command: [String]
    let poll_interval: Double?
}

public enum ConfigLoader {
    public static func load(from url: URL) throws -> WorkspaceConfig {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ConfigError.fileNotFound(url)
        }

        let data = try Data(contentsOf: url)
        let decoder = YAMLDecoder()
        let raw: RawConfig
        do {
            raw = try decoder.decode(RawConfig.self, from: data)
        } catch {
            throw ConfigError.decodingFailed(error.localizedDescription)
        }

        let baseURL = url.deletingLastPathComponent()
        let projectPath = URL(fileURLWithPath: raw.local_dir, relativeTo: baseURL).standardizedFileURL
        return WorkspaceConfig(
            projectPath: projectPath,
            remoteHost: raw.host,
            remoteUser: raw.user,
            remotePath: raw.remote_dir,
            identityFile: raw.identity_file,
            pollInterval: raw.poll_interval ?? 3.0,
            buildCommands: raw.build_command
        )
    }
}
