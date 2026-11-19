import Foundation

/// Where a HolyArrs server lives: scheme, host, port and optional URL base
/// (for servers run under a path such as `/holyarrs`).
public struct ServerAddress: Sendable, Hashable, Codable {
    /// HolyArrs listens on 6262 unless told otherwise.
    public static let defaultPort = 6262

    /// The server root including any URL base, without a trailing slash,
    /// e.g. `http://192.168.1.20:6262` or `http://nas.local:6262/holyarrs`.
    public let baseURL: URL

    public enum ParseError: Error, Equatable, Sendable {
        case empty
        case unsupportedScheme(String)
        case missingHost
        case hasQueryOrFragment
        case invalid
    }

    /// Parses what someone types in the Connect screen.
    ///
    /// - No scheme → `http://` and, unless a port is given, port 6262.
    /// - Trailing slashes are dropped; a path is kept as the URL base.
    public init(parsing input: String) throws(ParseError) {
        var text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw .empty }

        let hadScheme = text.range(of: "://") != nil
        if !hadScheme { text = "http://" + text }

        guard var parts = URLComponents(string: text) else { throw .invalid }
        let scheme = (parts.scheme ?? "").lowercased()
        guard scheme == "http" || scheme == "https" else { throw .unsupportedScheme(scheme) }
        guard let host = parts.host, !host.isEmpty else { throw .missingHost }
        guard parts.query == nil, parts.fragment == nil else { throw .hasQueryOrFragment }

        parts.scheme = scheme
        parts.host = host.lowercased()
        if parts.port == nil, !hadScheme { parts.port = Self.defaultPort }
        while parts.path.hasSuffix("/") { parts.path.removeLast() }
        parts.user = nil
        parts.password = nil

        guard let url = parts.url else { throw .invalid }
        baseURL = url
    }

    /// The URL base (path prefix), `""` when the server is at the root.
    public var urlBase: String {
        URLComponents(url: baseURL, resolvingAgainstBaseURL: false)?.path ?? ""
    }

    /// `{base}/api/v1/{path}`.
    public func api(_ path: String) -> URL {
        appending("/api/v1/" + path.trimmingPrefix("/"))
    }

    /// Resolves a server-relative path from an API answer (picture paths
    /// often come without the URL base). Absolute URLs pass through.
    public func resolve(_ path: String) -> URL? {
        if let url = URL(string: path), url.scheme != nil { return url }
        guard path.hasPrefix("/") else { return nil }
        let base = urlBase
        if !base.isEmpty, path == base || path.hasPrefix(base + "/") {
            return URL(string: path, relativeTo: root)?.absoluteURL
        }
        return appending(path)
    }

    /// Whether iOS will allow plain HTTP to this host under
    /// `NSAllowsLocalNetworking` (IP addresses, `.local` and single-label names).
    public var isLocalNetwork: Bool {
        guard let host = baseURL.host() else { return false }
        if host.hasSuffix(".local") || !host.contains(".") && !host.contains(":") { return true }
        return Self.isPrivateIP(host)
    }

    // MARK: - Private

    private var root: URL {
        var parts = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        parts.path = ""
        return parts.url!
    }

    private func appending(_ path: String) -> URL {
        URL(string: baseURL.absoluteString + path)!
    }

    static func isPrivateIP(_ host: String) -> Bool {
        let h = host.trimmingCharacters(in: CharacterSet(charactersIn: "[]")).lowercased()
        let octets = h.split(separator: ".", omittingEmptySubsequences: false).compactMap { UInt8($0) }
        if octets.count == 4 {
            switch (octets[0], octets[1]) {
            case (10, _), (127, _), (192, 168), (169, 254): return true
            case (172, 16...31): return true
            default: return false
            }
        }
        if h.contains(":") {
            return h == "::1" || h.hasPrefix("fe80:") || h.hasPrefix("fc") || h.hasPrefix("fd")
        }
        return false
    }
}

private extension String {
    func trimmingPrefix(_ prefix: String) -> String {
        hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
    }
}
