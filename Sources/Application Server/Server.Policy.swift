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

public import HTTP_Redirect
public import Server_Static

extension Server {
    /// What a server does to every request before and after the application sees it.
    ///
    /// A policy is data, not an engine. It names four decisions — which host is
    /// canonical, whether HTTP is redirected to HTTPS, which static resources are
    /// served, and what a failure looks like on the wire — and materializes them as
    /// a ``Server/Middleware`` stack through ``middleware``. Nothing here mentions
    /// Vapor, NIO, or a socket, so the same policy value describes a test harness
    /// and a production process identically.
    ///
    /// Each decision is realized by the package that already owns it:
    /// ``HTTP/Redirect/HTTPS`` and ``HTTP/Redirect/Canonical`` own the redirects,
    /// ``Server/Static/Policy`` owns static-resource resolution, and only the
    /// failure shape — which had no owner — is declared here as
    /// ``Server/Policy/Failure``.
    ///
    /// ```swift
    /// let policy = Server.Policy(
    ///     host: .init(canonical: "example.com"),
    ///     https: true,
    ///     failure: .init(format: .json)
    /// )
    ///
    /// let responder = policy.middleware.chain(around: base)
    /// ```
    public struct Policy: Sendable {
        /// The host this server answers to, or `nil` to answer to any host.
        public var host: Server.Policy.Host?

        /// Whether a plaintext request is redirected to its HTTPS equivalent.
        public var https: Bool

        /// The static resources served ahead of the application, or `nil` for none.
        ///
        /// Resolution is a decision, not a read: ``Server/Static/Policy`` says which
        /// resource a path denotes, and the engine adapter performs the file access.
        /// Keeping the decision here is what lets a policy be asserted against
        /// without a filesystem.
        public var resources: Server.Static.Policy?

        /// How a thrown ``Server/Error`` is presented to the client.
        public var failure: Server.Policy.Failure

        public init(
            host: Server.Policy.Host? = nil,
            https: Bool = false,
            resources: Server.Static.Policy? = nil,
            failure: Server.Policy.Failure = .init()
        ) {
            self.host = host
            self.https = https
            self.resources = resources
            self.failure = failure
        }
    }
}

// MARK: - Materialization

extension Server.Policy {
    /// The policy as a middleware stack, outermost first.
    ///
    /// Order is the policy's substance, not a detail. The failure shape is
    /// outermost so that every layer below it — including a redirect that throws —
    /// is presented to the client in the declared shape rather than escaping as an
    /// engine default. The HTTPS redirect precedes the canonical-host redirect so a
    /// plaintext request to a non-canonical host takes one hop per correction in a
    /// fixed order, rather than a different number of hops depending on which layer
    /// fired first.
    ///
    /// Static resources are absent from this stack deliberately: serving a file is
    /// an engine capability, so the adapter installs its own file layer using
    /// ``resources`` as the decision. A stack that pretended otherwise would be
    /// untrue at the only point where it mattered.
    // The stack is deliberately heterogeneous — distinct concrete conformers
    // composed in policy order — so an existential element type is the design.
    // swiftlint:disable:next no_any_protocol_existential
    public var middleware: [any Server.Middleware] {
        // swiftlint:disable:next no_any_protocol_existential
        var stack: [any Server.Middleware] = [failure]

        if https {
            stack.append(Redirect.HTTPS(on: true))
        }

        if let host {
            stack.append(Redirect.Canonical(host: host.canonical))
        }

        return stack
    }
}
