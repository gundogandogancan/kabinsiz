import Foundation

// V37-06: the one network transport in the package, exempted by name in the static egress scan
// (StoreAndPrivacyTests.staticEgress), which also pins the settings below. It sends nothing about the
// user: no cookies, no cache, no credentials, no body, no query, a fixed User-Agent and language, and
// refuses redirects (a redirect could leave the allowlisted host). It only GETs URLs that
// `PartnerFeedConnector` already checked and only after the caller's capability check.

/// URLSession over an ephemeral, cookie-less configuration. One instance per fetch is fine.
public struct EphemeralFeedTransport: FeedTransport {
    public static let timeoutSeconds: TimeInterval = 15

    public init() {}

    public func fetch(_ request: FeedFetchRequest) async throws -> FeedDownload {
        let session = Self.makeSession()
        defer { session.invalidateAndCancel() }
        let payload = try await Self.get(request.feedURL, maxBytes: request.maxBytes, session: session)
        let signature = try await Self.get(request.signatureURL, maxBytes: 256, session: session)
        return FeedDownload(payload: payload, signature: signature)
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        configuration.urlCredentialStorage = nil
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.timeoutIntervalForRequest = timeoutSeconds
        configuration.timeoutIntervalForResource = timeoutSeconds * 2
        configuration.waitsForConnectivity = false
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        // Fixed values replace the defaults, which name the app build, the OS and the user's languages.
        configuration.httpAdditionalHeaders = [
            "User-Agent": "Kabinsiz-PartnerFeed/1",
            "Accept-Language": "en",
            "Accept": "application/json, application/octet-stream, text/plain",
        ]
        return URLSession(configuration: configuration, delegate: NoRedirects(), delegateQueue: nil)
    }

    static func get(_ url: URL, maxBytes: Int, session: URLSession) async throws -> Data {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutSeconds)
        request.httpMethod = "GET"
        request.httpShouldHandleCookies = false
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw PartnerFeedError.transportFailed }
        if http.expectedContentLength > Int64(maxBytes) { throw PartnerFeedError.oversize(bytes: Int(http.expectedContentLength)) }
        var data = Data()
        data.reserveCapacity(min(maxBytes, 64 * 1024))
        for try await byte in bytes {
            data.append(byte)
            // Stop reading as soon as the cap is passed, whatever Content-Length claimed.
            if data.count > maxBytes { throw PartnerFeedError.oversize(bytes: data.count) }
        }
        return data
    }
}

/// Refuses every redirect: the feed must be served from the URL that was checked.
private final class NoRedirects: NSObject, URLSessionTaskDelegate, Sendable {
    func urlSession(
        _ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
