# swift-application-server

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The server shell for [swift-application](https://github.com/swift-foundations/swift-application) — engine-free middleware policy, the boundary table a server process realizes, and the adapter binding that runs it.

An application is a composition root plus a routed response function. A shell is what opens execution boundaries around that function for one execution context. This package is that shell for a server process: a boundary per request, per job, and at shutdown.

## Key Features

- **Policy is data, not an engine** — `Server.Policy` names four decisions (canonical host, HTTPS redirect, static resources, failure shape) and materializes them as a middleware stack. Nothing in the vocabulary mentions Vapor, NIO, or a socket, so the same value describes a test harness and a production process identically.
- **Composed, not restated** — the redirects come from `swift-http-redirect`, host authorization from `swift-http-host`, static-resource resolution from `swift-server-static`. Only the failure shape, which had no owner, is declared here.
- **The failure shape is outermost** — order is the policy's substance: a failure raised anywhere below, including by another middleware, is presented in the declared format rather than escaping to whatever the engine does with an uncaught error.
- **An explicit boundary table** — `Application.Boundary.Table.server` records that every boundary a server opens re-applies the composition root, and why. A handler's task descends from the engine's accept loop, not from the task that booted the application, so it inherits nothing.

## Quick Start

```swift
import Application_Server

let policy = Server.Policy(
    host: .init(canonical: "example.com", additional: ["www.example.com"]),
    https: true,
    failure: .init(format: .json)
)

// Outermost first: failure shape, HTTPS redirect, canonical-host redirect.
let responder = policy.middleware.chain(around: base)
```

The failure format decides the body's encoding and nothing else. The status always comes from `Server.Error.status`, because the error already knows what it is:

```swift
let failure = Server.Policy.Failure(format: .json)
failure.response(for: .notFound("no such page"))
// 404, {"error":"no such page"}
```

The message is serialized through the JSON owner rather than interpolated, so a message containing a quote does not emit invalid JSON.

## Status

This package is landing under the application-layer programme. The policy vocabulary and boundary table are in place. The runtime conformer and the Vapor adapter binding are held pending an asynchronous re-application path in `swift-application` — the composition root's `reapply` is currently synchronous, and every boundary a server opens is asynchronous.

## Installation

No versions are tagged yet; pin to `main`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-application-server.git", branch: "main")
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Application Server", package: "swift-application-server")
    ]
)
```

## License

Apache License 2.0. See [LICENSE.md](LICENSE.md).
