---
title: "Hugo, Tailwind, and Netlify"
date: 2023-04-27T17:20:21Z
tags:
  - Web Development
---

I recently hopped on the [Tailwind CSS][tailwind] bandwagon, and I've been
thoroughly enjoying how productive I feel building web pages. I also wanted to
revamp this site, which was already built with [Hugo][hugo] and deployed on
[Netlify][netlify]. Here's the configuration I ended up with.

<!--more-->

Assuming there's an existing Hugo site, start by initializing an `npm` package.

```bash
npm init
```

Next we can install and initialize Tailwind:

```bash
npm install tailwindcss
npx tailwindcss init
```

For a Hugo site, we definitely want to utilize Tailwind classes in our layouts,
so a barebones `tailwind.config.js` would be:

```js
module.exports = {
  content: ["layouts/**/*.html"],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

We'll add the base CSS file `assets/global.css` that pulls in the Tailwind
defaults:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## PostCSS

PostCSS makes it easy to transform CSS with JavaScript plugins, and Tailwind
makes itself available as such a plugin. To get started, install PostCSS and the
related tooling:

```bash
npm install postcss postcss-cli autoprefixer
```

We can now configure PostCSS in `postcss.config.js` to utilize Tailwind and
autoprefixer:

```js
module.exports = {
  plugins: [require("tailwindcss"), require("autoprefixer")],
};
```

## Development Server

Hugo provides a [`PostCSS` pipe][hugo-postcss] to preprocess your CSS. The
problem is that this does not work well with Tailwind's JIT compiler since Hugo
only refreshes changed files, and it does not know that the CSS may have changed
when a class is added to a layout file. The easiest way to get around this is to
run the Hugo server and PostCSS process separately.

The two commands we'll be running are:

```bash
hugo server
postcss ./assets/global.css -o ./assets/dist/global.css --watch
```

To make this as easy as possible to run, we'll use [concurrently][concurrently]
to wrap these commands into a single NPM script. First, add `concurrently` to
the package:

```bash
npm install --save-dev concurrently
```

Then add the following scripts to `package.json`:

```json
{
  "scripts": {
    "dev": "concurrently \"npm:dev:*\"",
    "dev:css": "postcss assets/global.css -o assets/dist/global.css --watch",
    "dev:server": "hugo server"
  }
}
```

Don't forget to reference the built CSS in your Hugo templates, and add the
`assets/dist` directory to `.gitignore`.

Now we can run `npm run dev` and get a live-reloading server that recompiles our
CSS on every change.

## Production Build

Our production build is similar to our development build, just without the live
reloading:

```bash
postcss assets/global.css -o assets/dist/global.css
hugo
```

Again, we'll wrap these into a single NPM command for convenience:

```json
{
  "scripts": {
    "build": "npm run build:css && npm run build:site",
    "build:css": "postcss assets/global.css -o assets/dist/global.css",
    "build:site": "hugo"
  }
}
```

We can now use `npm run build` to create our static site!

## Netlify

Assuming you've already added your site in Netlify, there is a small amount of
configuration we need to add to our repository in `netlify.toml`:

```toml
[build]
  publish = "public"
  command = "HUGO_BASE_URL=$DEPLOY_PRIME_URL npm run build"

[build.environment]
  HUGO_VERSION = "0.111.3"
```

The `publish` option tells Netlify which directory to publish. Hugo outputs into
the `public/` directory by default.

We set `command` to our nicely packaged `npm run build` script. The presence of
a `package.json` file causes Netlify to install the packages by default, so we
don't need to worry about that. We also set the `HUGO_BASE_URL` environment
variable to `$DEPLOY_PRIME_URL` which contains the base URL of the Netlify site
being deployed. This allows absolute permalinks to work in both the production
build, and any branch deploys or deploy previews.

Finally, we pin a `HUGO_VERSION` since the `hugo` provided in the base image is
most likely older than what we want. Netlify automatically [installs the pinned
version][netlify-hugo-version].

[concurrently]: https://www.npmjs.com/package/concurrently
[hugo]: https://gohugo.io
[hugo-postcss]: https://gohugo.io/hugo-pipes/postcss/
[netlify]: https://www.netlify.com/
[netlify-hugo-version]:
  https://docs.netlify.com/integrations/frameworks/hugo/#hugo-version
[tailwind]: https://tailwindcss.com/
