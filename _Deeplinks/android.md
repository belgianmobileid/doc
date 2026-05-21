---
layout: deeplinks
title: Android — App Links
permalink: deeplinks-android/
nav_order: 3
toc_list: true
---

# Android — App Links

On Android, deeplinks are implemented as **App Links** (Android 6.0+). Google's
documentation: <https://developer.android.com/training/app-links>.

# How it works

1. The app declares intent filters in its manifest for the HTTPS scheme and
   the relevant host(s), with `android:autoVerify="true"`.
2. Each declared domain must host a Digital Asset Links file at
   `https://yourdomain.com/.well-known/assetlinks.json` that lists the
   package name and the SHA-256 fingerprints of the signing certificate(s).
3. On install/update, Android fetches the file and, if verification succeeds,
   marks the app as the **default handler** for those URLs — no disambiguation
   dialog is ever shown.
4. From that point on, any tap on a matching `https://yourdomain.com/...`
   URL opens the app directly.

# assetlinks.json example

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.yourcompany.yourapp",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:DD:..."
      ]
    }
  }
]
```

- Must be served over HTTPS with a valid certificate.
- Must be served with `Content-Type: application/json`.
- Must be reachable without redirects.
- The fingerprint must match the certificate the APK/AAB is actually signed
  with — including the **Play App Signing** certificate when using Google
  Play, *not* your upload certificate.

# Good to know

- If verification fails, the link will still open — but Android will show a
  disambiguation dialog ("Open with…") or, worse, silently open the browser.
- You can inspect verification state on a device with:
  `adb shell pm get-app-links com.yourcompany.yourapp`
- The user can manually disable App Links handling for a given app in
  **Settings → Apps → [App] → Open by default**. This is a frequent source
  of support tickets.
