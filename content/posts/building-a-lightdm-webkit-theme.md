---
title: "Building a LightDM Webkit Greeter Theme"
description: Building a theme for `lightdm-webkit2-greeter`.
date: 2021-01-23T22:54:04Z
tags:
  - Programming
---

I recently built [a custom LightDM greeter theme][custom-theme], and there
wasn't a whole lot of info I found on how to do this, so I wanted to jot down
some tips.

<!--more-->

LightDM has the concept of greeters, which are the user's entrypoint into a
graphical session. One of these greeters is `lightdm-webkit2-greeter` which
allows your greeter to be created using standard web technologies. This is great
for me since I'm much more familiar with web development than I am with creating
GUIs using GTK.

## Escaping to Safety

Because you have to pass through the greeter to gain access to any kind of
graphical user session, it is important to know how to fix your system in case
of show-stopping issues with your custom theme.

My usual method of reverting changes is switching to another TTY, usually with
<kbd>Ctrl + Alt + F2</kbd>, and reverting to the default theme. Note that this
is a shell-based environment, so you should have a working knowledge of how to
navigate and edit in such an environment.

## The LightDM API

Since the primary function of the greeter is to eventually launch a graphical
session, there obviously needs to be some sort of API that is exposed to your
greeter. With the webkit greeter, this takes the form of a few globals exposed
through `window` object via Javascript. This is great, but I was struggling to
find any documentation on this API. Then I saw a tip to read the greeter's man
page, and all my problems were solved.

```
man lightdm-webkit2-greeter
```

The man page contains information about all of the properties and methods that
are exposed, as well as the objects it expects your theme to provide. Super
useful.

## File Paths and Routing

Under the hood, the theme is being loaded the same way any other local file is
loaded in the browser: via a `file://` URL. When developing a theme, you have to
be cognisant of how your paths will be resolved. For example, in a standard web
app, it's common to build absolute paths for assets that begin with a `/`. This
does not work for a greeter theme because any absolute path will be resolved
from the root of your file system which is certainly not where your theme is.
I've found the best solution here is to output relative paths. In the theme I
built, the `index.html` file references the scripts with the relative reference
`main.js` as opposed to something like `/main.js` which is what I would do in a
standard web app.

One reason to avoid relative paths in a traditional web app is that you can get
into trouble when accessing a page that is not at the site root since a relative
reference would now be pointing to a different path. This is not really a
problem in the context of our webkit-based greeter since routing using the HTML5
history API doesn't work so well with `file://` URLs.

Instead of using the history API, it is much easier to use hash-based navigation
in a greeter theme (eg `#/some/path` instead of `/some/path`). This also solves
the issue with relative URIs because there will only be one path for relatively
referenced assets to be loaded from.

## Debugging

The easiest way to debug a greeter theme is by running it in a normal web
browser. Of course you'll have to mock out the globals that facilitate
interactions with LightDM, but otherwise this is a huge benefit of using
standard web technologies to create interfaces.

Unfortunately mocks are never 100% accurate, and there will always be bugs only
discovered when the theme is running in the actual LightDM environment. For this
case, the debug mode provided by `lightdm-webkit2-greeter` is exceedingly
helpful. It can be enabled in `/etc/lightdm/lightdm-webkit2-greeter.conf` in the
`[greeter]` section by setting `debug_mode = true`. With this mode enabled, you
can now right-click on an element when the greeter is running and select
"Inspect Element" to get a full debug console where you can look for Javascript
errors, inspect elements, and examine the globals that LightDM provides.

[custom-theme]: https://github.com/cdriehuys/lightdm-webkit-theme
