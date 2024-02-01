---
title: "Hugo, Netlify, and Sitemaps"
date: 2024-02-01T23:37:43Z
tags:
  - Hugo
  - Netlify
  - Web Development
---

I went through a brief struggle figuring out how to generate sitemaps accepted
by Google from my site built with Hugo and deployed on Netlify. Here's how I
fixed it.

<!--more-->

## The Problem

When publishing a Hugo site with Netlify, Netlify [recommends setting the base
URL to "/"][netlify-base-url-recommendation]. This appears to work great when
you're just browsing the site. Links resolve correctly in both the production
build as well as any deploy previews even though the hostname changes.

When you take the next step with your site and start looking into SEO, you run
into the issue of Google (among others) complaining that your sitemap contains
invalid URLs. The issue is that they expect full URLs with a scheme, hostname,
and path, and the recommended Hugo configuration results in links that are just
absolute paths (no hostname or scheme).

## The Solution

The solution is to specify your canonical production URL as the base URL in
`hugo.toml`. You can then add the following to `netlify.toml` to override the
base URL for deploy previews:

```toml
[context.deploy-preview]
  command = "hugo --baseURL $DEPLOY_PRIME_URL"
```

In development, the `hugo server` command automatically overrides the base URL
to whatever localhost port the development server is bound to.

## Why Not `$DEPLOY_PRIME_URL` Everywhere?

As stated by Netlify, `$DEPLOY_PRIME_URL` is a "URL representing the primary URL
for an individual deploy, or a group of them, like branch deploys and Deploy
Previews; for example, `https://feature-branch--petsof.netlify.app` or
`https://deploy-preview-1--petsof.netlify.app`".

This is great for pointing to deploy previews, but for your primary production
deployment, this would still point to the name of your main branch rather than
any custom domain you have set up.

[netlify-base-url-recommendation]:
  https://answers.netlify.com/t/hugo-deployment-generates-urls-to-examplesite-com/13153/3
[netlify-env-urls]:
  https://docs.netlify.com/configure-builds/environment-variables/#deploy-urls-and-metadata
