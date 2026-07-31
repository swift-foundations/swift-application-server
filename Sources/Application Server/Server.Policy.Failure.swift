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

public import JSON

extension Server.Policy {
    /// How a thrown ``Server/Error`` is presented to the client.
    ///
    /// This is the one element of ``Server/Policy`` with no prior owner. Redirects,
    /// host authorization, and static-resource resolution each already have a
    /// package; turning the server's error domain into a response did not, and it
    /// belongs to the shell because it is a property of the deployment rather than
    /// of any one route.
    ///
    /// Note the name: this is the failure *policy*, not an error type. It conforms
    /// to ``Server/Middleware``, not to `Swift.Error`.
    ///
    /// The middleware is outermost in the stack, so a failure raised anywhere below
    /// it — including by another middleware — is presented in the declared format
    /// rather than escaping to whatever the engine does with an uncaught error.
    public struct Failure: Sendable, Hashable {
        /// The wire format the failure body takes.
        public var format: Server.Policy.Failure.Format

        public init(format: Server.Policy.Failure.Format = .text) {
            self.format = format
        }
    }
}

// MARK: - Presentation

extension Server.Policy.Failure {
    /// The response presenting `error` in this policy's format.
    ///
    /// Total by construction: every ``Server/Error`` case carries both a status and
    /// a message, so there is no failure mode here and no error to throw.
    public func response(for error: Server.Error) -> Server.Response {
        switch format {
        case .text:
            return .text(error.message, status: error.status)

        case .json:
            // Serialized through the JSON owner rather than by string
            // interpolation: the message is arbitrary text, and an interpolated
            // body would emit invalid JSON the first time one contained a quote.
            let body: JSON = ["error": JSON(stringLiteral: error.message)]
            return .json(body.serialize(), status: error.status)
        }
    }
}

// MARK: - Middleware

extension Server.Policy.Failure: Server.Middleware {
    public func intercept(
        _ request: Server.Request,
        next: Server.Responder
    ) async throws(Server.Error) -> Server.Response {
        // `do throws(Server.Error)` is required for the catch to bind the typed
        // error; an unannotated `do` binds `any Error` and the branch below would
        // not compile against `response(for:)`.
        do throws(Server.Error) {
            return try await next(request)
        } catch {
            return response(for: error)
        }
    }
}
