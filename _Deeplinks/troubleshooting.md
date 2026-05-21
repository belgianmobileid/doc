---
layout: deeplinks
title: Troubleshooting
permalink: deeplinks-troubleshooting/
nav_order: 4
toc_list: true
---

# Deeplink issues when opening itsme

You have integrated itsme in your application but when you try to open the itsme app, it doesn’t work. You stay in browser when you expect the itsme app to be opened.

<div class="fc-flow">
<table class="fc-plain">
  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">Is the itsme URL opened inside a webview?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">No ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">Yes →</span><div class="fc-outcome fc-warn">Always open the itsme URL in the default browser app. Deeplinks do not work reliably inside webviews.</div></td>
  </tr>
  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">Send yourself the exact itsme URL by email, open it on mobile and tap it. Does the itsme® app open?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">No ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">Yes →</span><div class="fc-outcome fc-warn">The itsme URL is correctly constructed. Review your implementation for opening this URL with the default browser.</div></td>
  </tr>
  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">When the itsme URL is loaded in the browser, do you see page redirects?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">No ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">Yes →</span><div class="fc-outcome fc-warn">This should not be the case. Please review the implementation with the itsme support team.</div></td>
  </tr>
  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">Does the issue occur on every device (both iOS and Android)?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">Yes, both ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">Only one →</span><div class="fc-outcome fc-warn">Review most common issues <a href="/doc/deeplinks-issues/">here</a>.</div></td>
  </tr>
  <tr>
    <td class="fc-q" colspan="2"><div class="fc-outcome fc-warn">Please review the itsme URL you construct and make sure it follows the guidelines and applies correct encoding.</div></td>
  </tr>
</table>
</div>


# Deeplink issues when opening your app

When the flow at itsme side is finished, you expect your app to open but this does not happen.

<div class="fc-flow">
<table class="fc-plain">
  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">Do you stay in the itsme® app while you expect your webpage or mobile app to open?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">No ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">Yes →</span><div class="fc-outcome fc-warn">Does this occur on every device (iOS and Android)? If yes, review with itsme support whether your <code>redirect_uri</code> is correctly configured. If only one platform is affected, review most common issues <a href="/doc/deeplinks-issues/">here</a>.</div></td>
  </tr>

  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">Are you testing with one device (itsme app + your app installed) or with two separate devices?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">1 device ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">2 devices →</span><div class="fc-outcome fc-warn">Implement a fallback webpage as described <a href="/doc/deeplinks-fallback/">here</a>.</div></td>
  </tr>

  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">The URL opens in the default browser but does not open your app. Look at the URL in the browser searchbar, is it correctly constructed as you expect?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">Yes ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">No →</span><div class="fc-outcome fc-warn">Please review with itsme support whether your <code>redirect_uri</code> is correctly configured.</div></td>
  </tr>

  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">When your URL is opened in the browser, do you see page redirects happen?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">No ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">Yes →</span><div class="fc-outcome fc-warn">Review your implementation and avoid intermediate redirects before the final deeplink URL. Also ensure your redirect URL is a valid page (no HTTP 404 redirect flow).</div></td>
  </tr>

  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">Send the redirect URL to yourself by email, open the email on your mobile device and click on the URL. Does your app open?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">Yes ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">No →</span><div class="fc-outcome fc-warn">Please review your AASA / <code>assetlinks.json</code> configuration.</div></td>
  </tr>

  <tr>
    <td class="fc-q" colspan="2"><div class="fc-decision">Does the issue occur on every device (both iOS and Android)?</div></td>
  </tr>
  <tr>
    <td class="fc-arrow-cell"><span class="fc-badge">Yes, both ↓</span></td>
    <td class="fc-exit-cell"><span class="fc-badge fc-badge-yes">Only one →</span><div class="fc-outcome fc-warn">Review most common issues <a href="/doc/deeplinks-issues/">here</a>.</div></td>
  </tr>
  <tr>
    <td class="fc-q" colspan="2"><div class="fc-outcome fc-warn">Please contact itsme support for further investigation.</div></td>
  </tr>
</table>
</div>