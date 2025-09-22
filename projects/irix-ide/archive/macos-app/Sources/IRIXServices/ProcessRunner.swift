import Foundation

struct ProcessResult {
    let exitCode: Int32
}

enum ProcessError: Error, LocalizedError {
    case launchFailed(String)
    case nonZeroExit(code: Int32)

    var errorDescription: String? {
        switch self {
        case let .launchFailed(message):
            return "Failed to launch process: \(message)"
        case let .nonZeroExit(code):
            return "Process exited with code \(code)"
        }
    }
}

struct ProcessRunner {
    @discardableResult
    static func run(command: [String], workingDirectory: URL? = nil) throws -> ProcessResult {
        guard !command.isEmpty else {
            throw ProcessError.launchFailed("Empty command")
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = command
        if let workingDirectory {
            process.currentDirectoryURL = workingDirectory
        }

        try process.run()
        process.waitUntilExit()
        let status = process.terminationStatus
        if status != 0 {
            throw ProcessError.nonZeroExit(code: status)
        }
        return ProcessResult(exitCode: status)
    }

    static func streamLines(command: [String], workingDirectory: URL? = nil) throws -> AsyncThrowingStream<String, Error> {
        guard !command.isEmpty else {
            throw ProcessError.launchFailed("Empty command")
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = command
        if let workingDirectory {
            process.currentDirectoryURL = workingDirectory
        }

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        let handle = pipe.fileHandleForReading

        return AsyncThrowingStream { continuation in
            Task.detached {
                do {
                    for try await line in handle.bytes.lines {
                        continuation.yield(String(line))
                    }
                    handle.closeFile()
                    process.waitUntilExit()
                    let status = process.terminationStatus
                    if status == 0 {
                        continuation.finish()
                    } else {
                        continuation.finish(throwing: ProcessError.nonZeroExit(code: status))
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
