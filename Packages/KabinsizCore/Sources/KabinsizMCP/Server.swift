import Foundation

/// Minimal MCP server (protocol revision 2025-06-18) over newline-delimited JSON-RPC 2.0 on stdio.
/// Methods: `initialize`, `notifications/initialized`, `ping`, `tools/list`, `tools/call`. No
/// resources, prompts or sampling. Stateless apart from the handshake flag.
struct MCPServer: Sendable {
    static let protocolVersion = "2025-06-18"
    static let serverName = "kabinsiz-mcp"
    static let serverVersion = "0.1.0"
    /// One line is one message; a longer line is refused instead of buffered without bound.
    static let maxLineBytes = 1 * 1024 * 1024

    enum ErrorCode: Int {
        case parseError = -32700, invalidRequest = -32600, methodNotFound = -32601, invalidParams = -32602, internalError = -32603
    }

    let context: ToolContext
    let tools: [MCPTool]

    /// Handles one input line. Returns the response line, or nil for a notification.
    func handle(line: String) async -> JSONValue? {
        guard line.utf8.count <= Self.maxLineBytes else { return Self.error(id: .null, .invalidRequest, "message too large") }
        let message: JSONValue
        do { message = try JSONValue.parse(Data(line.utf8)) } catch {
            return Self.error(id: .null, .parseError, "Parse error")
        }
        // 2025-06-18 removed JSON-RPC batching; arrays are not requests.
        guard case .object(let object) = message else { return Self.error(id: .null, .invalidRequest, "Invalid Request") }
        let id = object["id"]
        if let id {
            switch id {
            case .string, .number: break
            default: return Self.error(id: .null, .invalidRequest, "id must be a string or a number")
            }
        }
        guard object["jsonrpc"] == .string("2.0"), let method = object["method"]?.stringValue else {
            // A response sent to us, or garbage. Responses (result/error with id) are ignored silently.
            if object["result"] != nil || object["error"] != nil { return nil }
            return Self.error(id: id ?? .null, .invalidRequest, "Invalid Request")
        }
        let params = object["params"]
        if let params, params.objectValue == nil {
            return id.map { Self.error(id: $0, .invalidParams, "params must be an object") }
        }
        // Notifications get no answer, whatever they are.
        guard let id else { return nil }
        let reply: Result<JSONValue, RPCError> = await dispatch(method: method, params: params?.objectValue ?? [:])
        switch reply {
        case .success(let result): return ["jsonrpc": "2.0", "id": id, "result": result]
        case .failure(let e): return Self.error(id: id, e.code, e.message)
        }
    }

    struct RPCError: Error {
        let code: ErrorCode
        let message: String
    }

    func dispatch(method: String, params: [String: JSONValue]) async -> Result<JSONValue, RPCError> {
        switch method {
        case "initialize":
            return .success([
                // The server answers with the revision it implements; a client that cannot use it disconnects.
                "protocolVersion": .string(Self.protocolVersion),
                "capabilities": ["tools": ["listChanged": false]],
                "serverInfo": ["name": .string(Self.serverName), "title": "Kabinsiz on-device analyzers", "version": .string(Self.serverVersion)],
                "instructions": "Local Kabinsiz analyzers for development agents. Mac only, no network. Only image files under the repository or the system temp directory are accepted; use fixtures, never personal photos. Every result is a suggestion, not a measurement or an identity.",
            ])
        case "ping":
            return .success([:])
        case "tools/list":
            return .success(["tools": .array(tools.map(\.listing))])
        case "tools/call":
            guard let name = params["name"]?.stringValue else { return .failure(RPCError(code: .invalidParams, message: "params.name is required")) }
            guard let tool = tools.first(where: { $0.name == name }) else {
                return .failure(RPCError(code: .invalidParams, message: "Unknown tool: \(name)"))
            }
            let arguments: [String: JSONValue]
            switch params["arguments"] {
            case nil, .null?: arguments = [:]
            case .object(let o)?: arguments = o
            default: return .failure(RPCError(code: .invalidParams, message: "arguments must be an object"))
            }
            do {
                let output = try await tool.run(arguments, context)
                return .success(["content": [["type": "text", "text": .string(output.text)]], "structuredContent": output, "isError": false])
            } catch let e as InvalidArguments {
                return .failure(RPCError(code: .invalidParams, message: e.description))
            } catch let e as ToolFailure {
                return .success(["content": [["type": "text", "text": .string(e.description)]], "isError": true])
            } catch {
                return .failure(RPCError(code: .internalError, message: "Internal error"))
            }
        default:
            return .failure(RPCError(code: .methodNotFound, message: "Method not found: \(method)"))
        }
    }

    static func error(id: JSONValue, _ code: ErrorCode, _ message: String) -> JSONValue {
        ["jsonrpc": "2.0", "id": id, "error": ["code": .number(Double(code.rawValue)), "message": .string(message)]]
    }
}
