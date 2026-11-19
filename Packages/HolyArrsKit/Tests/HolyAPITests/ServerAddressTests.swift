import Foundation
import Testing
@testable import HolyAPI

@Suite struct ServerAddressTests {
    @Test func bareIPGetsHTTPAndDefaultPort() throws {
        let a = try ServerAddress(parsing: " 192.168.1.20 ")
        #expect(a.baseURL.absoluteString == "http://192.168.1.20:6262")
        #expect(a.urlBase == "")
        #expect(a.isLocalNetwork)
    }

    @Test func explicitPortIsKept() throws {
        let a = try ServerAddress(parsing: "192.168.1.20:8080")
        #expect(a.baseURL.absoluteString == "http://192.168.1.20:8080")
    }

    @Test func schemeWithoutPortKeepsSchemeDefault() throws {
        let a = try ServerAddress(parsing: "https://holyarrs.example.com")
        #expect(a.baseURL.absoluteString == "https://holyarrs.example.com")
        #expect(!a.isLocalNetwork)
    }

    @Test func urlBaseIsKeptWithoutTrailingSlash() throws {
        let a = try ServerAddress(parsing: "http://NAS.local:6262/holyarrs//")
        #expect(a.baseURL.absoluteString == "http://nas.local:6262/holyarrs")
        #expect(a.urlBase == "/holyarrs")
        #expect(a.isLocalNetwork)
    }

    @Test func apiPaths() throws {
        let a = try ServerAddress(parsing: "nas.local:6262/holyarrs")
        #expect(a.api("auth/state").absoluteString == "http://nas.local:6262/holyarrs/api/v1/auth/state")
        #expect(a.api("/asks").absoluteString == "http://nas.local:6262/holyarrs/api/v1/asks")
    }

    @Test func resolvesServerRelativePaths() throws {
        let a = try ServerAddress(parsing: "10.0.0.5/holyarrs")
        #expect(a.resolve("/api/v1/artwork/img/x.jpg")?.absoluteString
                == "http://10.0.0.5:6262/holyarrs/api/v1/artwork/img/x.jpg")
        #expect(a.resolve("/holyarrs/api/v1/artwork/img/x.jpg")?.absoluteString
                == "http://10.0.0.5:6262/holyarrs/api/v1/artwork/img/x.jpg")
        #expect(a.resolve("https://image.tmdb.org/t/p/w342/a.jpg")?.absoluteString
                == "https://image.tmdb.org/t/p/w342/a.jpg")
        #expect(a.resolve("relative.jpg") == nil)
    }

    @Test(arguments: [
        ("", ServerAddress.ParseError.empty),
        ("ftp://nas.local", .unsupportedScheme("ftp")),
        ("http://", .missingHost),
        ("192.168.1.20/?x=1", .hasQueryOrFragment),
    ])
    func rejectsBadInput(input: String, expected: ServerAddress.ParseError) {
        #expect(throws: expected) { try ServerAddress(parsing: input) }
    }

    @Test(arguments: [
        ("10.1.2.3", true), ("172.16.0.1", true), ("172.31.255.1", true), ("172.32.0.1", false),
        ("192.168.0.1", true), ("169.254.1.1", true), ("127.0.0.1", true), ("8.8.8.8", false),
        ("100.101.102.103", false), ("fe80::1", true), ("fd12::1", true), ("2001:db8::1", false),
    ])
    func privateIPs(host: String, isPrivate: Bool) {
        #expect(ServerAddress.isPrivateIP(host) == isPrivate)
    }

    @Test func singleLabelHostIsLocal() throws {
        #expect(try ServerAddress(parsing: "holyarrs").isLocalNetwork)
    }
}
