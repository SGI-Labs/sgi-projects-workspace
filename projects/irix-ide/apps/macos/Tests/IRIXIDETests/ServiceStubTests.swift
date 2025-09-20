#if canImport(XCTest)
import XCTest
@testable import IRIXServices

final class ServiceStubTests: XCTestCase {
    func testHostLoadReturnsStubs() async throws {
        let hosts = await StubHostService().loadHosts()
        XCTAssertFalse(hosts.isEmpty)
    }
}
#endif
