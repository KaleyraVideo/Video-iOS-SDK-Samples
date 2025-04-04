// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import XCTest
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
@testable import SDK_Sample

final class URLSessionHTTPClientTests: UnitTestCase {

    private var sut: URLSessionHTTPClient!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        sut = .init(session: .init(configuration: configuration))
    }

    override func tearDown() {
        URLProtocolStub.reset()
        sut = nil
        super.tearDown()
    }

    func testGetRequestStartsURLRequest() {
        let exp = expectation(description: "Waiting for request to start")

        let request = makeARequest()
        URLProtocolStub.observeRequests { issuedRequest in
            assertThat(issuedRequest, equalTo(request))
            exp.fulfill()
        }

        sut.get(request) { _ in }

        wait(for: [exp], timeout: 1)
    }

    func testPostRequestStartsURLRequest() {
        let exp = expectation(description: "Waiting for request to start")

        let request = makeARequest()
        URLProtocolStub.observeRequests { issuedRequest in
            assertThat(issuedRequest.url, equalTo(request.url))
            exp.fulfill()
        }

        let _ = sut.post(.init(url: .kaleyra)) { _ in }

        wait(for: [exp], timeout: 5)
    }

    func testGetRequestReportsErrorWhenRequestFailsWithAnError() {
        let expectedError = anyNSError()

        let error = startRequest(simulatingFailure: expectedError)

        assertThat(error, present())
    }

    func testGetRequestReportsErrorWhenAnErrorIsReceivedAlongsideAnHttpResponse() {
        let emptyData = Data()
        let failureResponse = makeUnsuccessfulHTTPResponse()
        let receivedError = anyNSError()

        let error = startRequest(simulatingHTTPResponse: failureResponse, data: emptyData, error: receivedError)

        assertThat(error, present())
    }

    func testGetRequestReportsSuccessWhenSuccessfulHTTPResponseIsReceivedWithEmptyData() {
        let emptyData = Data()
        let successResponse = makeSuccessfulHTTPResponse()

        let result = startRequest(simulatingHTTPResponse: successResponse, data: emptyData)

        assertThat(result, present())
        assertThat(result?.response.statusCode, equalTo(successResponse.statusCode))
        assertThat(result?.response.url, equalTo(successResponse.url))
        assertThat(result?.data, equalTo(emptyData))
    }

    func testGetRequestReportsSuccessWhenNonSuccessfulHTTPResponseIsReceived() {
        let emptyData = Data()
        let failureResponse = makeUnsuccessfulHTTPResponse()

        let result = startRequest(simulatingHTTPResponse: failureResponse, data: emptyData)

        assertThat(result, present())
        assertThat(result?.response.statusCode, equalTo(failureResponse.statusCode))
        assertThat(result?.response.url, equalTo(failureResponse.url))
        assertThat(result?.data, equalTo(emptyData))
    }

    func testGetRequestReportsSuccessWhenAnyHTTPResponseIsReceivedWithNilData() {
        let failureResponse = makeUnsuccessfulHTTPResponse()

        let result = startRequest(simulatingHTTPResponse: failureResponse, data: nil)

        assertThat(result, present())
        assertThat(result?.response.statusCode, equalTo(failureResponse.statusCode))
        assertThat(result?.response.url, equalTo(failureResponse.url))
        assertThat(result?.data, equalTo(Data()))
    }

    func testGetRequestReportsFailureWhenNonHTTPResponseIsReceived() {
        let nonHTTPResponse = makeNonHTTPResponse()

        let error = startRequest(simulatingResponse: nonHTTPResponse)

        assertThat(error, present())
    }

    func testPostRequestHttpMethodIsPost() {
        let exp = expectation(description: "Waiting for request to start")

        URLProtocolStub.observeRequests { issuedRequest in
            assertThat(issuedRequest.httpMethod, equalTo("POST"))
            exp.fulfill()
        }

        let _ = sut.post(.init(url: .kaleyra)) { _ in }

        wait(for: [exp], timeout: 5)
    }

    func testPostRequestWithBodyCreatesARequestWithTheSameBody() throws {
        let exp = expectation(description: "Waiting for request to start")
        let body = "postBody".data(using: .utf8)

        URLProtocolStub.observeRequests { issuedRequest in
            assertThat(issuedRequest.httpBodyStream, present())
            assertThat(try? Data(reading: issuedRequest.httpBodyStream!), presentAnd(equalTo(body)))
            exp.fulfill()
        }

        var request = URLRequest(url: .kaleyra)
        request.httpBody = body
        let _ = sut.post(request) { _ in }

        wait(for: [exp], timeout: 5)
    }

    // MARK: - Helpers

    private func startRequest(simulatingHTTPResponse response: HTTPURLResponse, data: Data?, error: Error, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.simulateResponse(response, data: data, error: error)
        let request = makeARequest()
        let result = start(request: request)

        switch result {
            case let .failure(err):
                return err
            default:
                XCTFail("Expected failure, got \(result)", file: file, line: line)
                return nil
        }
    }

    private func startRequest(simulatingHTTPResponse response: HTTPURLResponse, data: Data?, file: StaticString = #filePath, line: UInt = #line) -> (response: HTTPURLResponse, data: Data)? {
        URLProtocolStub.simulateSuccess(response: response, data: data)
        let request = makeARequest()
        let result = start(request: request)

        switch result {
            case let .success(content):
                return (content.httpResponse, content.data)
            default:
                XCTFail("Expected success, got \(result)", file: file, line: line)
                return nil
        }
    }

    private func startRequest(simulatingFailure error: Error, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.simulateFailure(error)
        let request = makeARequest()
        let result = start(request: request)

        switch result {
            case let .failure(err):
                return err
            default:
                XCTFail("Expected failure, got \(result)", file: file, line: line)
                return nil
        }
    }

    private func startRequest(simulatingResponse response: URLResponse, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.simulateResponse(response)
        let request = makeARequest()
        let result = start(request: request)

        switch result {
            case let .failure(err):
                return err
            default:
                XCTFail("Expected failure, got \(result)", file: file, line: line)
                return nil
        }
    }

    private func start(request: URLRequest, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        let exp = expectation(description: "Waiting for task completion")
        let request = makeARequest()
        var result: Result<(data: Data, httpResponse: HTTPURLResponse), Error>!
        sut.get(request) { res in
            result = res
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        return result
    }

    private func makeARequest() -> URLRequest {
        URLRequest(url: .kaleyra)
    }

    private func makeSuccessfulHTTPResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: .kaleyra, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func makeUnsuccessfulHTTPResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: .kaleyra, statusCode: 400, httpVersion: nil, headerFields: nil)!
    }

    private func makeNonHTTPResponse() -> URLResponse {
        URLResponse(url: .kaleyra, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}

class URLProtocolStub: URLProtocol {

    private struct Stub {
        let response: URLResponse?
        let data: Data?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?

        init(response: URLResponse? = nil, data: Data? = nil, error: Error? = nil, requestObserver: ((URLRequest) -> Void)? = nil) {
            self.response = response
            self.data = data
            self.error = error
            self.requestObserver = requestObserver
        }
    }

    private static var queue = DispatchQueue(label: "stub.queue")
    private static var unsafeStub: Stub?
    private static var stub: Stub? {
        get { return queue.sync { unsafeStub } }
        set { queue.sync { unsafeStub = newValue } }
    }

    static func simulateSuccess(response: HTTPURLResponse, data: Data?) {
        simulateResponse(response, data: data, error: nil)
    }

    static func simulateFailure(_ error: Error) {
        stub = Stub(error: error)
    }

    static func simulateResponse(_ response: URLResponse) {
        stub = Stub(response: response)
    }

    static func simulateResponse(_ response: URLResponse, data: Data?, error: Error?) {
        stub = Stub(response: response, data: data, error: error, requestObserver: nil)
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(requestObserver: observer)
    }

    static func reset() {
        stub = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }

        stub.requestObserver?(request)
    }

    override func stopLoading() {

    }
}

private extension Data {

    init(reading input: InputStream) throws {
        self.init()
        try read(from: input)
    }

    private mutating func read(from input: InputStream) throws {
        input.open()
        defer { input.close() }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            } else if read == 0 {
                //EOF
                break
            }
            self.append(buffer, count: read)
        }
    }
}
