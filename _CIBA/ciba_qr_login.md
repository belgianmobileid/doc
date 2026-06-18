---
layout: ciba
title: CIBA QR login API
permalink: ciba-qr-login/
nav_order: 1
toc_list: true
---

# Overview

itsme® API supports an authentication flow based on the OpenID Connect CIBA (Client-Initiated Backchannel Authentication) specification. This flow enables partners to authenticate users in a host-to-host manner, without requiring any front-end interaction.

Since there is no direct interaction, the Client must provide a user identifier in the backchannel authentication request.

To support use cases where the Client does not have such a user identifier in advance, itsme® provides a proprietary User Discovery Flow. This flow allows the Client to obtain a user identifier prior to initiating CIBA authentication.

The User Discovery Flow involves displaying a QR code on the Client's frontend, which the user scans using their itsme® mobile app. Upon scanning, the mobile app identifies the user and communicates with the itsme® backend, enabling the Client to receive a valid user identifier that can then be used to initiate a standard CIBA flow.

The diagram below describes both the User Discovery Flow & the OIDC CIBA Flow and how your systems should integrate with itsme®. A more extensive explanation of the flow can be found under Guides.

![Partner POV OIDC CIBA QR Ping flow](/doc/public/images/pov_partner_oidc_ciba_qr_ping.png)

![Partner POV OIDC CIBA QR Poll flow](/doc/public/images/pov_partner_oidc_ciba_qr_poll.png)



# Onboarding

To make use of the itsme® OIDC CIBA API, you will need to contact our Customer Care team at <a href="mailto:onboarding@itsme-id.com">onboarding@itsme-id.com</a>. Based on your requirements, they will invite you to our self-service Portal where you will be able to configure an account. A clientID will be generated and linked to your account, which you will need to include in these requests:

<ul>
  <li><code>POST /user_discovery_sessions</code></li>
  <li><code>POST /user_discovery_sessions/{user_discovery_session_id}</code></li>
  <li><code>POST /backchannel/authentication</code></li>
  <li><code>POST /token</code></li>
</ul>

Each partner can configure multiple "services" in the portal. Each service should correspond to one user flow on your side and can be of type Authentication, Identification, Confirmation or Data Sharing. The service code will also be required in your backchannel Authentication Request.

<aside class="notice">Unlike redirect-based flows, there is no need to provide or whitelist redirect URIs for OIDC CIBA.</aside>



{% include_relative chapters/guides.md %}

## Request QR Code for User Discovery Flow

To use the User Discovery Flow via QR code, follow these steps:

<ol>
  <li><b>Initiate the User Discovery Session:</b> The user clicks a button on the partner's device to trigger the partner to call <code>POST /user_discovery_session</code>.<br><br>
    Partner calls endpoint <code>POST /user_discovery_sessions</code> to create a new user discovery session. The response will include a QR code and a unique session identifier.<br><br>
    The response may contain an <code>interval</code> value. The Partner is allowed to poll the session status via the <code>POST /user_discovery_sessions/{user_discovery_session_id}</code> endpoint every <code>interval</code> seconds. If no interval value is present, default to 5 seconds.
  </li>
  <li><b>Display the QR Code:</b> Show the QR code from the response on the partner's device (web page, kiosk, terminal, etc.) for the user to scan with the itsme® app.</li>
  <li><b>User Discovery Poll for Session Status:</b> Partner regularly polls endpoint <code>POST /user_discovery_sessions/{user_discovery_session_id}</code> using the session identifier to check the status of the session.<br><br>
    If the status is <code>PENDING_USER_DISCOVERY</code>, the QR code has not yet been scanned. The endpoint can return a new QR code in the response, which will need to replace the old QR code on the partner's device.<br><br>
    The response may contain an <code>interval</code> value. The Partner is allowed to poll the endpoint every <code>interval</code> seconds. If no interval value is present, default to 5 seconds.<br><br>
    Polling more frequently than allowed will result in a HTTP 429 error "Too many requests. Returned when the Client does not respect the polling interval."<br><br>
    Stop polling after 10 min when the response <code>USER_DISCOVERED</code> is still not received. A HTTP 400 error will be returned when polling too long.<br><br>
    If the status is <code>USER_DISCOVERED</code>, the QR code has been scanned and the response will include a <code>user_identifier_token</code>. This token can be used in the OIDC CIBA backchannel Authentication request.<br><br>
    Stop polling the endpoint once a response with this status is received.
  </li>
</ol>



## Initiating the OIDC CIBA Flow

Once you have obtained the <code>user_identifier_token</code> from the User Discovery Flow, you can initiate the OIDC CIBA backchannel authentication request:

<ol>
  <li><b>Start the OIDC CIBA flow:</b> Partner calls endpoint <code>POST /backchannel/authentication</code>, including the <code>user_identifier_token</code> as the <code>login_hint_token</code> parameter, along with your client credentials and any required scopes/claims. Currently we only support signed authentication requests. The response will include an <code>auth_request_id</code>.</li>
  <li><b>Receiving the authentication result:</b> When the user has completed authentication in the itsme® app, the partner will receive an <code>access_token</code> and <code>id_token</code>.<br><br>
    We support the POLL and PING token delivery modes. Please let our Onboarding team know which flow you want to implement.
    <ul>
      <li><b>CIBA Ping mode:</b> Once the end user has confirmed the action in their itsme® app, we will send a POST request on your preregistered callback endpoint. That request will contain your <code>client_notification_token</code> as a bearer token. It will use the <code>application/json</code> media type and will only contain the <code>auth_req_id</code> as body content.<br><br><img src="/doc/public/images/oidc_ciba_ping.png" alt="OIDC CIBA Ping mode"></li>
      <li><b>CIBA Poll mode:</b> Partner polls endpoint <code>POST /token</code> with the <code>auth_request_id</code> for the authentication result. The response may contain an <code>interval</code> value. The Partner is allowed to poll the endpoint every <code>interval</code> seconds. If no interval value is present, default to 5 seconds. Polling more frequently than allowed will result in a <code>slow_down</code> error.<br><br><img src="/doc/public/images/oidc_ciba_poll.png" alt="OIDC CIBA Poll mode"></li>
    </ul>
  </li>
  <li><b>Retrieve user data:</b> Use <code>GET /userinfo</code> with the <code>access_token</code> to retrieve the user's attributes and metadata.</li>
</ol>



## Securing the exchange of information

To protect the exchange of sensitive information and ensure the requested information gets issued to a legitimate application and not some other party, the OpenID Connect protocol uses JSON Web Token (JWT) which can be signed and/or encrypted.

Among the methods described in the OpenID specification, itsme® supports only Private Key JWT to secure communications between your backend and itsme® for the CIBA QR Process. Client Secret is not supported.

### Public-private key pair and JWKSet URI

This method uses a pair of keys (1 public, 1 private) to encrypt and decrypt senders' and recipients' sensitive data. It is also known as public-key cryptography or asymmetric encryption.

<aside class="notice">This method requires that each party exposes its public keys in the form of a JWK Set document on a publicly accessible URI, and keeps its private keys for itself.</aside>

You can retrieve the itsme® JWK Set from the URI mentioned as <code>jwks_uri</code> in our itsme® Discovery document.

<aside class="notice">Refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more on signing and encrypting tokens.</aside>

<aside class="notice">Whatever the tool you are choosing to create your key pairs, don't forget to send your JWK Set URI by email to <a href="mailto:onboarding@itsme-id.com">onboarding@itsme-id.com</a> and itsme® will make sure to complete the configuration for you in no time!</aside>

<aside class="notice">The algorithms - needed to sign and encrypt a JWT - are listed in the itsme® Discovery document.</aside>

### Key rotation procedure

itsme® backend has a cache mechanism in place, which is sporadic (from 30min to 24h). During this time, we will keep on using old keys.

<aside class="notice">Use the <code>Cache-Control: max-age=</code> HTTP header (min 30min) to lower waiting time.</aside>

#### Rotating signing key:
<ul>
  <li>Add the new key to JWK set, with a new "kid"</li>
  <li>Start using the new key to sign JWTs</li>
  <li>When the flow is validated with the new key, remove the old one from the JWK set</li>
</ul>

#### Rotating encryption key:
<ul>
  <li>Replace the old key with the new one in JWK set, but still support old and new keys in decryption process</li>
  <li>Wait 24h (or wait for "max-age" amount of time, if specified)</li>
  <li>Decommission the old key completely</li>
</ul>

Changing the key could come along with changing the jwkset url. If that is the case, communicate the new available jwkset url to <a href="mailto:onboarding@itsme-id.com">onboarding@itsme-id.com</a>. It is not possible to be perfectly in sync, a few failed flows should be expected in the lapse of time between jwkset url update and the key update at the partner's side. Smoother way would be:
<ul>
  <li>Copy the old jwkSet on the new URL</li>
  <li>The URL is communicated & registered by itsme®</li>
  <li>Rotate the keys in the jwkSet on the new URL as per rotating keys info above</li>
</ul>

### Signing, encrypting and decoding JWTs

Libraries implementing JWT and the JOSE specs JWS, JWE, JWK, and JWA are listed <a href="https://openid.net/certified-open-id-developer-tools/" target="blank">here</a>. For testing purposes only, we could advise the use of <a href="https://mkjwk.org/" target="blank">https://mkjwk.org/</a> for JWK generation and for payload check - these are 2 open-source tools which will help you visualize JWK mechanisms, client assertion construct. Please DO NOT generate production private keys on any website. Rather opt for the relevant SDK library mentioned <a href="https://openid.net/certified-open-id-developer-tools/" target="blank">here</a>.

### Token Confidentiality

All tokens issued by itsme® must be treated as confidential. These tokens must never be exposed to the user, browser, or any third party, and must only be used server-to-server.

List of all the issued tokens: <code>user_identifier_token</code>, <code>auth_req_id</code>, <code>access_token</code>, <code>refresh_token</code> and <code>client_notification_token</code>.

{% include_relative chapters/certificates_and_website_security.md %}

## Handling responses

Whenever a partner is sending a request to itsme®, they will get a response back. The format and content of the response depend on the endpoint and the flow.

Alongside the type of response, an HTTP status code is sent that shows whether the request was successful or not. If it was not, you can tell by the code and the message in the response what went wrong, why it went wrong and whether there is something the partner can do about it.

### A successful response

An HTTP status <code>200 OK</code> is issued whenever your request was a success.

You see this type of response in our examples like the one where we successfully retrieve the Token Response:

```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache

{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ....",
  "access_token": "SlAV32hkKG",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

### The error responses

Things will sometimes go wrong. For both the User Discovery Flow as the OIDC CIBA flow, a number of rules regarding the format of errors returned from our endpoints are defined.

***User Discovery Endpoints errors***

Same for both endpoints <code>POST /user_discovery_sessions</code> & <code>POST /user_discovery_sessions/{user_discovery_session_id}</code>.

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="400 Bad Request" req="" %}</td>
      <td>Authentication request not valid.<br>This will be the response after polling the endpoint for 15 min with same <code>{user_discovery_session_id}</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="401 Unauthorized" req="" %}</td>
      <td>Client authentication failed.</td>
    </tr>
  </tbody>
</table>

***Authentication Endpoint errors***

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="error" req="REQUIRED" %}</td>
      <td>A single ASCII error code.
        <table>
          <tr>
            <td>{% include parameter.html name="invalid_request" req="" %}</td>
            <td>The request is missing a required parameter, includes an invalid parameter value, includes a parameter more than once, or is otherwise malformed.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="invalid_scope" req="" %}</td>
            <td>The requested scope is invalid, unknown, or malformed.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="expired_login_hint_token" req="" %}</td>
            <td>The <code>login_hint_token</code> provided in the authentication request is not valid because it has expired.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="unknown_user_id" req="" %}</td>
            <td>The OpenID Provider is not able to identify which end-user the Client wishes to be authenticated by means of the hint provided in the request (<code>login_hint_token</code>).</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="unauthorized_client" req="" %}</td>
            <td>Unknown or unspecified <code>client_id</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="invalid_client" req="" %}</td>
            <td>Client authentication failed (e.g., invalid client credentials, unknown client, no client authentication included, or unsupported authentication method). HTTP 401.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="access_denied" req="" %}</td>
            <td>The User or the Authentication Endpoint denied the request. HTTP 403.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="error_description" req="OPTIONAL" %}</td>
      <td>Human-readable text providing additional information, used to assist the developer in understanding the error that occurred.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="error_uri" req="OPTIONAL" %}</td>
      <td>A URI identifying a human-readable web page with information about the error to provide the client developer with additional information.</td>
    </tr>
  </tbody>
</table>

For example:

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "unauthorized_client",
  "error_description": "The client 'client.example.org' is not allowed to use CIBA."
}
```

***Token Endpoint errors***

If the request fails the Token Endpoint responds with an HTTP 400 (Bad Request) status code (unless specified otherwise) and includes the following parameters in the entity-body of the HTTP response using the <code>application/json</code> media type:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="error" req="REQUIRED" %}</td>
      <td>A single ASCII error code.
        <table>
          <tr>
            <td>{% include parameter.html name="invalid_request" req="" %}</td>
            <td>The request is missing a required parameter, includes an unsupported parameter value (other than grant type), repeats a parameter, includes multiple credentials, utilizes more than one mechanism for authenticating the client, or is otherwise malformed.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="invalid_grant" req="" %}</td>
            <td>The provided Authorization grant (e.g., Authorization code, resource owner credentials) is invalid or expired.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="authorization_pending" req="" %}</td>
            <td>The authorization request is still pending as the end-user hasn't yet been authenticated.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="slow_down" req="" %}</td>
            <td>A variant of "authorization_pending", the authorization request is still pending and polling should continue, but the interval MUST be increased by at least 5 seconds for this and all subsequent requests.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="expired_token" req="" %}</td>
            <td>The <code>auth_req_id</code> has expired. The Client will need to make a new Authentication Request.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="access_denied" req="" %}</td>
            <td>The end-user denied the authorization request.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="unauthorized_client" req="" %}</td>
            <td>The authenticated client is not authorized to use this authorization grant type. Can also be caused by an invalid <code>client_assertion</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="invalid_client" req="" %}</td>
            <td>Client authentication failed (e.g., unknown client, no client authentication included, or unsupported authentication method). HTTP 401.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="detail" req="OPTIONAL" %}</td>
      <td>Human-readable text providing additional information, used to assist the developer in understanding the error that occurred.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="uid" req="OPTIONAL" %}</td>
      <td>A URI identifying a human-readable web page with information about the error to provide the client developer with additional information.</td>
    </tr>
  </tbody>
</table>

For example:

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "authorization_pending",
  "detail": "User has not completed authentication yet."
}
```

***UserInfo Endpoint errors***

When a request fails, the UserInfo Endpoint responds using the appropriate HTTP status code (typically, 400, 401, 403, or 405) and includes specific error codes in the response.

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="invalid_request" req="" %}</td>
      <td>The request is missing a required parameter, includes an unsupported parameter or parameter value, repeats the same parameter, uses more than one method for including an access token, or is otherwise malformed.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="invalid_token" req="" %}</td>
      <td>The access token provided is expired, revoked, malformed, or invalid for other reasons.</td>
    </tr>
  </tbody>
</table>

For example:

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer realm="example"
```



{% include_relative chapters/mapping_the_user.md %}

{% include_relative chapters/user_data.md %}

{% include_relative chapters/api_reference.md %}

{% include_relative chapters/itsme_discovery_document.md %}

## User Discovery Request

<b><code>POST https://idp.[e2e/prd].itsme.services/v2/user_discovery_sessions</code></b>

<b><code>POST https://idp.[e2e/prd].itsme.services/v2/user_discovery_sessions/{user_discovery_session_id}</code></b>

### Parameters

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>It identifies your application. This parameter value is generated during registration.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_assertion" req="REQUIRED" %}</td>
      <td>Is a set of identity and security information, in the form of a JWT, used as an authentication method. The JWT MUST be signed, and MAY also be encrypted. If both signing and encryption are performed, it MUST be signed then encrypted, with the result being a Nested JWT.<br><br>
        The JWT contains the following claims.
        <table>
          <tr>
            <td>{% include parameter.html name="iss" req="REQUIRED" %}</td>
            <td>The issuer of the token. This value MUST be the same as the <code>client_id</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="sub" req="REQUIRED" %}</td>
            <td>The subject of the token. This value MUST be the same as the <code>client_id</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="aud" req="REQUIRED" %}</td>
            <td>The full URL of the resource you're using the JWT to authenticate to. Set this to <code>https://idp.[e2e/prd].itsme.services/v2/backchannel/authentication</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="jti" req="REQUIRED" %}</td>
            <td>A unique identifier for the token, containing maximum 255 characters.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="exp" req="REQUIRED" %}</td>
            <td>The expiration time of the token in seconds since January 1, 1970 UTC.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="iat" req="OPTIONAL" %}</td>
            <td>The time at which the JWT was issued.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_assertion_type" req="REQUIRED" %}</td>
      <td>Specifies the type of assertion. Set this to <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code>.</td>
    </tr>
  </tbody>
</table>

### Example

```http
POST https://idp.[e2e/prd].itsme.services/v2/user_discovery_sessions
Host: idp.[e2e/prd].itsme.services
Content-Type: application/x-www-form-urlencoded

client_assertion=eyJraWQiO...
&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer
```

### Response — PendingUserDiscoverySession

<code>200</code> <code>application/json</code>

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="user_discovery_session_id" req="" %}</td>
      <td>Unique session identifier as a string.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="status" req="" %}</td>
      <td><code>PENDING_USER_DISCOVERY</code></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="qr_code" req="" %}</td>
      <td>Base64-encoded image of the QR code. The QR code might differ from the previous one (dynamic QR code).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="expires_at" req="" %}</td>
      <td>String in <code>YYYY-MM-DDThh:mm:ssZ</code> date format specified by ISO 8601.</td>
    </tr>
  </tbody>
</table>

#### Example

```json
{
  "user_discovery_session_id": "abcdef...",
  "status": "PENDING_USER_DISCOVERY",
  "user_discovery_token": {
    "qr_code": "/9j/4AAQSkZJRgABAQAAZABk...",
    "expires_at": "2025-01-01T00:00:00Z"
  }
}
```

### Response — DiscoveredUserDiscoverySession

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="user_discovery_session_id" req="" %}</td>
      <td>Unique session identifier as a string.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="status" req="" %}</td>
      <td><code>USER_DISCOVERED</code></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="user_identifier_token" req="" %}</td>
      <td>This token is a single-use user identifier. It is used to initiate the Authentication process in the OIDC CIBA Flow (<code>POST /backchannel/authentication</code>), and is not a persistent user identifier. It cannot be used to map or store user accounts in your database for future sessions.</td>
    </tr>
  </tbody>
</table>

#### Example

```json
{
  "user_discovery_session_id": "abcdef...",
  "status": "USER_DISCOVERED",
  "user_identifier_token": "abcdef..."
}
```



## Authentication Request

<b><code>POST https://idp.[e2e|prd].itsme.services/v2/backchannel/authentication</code></b>

<aside class="notice">Depending on the identity document used to create an itsme® account and the country issuing it, not all claims are always available or formatted the same way.</aside>

### Signed authentication Request

This endpoint only accepts a signed Request Object (request JWT). All authentication parameters need to be included as claims. Requests with plain form parameters are not supported.

### Parameters

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="request" req="REQUIRED" %}</td>
      <td>A signed JWT containing all authentication parameters as claims.
        <table>
          <tr>
            <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
            <td>It identifies your application. This parameter value is generated during registration.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="scope" req="REQUIRED" %}</td>
            <td>It allows your application to express the desired scope of the access request. All scope values must be space-separated. The basic (and required) scopes are <code>openid</code> and <code>service</code>.
              <table>
                <tr>
                  <td>{% include parameter.html name="service" req="REQUIRED" %}</td>
                  <td>It indicates the itsme® service your application intends to use, e.g. <code>service:TEST_code</code>.</td>
                </tr>
                <tr>
                  <td>{% include parameter.html name="openid" req="REQUIRED" %}</td>
                  <td>It indicates that your application intends to use the OpenID Connect protocol to verify a user's identity by returning a <code>sub</code> claim.</td>
                </tr>
                <tr>
                  <td>{% include parameter.html name="profile" req="OPTIONAL" %}</td>
                  <td>Returns <code>family_name</code>, <code>given_name</code>, <code>name</code>, <code>gender</code>, <code>locale</code>, <code>picture</code> and <code>birthdate</code>.</td>
                </tr>
                <tr>
                  <td>{% include parameter.html name="email" req="OPTIONAL" %}</td>
                  <td>Returns the <code>email</code> claim and <code>email_verified</code>.</td>
                </tr>
                <tr>
                  <td>{% include parameter.html name="address" req="OPTIONAL" %}</td>
                  <td>Returns <code>address_assurance_level</code> claim and user's postal address as a JSON Object containing <code>formatted</code>, <code>street_address</code>, <code>postal_code</code>, <code>locality</code>.</td>
                </tr>
                <tr>
                  <td>{% include parameter.html name="phone" req="OPTIONAL" %}</td>
                  <td>Returns the <code>phone_number</code> claim and <code>phone_number_verified</code>.</td>
                </tr>
                <tr>
                  <td>{% include parameter.html name="idDocument" req="OPTIONAL" %}</td>
                  <td>Returns <code>IDDocumentSN</code>, <code>IDDocumentType</code>, <code>IDIssuingCountry</code>, <code>validityFrom</code> and <code>validityTo</code>.</td>
                </tr>
                <tr>
                  <td>{% include parameter.html name="eid" req="OPTIONAL" %}</td>
                  <td>Returns <code>BENationalNumber</code> and <code>BEeidSn</code>.</td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td>{% include parameter.html name="login_hint_token" req="REQUIRED" %}</td>
            <td>The user identifier token you receive from the discovery step. This token must be wrapped in a JWT with the following payload:<br>
              <code>{ "type": "user_identifier_token", "value": "&lt;user_identifier_token&gt;" }</code><br>
              The JWT (in compact serialization) is then used as the value for the <code>login_hint_token</code> parameter.
            </td>
          </tr>
          <tr>
            <td>{% include parameter.html name="id_token_hint" req="NOT SUPPORTED" %}</td>
            <td>Not accepted in this API. Use <code>login_hint_token</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="login_hint" req="NOT SUPPORTED" %}</td>
            <td>Not accepted in this API. Use <code>login_hint_token</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="acr_values" req="OPTIONAL" %}</td>
            <td>Indicates the authentication method required to process the request.
              <table>
                <tr>
                  <td>{% include parameter.html name="http://itsme.services/v2/claim/acr_basic" req="" %}</td>
                  <td>It lets the user choose either fingerprint usage (if device is compatible) or itsme® code. This is the default if <code>acr_values</code> is not specified.</td>
                </tr>
                <tr>
                  <td>{% include parameter.html name="http://itsme.services/v2/claim/acr_advanced" req="" %}</td>
                  <td>It forces the user to use his itsme® code.</td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td>{% include parameter.html name="requested_expiry" req="OPTIONAL" %}</td>
            <td>A positive integer that allows the client to suggest the desired lifetime (in seconds) for the pending authentication request.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="client_notification_token" req="REQUIRED IN PING" %}</td>
            <td>Mandatory in PING mode. A bearer token to be used by itsme® when sending our PING. Max 1024 chars.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_assertion_type" req="REQUIRED" %}</td>
      <td>Specifies the type of assertion. Set this to <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_assertion" req="REQUIRED" %}</td>
      <td>Is a set of identity and security information, in the form of a JWT, used as an authentication method. The JWT MUST be signed, and MAY also be encrypted.<br><br>
        The JWT contains the following claims.
        <table>
          <tr>
            <td>{% include parameter.html name="iss" req="REQUIRED" %}</td>
            <td>The issuer of the token. This value MUST be the same as the <code>client_id</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="sub" req="REQUIRED" %}</td>
            <td>The subject of the token. This value MUST be the same as the <code>client_id</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="aud" req="REQUIRED" %}</td>
            <td>The full URL of the resource you're using the JWT to authenticate to. Set this to <code>https://idp.[e2e/prd].itsme.services/v2/token</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="jti" req="REQUIRED" %}</td>
            <td>A unique identifier for the token, containing maximum 255 characters.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="exp" req="REQUIRED" %}</td>
            <td>The expiration time of the token in seconds since January 1, 1970 UTC.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="iat" req="OPTIONAL" %}</td>
            <td>The time at which the JWT was issued.</td>
          </tr>
        </table>
      </td>
    </tr>
  </tbody>
</table>

### Example

```http
POST https://idp.[e2e|prd].itsme.services/v2/backchannel/authentication
Host: idp.[e2e/prd].itsme.services
Content-Type: application/x-www-form-urlencoded

request=eyJraWQiOi...
&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer
&client_assertion=eyJraWQiOiJsdGFjZXNidy...
```

Where the following is the JWT payload of <code>request</code>:

```json
{
  "aud": "https://idp.e2e.itsme.services/v2",
  "login_hint_token": {
    "type": "subject_code",
    "value": "mqxews5ukc53ltb1jgj9qe9rnfnwwhyga18m"
  },
  "nbf": "2023-08-25T14:56:12.870Z",
  "scope": "openid service:TEST_LOGIN profile email",
  "iss": "s6BhdRkqt3",
  "claims": "{id_token:{name:null,gender:null}}",
  "exp": "1712757579",
  "iat": "1712757579",
  "jti": "4LTCqACC2ESC5BWCnN3j58EnA"
}
```

### Response

<code>200</code> <code>application/json</code>

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="auth_req_id" req="REQUIRED" %}</td>
      <td>Unique identifier of the authentication request, generated by the OpenID Provider. Used by the client to poll the token endpoint. Treated as opaque.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="expires_in" req="REQUIRED" %}</td>
      <td>Lifetime of the <code>auth_req_id</code> in seconds. After this period, the client must not use it.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="interval" req="OPTIONAL" %}</td>
      <td>Minimum number of seconds the client must wait between token polling requests. Default is 5 if not provided.</td>
    </tr>
  </tbody>
</table>

#### Example

```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store

{
  "auth_req_id": "1c266114-a1be-4252-8ad1-04986c5b9ac1",
  "expires_in": 120,
  "interval": 2
}
```



{% include_relative chapters/ping_callback.md %}

{% include_relative chapters/token_request.md %}

{% include_relative chapters/userinfo_request.md %}


