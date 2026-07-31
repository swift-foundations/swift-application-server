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

extension Server.Policy.Failure {
    /// The wire format a failure body takes.
    ///
    /// The status code is never a format decision — it comes from
    /// ``Server/Error/status`` in every case, because the error already knows what
    /// it is. Only the body's encoding varies.
    public enum Format: Sendable, Hashable, CaseIterable {
        /// `text/plain`, carrying ``Server/Error/message``.
        case text

        /// `application/json`, an object with a single `error` member.
        case json
    }
}
