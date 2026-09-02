# Fallback web page

If you have integrated itsme in a specific flow that can only be completed in your app and not in browser, we highly recommend to provide a fallback web page in case the deeplink fails.

# Scenario

1. The user opens your app on their tablet and they click on a button to authorize something via itsme.
2. Itsme is opened in the default browser app, but the itsme app is not launched because they have itsme not installed on their tablet.
3. The user completes the itsme action on their phone.
4. Once completed, the itsme web page on the tablet will automatically redirect to your redirect URL.

**The problem:** this last redirect does not open your app — the user is left on a webpage with no way to continue.

There are a lot of known issues that deeplinks are not triggered when there are too many page redirects. 
It's required to have user interaction in between, like a button click.

# Solution

<div style="display: flex; gap: 1.5rem; align-items: flex-start; flex-wrap: wrap;">
  <div style="flex: 1; min-width: 260px;">
    <p>
      Rather than relying on an automatic redirect, implement a <strong>fallback web page</strong> that is
      displayed when the deeplink cannot be triggered automatically. This page shows a button the user can
      tap to open the app themselves.
    </p>
    <p>
      Because the tap is a direct user action, the OS will correctly open the native app.
    </p>
    <p>
      The button must open the URL in a <strong>new tab</strong>. Opening it in the same tab can cause
      the browser to cache the page and prevent the deeplink from firing.
    </p>
  </div>
  <div style="flex-shrink: 0;">
  <p>Example from KBC</p>
    <img
      src="/doc/assets/deeplink/deeplink-fallback.webp"
      alt="KBC fallback page with open-in-app button"
      style="max-width: 220px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.12);"
    >
  </div>
</div>
