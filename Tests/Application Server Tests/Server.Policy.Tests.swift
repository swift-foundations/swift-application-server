// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-application-server open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-application-server project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Application_Server
import HTTP_Standard
import Testing

extension Server.Policy {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

// MARK: - Unit

extension Server.Policy.Test.Unit {
    @Test func `a default policy installs only the failure shape`() {
        let policy = Server.Policy()

        #expect(policy.middleware.count == 1)
    }

    @Test func `enabling https adds exactly one layer`() {
        let plain = Server.Policy()
        let secure = Server.Policy(https: true)

        #expect(secure.middleware.count == plain.middleware.count + 1)
    }

    @Test func `naming a canonical host adds exactly one layer`() {
        let anyHost = Server.Policy()
        let canonical = Server.Policy(host: .init(canonical: "example.com"))

        #expect(canonical.middleware.count == anyHost.middleware.count + 1)
    }

    @Test func `the canonical host is allowed without being repeated`() {
        let host = Server.Policy.Host(canonical: "example.com")

        #expect(host.allowed == ["example.com"])
    }

    @Test func `additional hosts follow the canonical one`() {
        let host = Server.Policy.Host(
            canonical: "example.com",
            additional: ["www.example.com"]
        )

        #expect(host.allowed == ["example.com", "www.example.com"])
    }

    @Test func `every boundary a server opens re-applies the root`() {
        let table = Application.Boundary.Table.server

        #expect(table[.request] == .reapplied)
        #expect(table[.job] == .reapplied)
        #expect(table[.shutdown] == .reapplied)
        #expect(table[.task] == .reapplied)
    }
}

// MARK: - Edge Case

extension Server.Policy.Test.`Edge Case` {
    @Test func `a text failure carries the error's own status`() {
        let failure = Server.Policy.Failure(format: .text)
        let response = failure.response(for: .notFound("no such page"))

        #expect(response.status == HTTP.Status.notFound)
    }

    @Test func `a json failure carries the error's own status`() {
        let failure = Server.Policy.Failure(format: .json)
        let response = failure.response(for: .unauthorized)

        #expect(response.status == HTTP.Status.unauthorized)
    }

    @Test func `a message containing a quote stays valid json`() {
        // The reason `response(for:)` serializes through the JSON owner instead of
        // interpolating: this input is what an interpolated body gets wrong.
        let failure = Server.Policy.Failure(format: .json)
        let response = failure.response(for: .badRequest(#"unexpected " character"#))
        let body = Swift.String(decoding: response.body, as: Swift.UTF8.self)

        #expect(body.contains(#"\""#))
    }

    @Test func `the failure shape is outermost in the stack`() {
        // Order is the policy's substance: a failure raised by the redirect layer
        // must still be presented in the declared format.
        let policy = Server.Policy(host: .init(canonical: "example.com"), https: true)
        let outermost = policy.middleware.first

        #expect(outermost is Server.Policy.Failure)
    }
}

// MARK: - Integration

extension Server.Policy.Test.Integration {
    @Test func `a failing responder is presented in the declared format`() async throws {
        let policy = Server.Policy(failure: .init(format: .json))
        let responder = policy.middleware.chain(around: { _ throws(Server.Error) in
            throw Server.Error.forbidden("nope")
        })

        let response = try await responder(Server.Request(method: .get, path: ["x"]))
        let body = Swift.String(decoding: response.body, as: Swift.UTF8.self)

        #expect(response.status == HTTP.Status.forbidden)
        #expect(body.contains("nope"))
    }

    @Test func `a succeeding responder passes through untouched`() async throws {
        let policy = Server.Policy()
        let responder = policy.middleware.chain(around: { _ throws(Server.Error) in
            Server.Response.text("ok")
        })

        let response = try await responder(Server.Request(method: .get, path: []))
        let body = Swift.String(decoding: response.body, as: Swift.UTF8.self)

        #expect(response.status == HTTP.Status.ok)
        #expect(body == "ok")
    }
}
