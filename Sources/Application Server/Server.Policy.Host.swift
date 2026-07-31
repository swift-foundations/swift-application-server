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

public import HTTP_Host

extension Server.Policy {
    /// The host a server answers to.
    ///
    /// Two decisions that are easy to conflate and must not be. ``canonical`` is the
    /// host every request is *redirected to*; ``allowed`` is the set of authorities
    /// a request may *arrive on* at all. A request to an allowed but non-canonical
    /// host is redirected; a request to a host outside the allowlist is refused
    /// before any redirect is considered, because a Host header the server does not
    /// recognize is not a routing hint, it is an attack surface.
    ///
    /// The canonical host is always allowed, so the common case states one name.
    public struct Host: Sendable, Hashable {
        /// The single host every request is redirected to.
        public var canonical: String

        /// Additional authorities a request may arrive on.
        ///
        /// ``canonical`` is implicit and need not be repeated.
        public var additional: [String]

        public init(canonical: String, additional: [String] = []) {
            self.canonical = canonical
            self.additional = additional
        }
    }
}

// MARK: - Authorization

extension Server.Policy.Host {
    /// Every authority a request may arrive on, canonical host included.
    public var allowed: [String] {
        [canonical] + additional
    }

    /// The allowlist this host policy denotes.
    ///
    /// Composed rather than restated: ``Host/Allowlist`` owns what it means for
    /// an authority to be admissible, and this policy owns only which authorities
    /// those are.
    public var allowlist: Host.Allowlist {
        Host.Allowlist(allowedHosts: allowed)
    }
}
