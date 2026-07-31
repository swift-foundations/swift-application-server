# ``Application_Server``

@Metadata {
    @DisplayName("Application Server")
    @TitleHeading("Swift Foundations")
}

The server shell: engine-free middleware policy, the boundary table a server process realizes, and the adapter binding that runs it.

## Overview

An application is a composition root plus a routed response function. A shell is what
opens execution boundaries around that function for one execution context. This
package is that shell for a server process.

It owns two things and deliberately no more. The **policy vocabulary** names what a
server does to every request before and after the application sees it — which host is
canonical, whether HTTP is redirected to HTTPS, which static resources are served, and
what a failure looks like on the wire — each expressed without naming an engine. The
**boundary table** says how each boundary a server opens obtains the composition root.

Transport, routing, and the middleware algebra itself are not owned here. They are
`Server`, `URLRouting`, and their engine adapters, composed as ordinary dependencies.

## Topics

### Policy

- ``Server/Policy``
- ``Server/Policy/Host``
- ``Server/Policy/Failure``
- ``Server/Policy/Failure/Format``
