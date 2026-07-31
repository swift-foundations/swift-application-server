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

extension Application.Boundary.Table {
    /// The boundary table a server process realizes.
    ///
    /// A server opens three of the five boundaries, and every one of them
    /// re-applies rather than inherits:
    ///
    /// - **request** — an engine accepts connections on its own executors. The task
    ///   running a handler descends from the accept loop, not from the task that
    ///   booted the application, so it inherits nothing and must have the root
    ///   re-established.
    /// - **job** — a job is dequeued by a worker whose task likewise descends from
    ///   the queue driver.
    /// - **shutdown** — teardown runs after the run loop returns, frequently from a
    ///   signal handler's task rather than the boot task.
    ///
    /// **task** re-applies for the same reason: a detached background task started
    /// from a request handler would otherwise resolve nothing.
    ///
    /// **scene** is never opened by a server. ``Application/Boundary/Table`` has no
    /// way to say "not opened", so it is declared
    /// ``Application/Boundary/Disposition/inherited`` — the disposition that
    /// performs no work — and this sentence is the record that the value is
    /// vacuous rather than reasoned. A boundary a shell never opens is a real
    /// distinction the table cannot currently express.
    public static var server: Self {
        Application.Boundary.Table(
            request: .reapplied,
            scene: .inherited,
            task: .reapplied,
            job: .reapplied,
            shutdown: .reapplied
        )
    }
}
