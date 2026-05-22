---
layout: deeplinks
title: How deeplinks work
permalink: deeplinks-overview/
nav_order: 1
toc_list: true
---

# How deeplinks work

Across this documentation we use the word **deeplink** as a generic term, but in
practice it maps to two different (but conceptually identical) platform
features:

| Platform | Official name      | Spec / mechanism                          |
|----------|--------------------|-------------------------------------------|
| iOS      | **Universal Link** | HTTPS URL + `apple-app-site-association`  |
| Android  | **App Link**       | HTTPS URL + Digital Asset Links (`assetlinks.json`) |

Both achieve the same outcome: when a regular `https://…` URL is opened on a
mobile device, the operating system silently routes it to a **specific app**
instead of the browser — provided that app is installed *and* that the domain
hosting the URL has cryptographically declared a trust relationship with the
app.

# Actors and hand-offs

In a typical itsme® flow, three actors are involved:

1. **Your application** (web page, mobile web, or native app) — starts the flow.
2. **The itsme® app** — performs authentication / signature / confirmation.
3. **The operating system** — decides whether a tapped/opened URL goes to a
   browser or to an installed app.

The deeplink mechanism is used in two directions:

1. **Hand-off to itsme®** — your application opens a URL like
   `https://merchant.itsme.be/...`. iOS/Android recognises the host as being
   associated with the itsme® app and opens that app directly.
2. **Return to your application** — once the user has completed the action in
   the itsme® app, itsme® opens a URL pointing back to **your** domain (the
   `redirect_uri` configured in the partner portal). iOS/Android recognises
   the host as being associated with **your** app and returns the user there.

For step 2 to skip the browser entirely, **your own domain must be configured
as a Universal Link / App Link target for your app**. If it is not, the URL
opens in the default browser, which can result in a degraded experience
(extra "Open in app?" prompt) or a broken flow if the browser tab does not
have access to the original session.

<aside class="notice">
A deeplink is just an <strong>HTTPS URL</strong>. The same URL will open the
app if installed and the configuration is correct, or fall back to a normal
web page otherwise. There is no custom scheme involved (custom schemes like
<code>myapp://</code> are deprecated for this use case because they are
insecure and can be hijacked by other apps).
</aside>

# End-to-end sequence

```
User in your app  ──tap──▶  HTTPS deeplink (itsme domain)
                              │
                       OS resolves owner
                              │
                              ▼
                         itsme® app opens
                              │
                       user authenticates
                              │
                              ▼
                  itsme® opens redirect_uri
                              │
                       OS resolves owner
                              │
                              ▼
                       Your app reopens
```
