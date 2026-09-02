Even when your deeplink configuration is correct, browser and OS behavior can still prevent app opening. The most common cases are listed below.

<table>
	<thead>
		<tr>
			<th>Platform</th>
			<th>Issue</th>
			<th>Explanation / recommendation</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>Android</td>
			<td>App links don't work in Samsung Internet Browser</td>
			<td>
				The Samsung Internet Browser app has a safety feature that blocks any app link from working. They believe it's more safe to open an URL in browser instead of suddenly opening an app without user permission. This is something the user has to turn off in the settings of the Samsung Internet browser app.
				<br/>
				<img
					src="/doc/assets/deeplink/deeplink-common-samsung-internet-browser.png"
					alt="Samsung Internet setting for opening links in apps"
					style="max-width: 260px; border-radius: 6px;"
				>
			</td>
		</tr>

		<tr>
			<td>Android + iOS</td>
			<td>App links / Universal links don't work in Firefox</td>
			<td>
				The Firefox app has a setting to deny the automatic opening of an app instead of the URL.
				<br/>
				<div style="display: flex; gap: 8px; flex-wrap: wrap;">
					<img src="/doc/assets/deeplink/deeplink-common-firefox1.png" alt="Firefox setting screen 1" style="max-width: 120px; border-radius: 6px;">
					<img src="/doc/assets/deeplink/deeplink-common-firefox2.png" alt="Firefox setting screen 2" style="max-width: 120px; border-radius: 6px;">
					<img src="/doc/assets/deeplink/deeplink-common-firefox3.png" alt="Firefox setting screen 3" style="max-width: 120px; border-radius: 6px;">
				</div>
			</td>
		</tr>

		<tr>
			<td>iOS</td>
			<td>Universal links fail in Safari after cancelling popup</td>
			<td>
				Sometimes the Safari app presents a permission popup, asking if a specific URL can open an app instead. If you select CANCEL in this popup, then the universal link for the specific URL will never work again.
        <br/>
        The only solution is to clear the Safari app cache and try again.
				<br/>
				<img src="/doc/assets/deeplink/deeplink-common-safari.jpeg" alt="Safari prompt for opening app" style="max-width: 120px; border-radius: 6px;">
			</td>
		</tr>

		<tr>
			<td>Android + iOS</td>
			<td>Usage of Chrome Custom Tab or similar in-app browser</td>
			<td>If the redirect happens within a Chrome Custom Tab or a similar in-app browser, the final link might be treated as a regular web link instead of a deeplink, causing it to open in the browser rather than in the app.
      <br/>
      Always open the deeplink in the default browser app instead of in-app browsers.</td>
		</tr>

		<tr>
			<td>Android + iOS</td>
			<td>Time delays and timing issues</td>
			<td>Delays between redirects can break deeplink resolution. Keep the redirect chain short and immediate.</td>
		</tr>

		<tr>
			<td>Android + iOS</td>
			<td>Browser caching issues</td>
			<td>	
Caching mechanisms involved in the redirect chain might hold onto outdated or cached information, interfering with the proper handling of the App Link and causing it to not open the app.</td>
		</tr>

		<tr>
			<td>Android + iOS</td>
			<td>Too many redirects without user action</td>
			<td>
				<strong>Redirect Handling:</strong> Modern browsers on Android, such as Chrome, have implemented security measures to prevent unwanted redirects. If a deeplink is triggered after a redirect, the browser might block or ignore the link to avoid potential security risks, resulting in the link not opening in the app.
<br/><br/>
<strong>Mixed Content:</strong> If the redirect involves switching between different protocols (e.g., from http to https or vice versa), the browser might block the deeplink due to mixed content rules or other security concerns.
<br/><br/>
<strong>App Link Verification:</strong> Deeplinks require the target domain to be associated with the app through the assetlinks.json file. After a redirect, this association might not be properly recognized by the OS, causing the App Link to fail to open in the app.
<br/><br/>
<strong>User-Initiated Actions:</strong> After a redirect, the browser or OS may require a user-initiated action (like a tap) to open the deeplink in the app. If the deeplink is triggered automatically without such an interaction, it might not work as expected.
			</td>
		</tr>

		<tr>
			<td>iOS</td>
			<td>The universal link has no content</td>
			<td>When using universal links, Apple requires that the page has some content.
If the page returns an error, for example a 404, this response will be cached and the URL will not reach the application.</td>
		</tr>

		<tr>
			<td>iOS</td>
			<td>Safari refuses to open a universal link in the correct app</td>
			<td>When the fallback page of a universal link once resulted in an SSL error or a 404, the result is cached.
Any future attempts to open an app with its universal link will fail.

To remedy this:
<br/>
- Go to Settings > Safari
<br/>
- Scroll down to the “History and website data section”
<br/>
- Press “Remove History and Website Data”</td>
		</tr>

		<tr>
			<td>iOS</td>
			<td>CODIT & default browser app</td>
			<td>When you still use the CODIT setup and change the default browser on your iPhone from Safari to something else, it’s possible that the deeplink will fail because the itsme webpage applies a redirect without user interaction.</td>
		</tr>

		<tr>
			<td>iOS 26.2+</td>
			<td>Redirect from itsme app to browser/ app does not work</td>
			<td>Since iOS 26.2, Apple allows the Safari browser to be removed (EU requirement) and be replaced with any other browser app.

Due to a bug, this can have the side-effect that external links from any app (including the itsme app) no longer open. Reinstalling the Safari app fixes this.</td>
		</tr>
	</tbody>
</table>

