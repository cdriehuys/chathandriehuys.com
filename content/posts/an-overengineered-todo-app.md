---
title: "An Overengineered Todo App"
date: 2026-06-07T14:10:28Z
tags:
  - Web Development
summary: >
  Delivering a Go-based API and React UI in a single container.
---

The concept of serving a React UI from a Go application is not novel. With Go's
ability to embed files and the standard library functions to serve files, you
can add a frontend to your existing web application in a couple of lines:

```go
import (
  "embed"
  "net/http"
)

//go:embed frontend/dist
var uiFiles embed.FS

// Note you might have to use [fs.Sub] to get the paths to line up correctly.
var flatFiles, _ := fs.Sub(uiFiles, "frontend/dist")

// Add a fallback route to your existing mux. Any route not handled by your API
// falls back to the frontend assets.
mux.Handle("/", http.FileServerFS(flatFiles))
```

I've known about this pattern for a while, but I wanted to experiment with what
it would be like to actually build an application like this. The "Hello, World!"
case is simple, but what problems come up when you try to build an actual
application?

## Routing

The first obvious hurdle is routing. Many single page applications use
client-side routing. This means that clicking a link like `/about` in the
application will swap in the appropriate UI without reloading the full page. The
issue is if a user either does a full refresh on the `/about` page or navigates
to it directly, the server has no idea that's a valid page since it does not
correspond to a file in the frontend's resources.

To solve this problem we need a router that does the following:

1. Serves API routes for requests to `/api/...`
2. Serves static resources for the frontend. Things like Javascript bundles and
   CSS files.
3. Serves the frontend's `index.html` for other requests

The first part is simple. Go's mux prioritizes longer path matches, so setting
up a handler for the `/api/` route handles all those requests appropriately:

```go
mux.Handle("/api/", someAPIHandler)
mux.Handle("/", uiFallback)
```

Now we need some way of serving static assets with a fallback to `index.html` if
the request path does not correspond to a real file. Unfortunately
`http.FileServerFS` does not have any mechanism for adding a fallback for
missing files. We can however add a new `fs.FS` implementation that gives us
what we want.

```go
type uiFS struct {
	files fs.FS
}

func (ui *uiFS) Open(name string) (fs.File, error) {
	file, err := ui.files.Open(name)
	if err == nil {
		return file, nil
	}

	return ui.files.Open("index.html")
}
```

We can then pass this directly to `http.FileServerFS`:

```go
mux.Handle("/", http.FileServerFS(&uiFS{flatFiles}))
```

The result is the desired routing logic:

```text
/api/data  -> API handler
/style.css -> Serve corresponding embedded file
/some/page -> Fallback to `index.html` to let client routing happen
```

## Development Experience

Another topic the toy example doesn't touch is the development experience.
Especially on the UI side, developers are accustomed to features like hot module
replacement (HMR) to iterate quickly. The current application requires a full
build of the UI followed by a full build of the Go application in order for any
change to be reflected.

I don't want to reinvent the wheel here. Most languages/frameworks already have
established methods for running a development server with live reloading. To
take advantage of this work, we're going to run separate UI and API servers in
development. The downside of this split is that our development setup is now
diverging from the production setup which can introduce errors. We'll do our
best to minimize this.

### UI Reloading

The main challenge with a separate UI server is that the API is no longer
accessible at the same origin as the UI. Requests to `/api/endpoint` that work
when the application is bundled together will start to fail in development.

I chose Vite for this application since it provides fast builds and HMR out of
the box. Fortunately it also provides a proxy which lets us solve this problem
by adding the following to `vite.config.ts`:

```js
export default defineConfig({
  // ... other config ...

  // Proxy API endpoints
  server: {
    proxy: {
      "/api": "http://localhost:8000",
    },
  },
});
```

The nice part about this implementation is that it only requires a config change
to Vite's development server. It does not require any changes to application
code like swapping out the API base URL with an environment variable. This
minimizes the differences between production and development to reduce the
possibility of errors during deployment.

### API Reloading

If the UI is going to get live reloading, we might as well add it to the API
too. I used `air` for this which pretty much just worked right out of the box.

The only implementation detail of note here is that we can skip bundling the UI
in this case because it's running separately. This improves build times since Go
does not have to read and embed all the frontend files into the binary.

Add one file with all the implementation from earlier:

```go
// register_ui_route.go

// Build this file as long as the `no_ui` tag is not set.
//go:build !no_ui

import "embed"

type uiFS struct {
  // ...
}

//go:embed frontend/dist
var uiFiles embed.FS

func registerUIRoute(mux *http.ServeMux) {
  mux.Handle("/", http.FileServerFS(&uiFS{flatFiles}))
}
```

Add another file that stubs `registerUIRoute` if the UI should be omitted:

```go
// register_ui_route_no_ui.go

// Only if the `no_ui` tag is set
//go:build no_ui

import "net/http"

func registerUIRoute(mux *http.ServeMux) {
  // no-op
}
```

In the main routing configuration, use the new `registerUIRoute` function:

```go
mux.Handle("/api/", someAPIHandler)
registerUIRoute(mux)
```

In your air config, ensure that the build command passes the `no_ui` tag:

```toml
[build]
  cmd = "go build -o tmp/app -tags no_ui ."
```

## Recap

We still have an application that is delivered as a single binary. At this point
the integration code is also pretty static meaning the UI is basically a
separate application. The API server does not need to know any implementation
details of the UI. As long as UI changes are built to the target embed
directory, they will be automatically picked up by the bundled application.

On the development side we have live reloading of both the UI and API which
enables developers to use the tools they are comfortable with regarding builds
and debugging.

I'd consider this a pretty solid foundation to build a real application on top
of. For an example, see [my demo repository][demo-repo] which contains a todo
app using this pattern. It also has the additional feature of the API server and
client being generated from an OpenAPI spec.

[demo-repo]: https://github.com/cdriehuys/oaas
