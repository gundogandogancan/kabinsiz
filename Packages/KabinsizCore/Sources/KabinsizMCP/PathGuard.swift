import Darwin
import Foundation

/// Which files a tool may open: regular image files under the repository or this server's own temp
/// folder, after every symlink is resolved. Anything else (the home folder, Photos, a symlink in
/// the repo pointing out of it, `..` tricks) is refused before a byte is read.
struct PathGuard: Sendable {
    enum Refusal: Error, CustomStringConvertible {
        case notAbsolute, missing, outsideAllowedRoots(String), notRegularFile, tooLarge(Int), notAnImageType(String)

        var description: String {
            switch self {
            case .notAbsolute: "path must be absolute"
            case .missing: "file does not exist"
            case .outsideAllowedRoots(let p): "path resolves outside the repository and <temp>/kabinsiz-mcp/: \(p)"
            case .notRegularFile: "not a regular file"
            case .tooLarge(let n): "file is \(n) bytes; limit is \(PathGuard.maxBytes)"
            case .notAnImageType(let e): "extension .\(e) is not an accepted image type"
            }
        }
    }

    static let maxBytes = 40 * 1024 * 1024
    static let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "heic", "heif", "tif", "tiff"]

    /// Real (symlink-free) roots, each ending in `/`.
    let roots: [String]

    /// Temp files are allowed only in a folder of this server's own (`<temp>/kabinsiz-mcp/`), created
    /// owner-only at start: the shared temp directory holds other apps' caches and screenshots.
    static let tempFolderName = "kabinsiz-mcp"

    init(repoRoot: String) {
        var candidates = [repoRoot]
        for base in [NSTemporaryDirectory(), "/tmp"] {
            let folder = (base as NSString).appendingPathComponent(Self.tempFolderName)
            try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
            // A folder someone else made first (/tmp is shared) is not ours: it is not a root.
            var info = stat()
            guard lstat(folder, &info) == 0, (info.st_mode & S_IFMT) == S_IFDIR, info.st_uid == getuid() else { continue }
            candidates.append(folder)
        }
        roots = candidates.compactMap(Self.realPath).map { $0.hasSuffix("/") ? $0 : $0 + "/" }
    }

    static func realPath(_ path: String) -> String? {
        guard let resolved = Darwin.realpath(path, nil) else { return nil }
        defer { free(resolved) }
        return String(cString: resolved)
    }

    /// Returns the resolved path of an allowed image file.
    func check(_ raw: String) throws(Refusal) -> String {
        guard raw.hasPrefix("/") else { throw .notAbsolute }
        guard let real = Self.realPath(raw) else { throw .missing }
        guard roots.contains(where: { real.hasPrefix($0) }) else { throw .outsideAllowedRoots(real) }
        var info = stat()
        guard lstat(real, &info) == 0, (info.st_mode & S_IFMT) == S_IFREG else { throw .notRegularFile }
        guard info.st_size <= Self.maxBytes else { throw .tooLarge(Int(info.st_size)) }
        let ext = (real as NSString).pathExtension.lowercased()
        guard Self.imageExtensions.contains(ext) else { throw .notAnImageType(ext) }
        return real
    }
}
