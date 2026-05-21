---
layout: deeplinks
title: iOS — Universal Links
permalink: deeplinks-ios/
nav_order: 2
toc_list: true
---

# iOS — Universal Links

On iOS, deeplinks are implemented as **Universal Links**. Apple's documentation:
<https://developer.apple.com/ios/universal-links/>.

# How it works

1. The app declares one or more domains it can handle in its entitlements
   (`com.apple.developer.associated-domains`, with values like
   `applinks:yourdomain.com`).
2. Each declared domain must host a signed file at
   `https://yourdomain.com/.well-known/apple-app-site-association` (AASA).
3. The AASA file declares which app(s) are authorised, and which URL paths
   they should handle.
4. iOS fetches and caches the AASA file the first time the app is installed
   (and periodically afterwards).
5. From that point on, any tap on a matching `https://yourdomain.com/...`
   URL — from Mail, Messages, Safari, another app, etc. — is routed to the
   app instead of Safari.

# AASA example

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.yourcompany.yourapp",
        "paths": [ "/callback/*", "/itsme/*" ]
      }
    ]
  }
}
```

- The file must be served over HTTPS with a valid certificate.
- It must be served with `Content-Type: application/json`.
- It must be reachable **without redirects**.
- It must not require authentication.

# Good to know

- iOS only fetches the AASA file on app **install** or **update** (and via a
  background CDN refresh). If you change the file, existing installs may take
  a while to pick it up.
- Once a user explicitly opens the link in Safari (via the "long press →
  Open in Safari" menu), iOS may remember that choice and stop routing to
  the app. The user can reverse this from the Safari address bar's
  "Open in app" banner.
- Universal Links **do not work** when triggered from JavaScript (e.g.
  `window.location = "https://..."` from a tap handler). They must originate
  from a real user gesture on an `<a href>` element.
