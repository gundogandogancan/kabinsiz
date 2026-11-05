import Foundation

// V37-07: local stdio MCP server exposing the on-device analyzers to development agents (Claude Code
// project server "kabinsiz", see /.mcp.json). Mac only, no network code, no writes. stdout carries
// only JSON-RPC messages, one per line; diagnostics go to stderr.

/// The repository root: `KABINSIZ_REPO_ROOT` if set, else derived from this file's build-time path
/// (drop `Packages/KabinsizCore/Sources/KabinsizMCP/main.swift`).
func repositoryRoot() -> String {
    if let override = ProcessInfo.processInfo.environment["KABINSIZ_REPO_ROOT"], !override.isEmpty { return override }
    var url = URL(fileURLWithPath: #filePath)
    for _ in 0..<5 { url.deleteLastPathComponent() }
    return url.path
}

func writeLine(_ data: Data, to handle: FileHandle) {
    var out = data
    out.append(0x0A)
    handle.write(out)
}

let repoRoot = repositoryRoot()
guard FileManager.default.fileExists(atPath: repoRoot + "/Packages/KabinsizCore/Package.swift") else {
    writeLine(Data("kabinsiz-mcp: repository root not found at \(repoRoot); set KABINSIZ_REPO_ROOT".utf8), to: .standardError)
    exit(2)
}

let server = MCPServer(context: ToolContext(paths: PathGuard(repoRoot: repoRoot)), tools: ToolTable.all)
writeLine(Data("kabinsiz-mcp \(MCPServer.serverVersion) ready; roots: \(server.context.paths.roots.joined(separator: " "))".utf8), to: .standardError)

/// Reads stdin in chunks and yields lines; a line longer than the cap is dropped while it streams
/// (memory stays bounded) and reported as `nil` so the server can answer "message too large".
struct BoundedLines: AsyncSequence {
    typealias Element = String?
    let limit: Int

    struct AsyncIterator: AsyncIteratorProtocol {
        let limit: Int
        var buffer = Data()
        var overflowing = false
        var pending: [String?] = []
        var finished = false

        mutating func next() async -> String?? {
            while pending.isEmpty {
                if finished { return nil }
                let chunk = FileHandle.standardInput.availableData
                if chunk.isEmpty {
                    finished = true
                    if overflowing { pending.append(nil) } else if !buffer.isEmpty { pending.append(String(decoding: buffer, as: UTF8.self)) }
                    buffer.removeAll()
                    continue
                }
                for byte in chunk {
                    if byte == 0x0A {
                        if overflowing { pending.append(nil) } else { pending.append(String(decoding: buffer, as: UTF8.self)) }
                        buffer.removeAll(keepingCapacity: true)
                        overflowing = false
                    } else if !overflowing {
                        buffer.append(byte)
                        if buffer.count > limit { overflowing = true; buffer.removeAll() }
                    }
                }
            }
            return pending.removeFirst()
        }
    }

    func makeAsyncIterator() -> AsyncIterator { AsyncIterator(limit: limit) }
}

for await line in BoundedLines(limit: MCPServer.maxLineBytes) {
    guard let line else {
        writeLine(MCPServer.error(id: .null, .invalidRequest, "message too large").serialized(), to: .standardOutput)
        continue
    }
    if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
    if let reply = await server.handle(line: line) {
        writeLine(reply.serialized(), to: .standardOutput)
    }
}
