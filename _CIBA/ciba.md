---
layout: ciba
title: CIBA QR flow
permalink: /ciba
nav_exclude: false
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

# Guides

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

## Certificates and website security

itsme® requires <code>https</code> connections to guarantee security. With the <code>https</code> protocol, a web site operator obtains a certificate by applying to a certificate authority with a certificate signing request. The certificate request is an electronic document that contains the web site name, company information and the public key. The certificate provider signs the request, thus producing a public certificate. During web browsing, this public certificate is served to any web browser that connects to the web site and proves to the web browser that the provider believes it has issued a certificate to the owner of the web site.

A certificate provider can opt to issue three types of certificates, each requiring its own degree of vetting rigor. In order of increasing rigor (and naturally, cost) they are: Domain Validation, Organization Validation and Extended Validation.

The Domain Validation certificate doesn't provide sufficient identity guarantees to itsme®. So, <b>only the Organization Validation and Extended Validation certificates</b> are supported. For example, using the Let's Encrypt open certificate authority is not sufficient because it only provide standard Domain Validation certificates.

<aside class="notice">The chain of trust of these certificates need to be publicly accessible, meaning that our systems need to be able to access the root and the intermediate certificates.</aside>

<aside class="notice">All itsme® API URL we publish use <code>https</code>.</aside>

<aside class="notice">All requests to our endpoints MUST also use the SNI extension (refer to the <a href="https://datatracker.ietf.org/doc/html/rfc6066#section-3">RFC 6066</a> for more information) of the TLS protocol, that allows our servers to provide you with the correct certificate based on which endpoint you are querying.</aside>

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

## Mapping the user

### Mapping using sub claim

To sign in successfully in your web desktop, mobile web or mobile application, a given user must be mapped to a user account in your database. By default, your application Server will use the subject identifier, or sub claim, in the ID Token to identify and verify a user account. The sub claim is a string that uniquely identifies a given user account. The benefit of using a sub claim is that it will not change, even if other user attributes (email, phone number, etc) associated with that account are updated.

If no user record is storing the sub claim value, then you should allow the user to associate his new or existing account to the sub.

### Benefit of sub claim

The benefit of using a sub claim is that it will not change, not even if other user attributes (email, phone number, etc.) associated with that account are updated.

### Deleting and re-creating an itsme® account

In a limited number of cases (e.g. technical issue,...) a user could ask itsme® to ‘delete' his account. As a result the specific account will be ‘archived' (for compliancy reasons) and thus also the unique identifier(s) (e.g. "sub").

If the same user would opt to re-create an itsme® afterwards, he will need to re-bind his itsme® account with your application server, in the same way as for the initial binding. After successful re-binding you will need to overwrite the initial reference with the new sub claim value in your database.

## User Data

itsme® makes a range of user data available for its partners. These data elements (called "claims") can be requested through the backchannel Authentication Request, either individually or as part of a broader "scope". The claims are grouped into two categories:

### User Attributes

User attributes are saying something about the end user. They are part of the identity of a person and we retrieve them from an identity document (ID card, passport...). Examples: name, address, birthdate, etc.

### Metadata

Metadata are saying something about the data we have for an end user. They are not directly related to a person, but rather to an information about this person. Examples are the validityTo, the verificationDate etc. Those metadata, if requested, will only return values relating to the user attributes that are also requested. The metadata will then return an object containing one value for each relevant user attribute.

Examples:

The verificationDate is a metadata that has a value for most user attributes. So requesting the verificationDate AND the birthdate AND the given_name will return the following pattern for verificationDate:

```text
"http://itsme.services/v2/claim/verificationDate": {
	"birthdate": "2023-06-01T13:04:26Z",
	"given_name": "2023-06-01T13:04:26Z"}
```

Requesting only the verificationDate will return nothing, as it only returns values for other requested attributes.

The validityTo metadata only has a value for BEeidSn and IDDocumentSN (because other attributes don't have an expiry date). So validityTo will only return a value if BEeidSn and/or IDDocumentSN is also requested. Even if other attributes are requested, validityTo will not return a value for those other attributes.

# API Reference

Currently, only Private Key JWT is supported for CIBA authentication. Client Secret is not supported.

## itsme® Discovery Document

### Public- And Private-Key

<b><code>GET https://idp.[e2e/prd].itsme.services/v2/.well-known/openid-configuration</code></b>

To simplify implementations and increase flexibility, OpenID Connect allows the use of a Discovery Document, a JSON document containing key-value pairs which provide details about itsme® configuration, such as the Authentication, Token and userInfo Endpoints, Supported claims, ...

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
                  <td>Returns user's postal address as a JSON Object containing <code>formatted</code>, <code>street_address</code>, <code>postal_code</code>, <code>locality</code>.</td>
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

## PING callback

This callback will only happen if your service is configured for Ping mode.

Once the end user has confirmed the action in their itsme® app, we will send a POST request on your preregistered callback endpoint. That request will contain your <code>client_notification_token</code> as a bearer token. It will use the <code>application/json</code> media type and will only contain the <code>auth_req_id</code> as body content.

You should respond to that callback by calling the endpoint <code>POST /token</code>.

### Example

```http
POST /cb HTTP/1.1
Host: idp.[e2e/prd].itsme.services
Authorization: Bearer 8d67dc78-7faa-4d41-aabd-67707b374255
Content-Type: application/json

{"auth_req_id": "1c266114-a1be-4252-8ad1-04986c5b9ac1"}
```

## Token Request

<b><code>POST https://idp.[e2e/prd].itsme.services/v2/token</code></b>

During this step, your application has to authenticate itself to our server using the public- and private-key pair method.

<aside class="notice">The parameters below must be included in the body of the POST request, not in the query string.</aside>

### Parameters

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>It identifies your application. This parameter value is generated during registration.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="grant_type" req="REQUIRED" %}</td>
      <td>Fixed value <code>urn:openid:params:grant-type:ciba</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_assertion_type" req="REQUIRED" %}</td>
      <td>Specifies the type of assertion. Set this to <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="auth_req_id" req="REQUIRED" %}</td>
      <td>Unique identifier received in the response of the authentication request, generated by the OpenID Provider. Treated as opaque.</td>
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
POST https://idp.[e2e/prd].itsme.services/v2/token
Host: idp.[e2e/prd].itsme.services
Content-Type: application/x-www-form-urlencoded

grant_type=urn%3Aopenid%3Aparams%3Agrant-type%3Aciba
&auth_req_id=YOUR_AUTH_REQ_ID
&client_id=YOUR_CLIENT_ID
&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer
&client_assertion=PHNhbWxwOl...
```

Where the following is the JWT payload of <code>client_assertion</code>:

```json
{
  "iss": "s6BhdRkqt3",
  "aud": "https://idp.e2e.itsme.services/v2/token",
  "exp": 1537820086,
  "iat": 1537819486,
  "nbf": 1537818886,
  "jti": "4LTCqACC2ESC5BWCnN3j58EnA"
}
```

### Response

<code>200</code> <code>application/json</code>

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="access_token" req="REQUIRED" %}</td>
      <td>Allows an application to retrieve consented user information from the UserInfo Endpoint.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="token_type" req="REQUIRED" %}</td>
      <td>Provides your application with the information required to successfully utilize the access token. Returned value is <code>Bearer</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="expires_in" req="REQUIRED" %}</td>
      <td>Access token lifetime (in seconds).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="id_token" req="OPTIONAL" %}</td>
      <td>A security token that contains information about the authentication of a user, and potentially other requested claim data's. The <code>id_token</code> value is represented as a signed and encrypted JWT. So, before being able to use the ID Token claims you will have to decrypt and verify the signature.</td>
    </tr>
  </tbody>
</table>

#### Example

```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store

{
  "access_token": "G5kXH2wHvUra0sHlDy1iTkDJgsgUO1bN",
  "token_type": "Bearer",
  "refresh_token": "4bwc0ESC_IAhflf-ACC_vjD_ltc11ne-8gFPfA2Kx16",
  "expires_in": 120,
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZ..."
}
```

Example of a decrypted <code>id_token</code>:

```json
{
  "sub": "6g2k9rgglem2dttw5d51ulkxpv24phwatiu6",
  "aud": "WXw9DMqkEv",
  "birthdate": "1974-10-23",
  "gender": "male",
  "name": "John Ronald R Tolkien",
  "iss": "https://idp.prd.itsme.services/v2",
  "nonce": "nonce",
  "exp": 1699538407,
  "iat": 1699538107
}
```

## Userinfo Request

<b><code>GET https://idp.[e2e/prd].itsme.services/v2/userinfo</code></b>

The UserInfo Endpoint returns previously consented user profile information to your application. In other words, if the required claims are not returned in the ID Token, you can obtain the additional claims by presenting the access token to the itsme® UserInfo Endpoint. This is achieved by sending a HTTP GET request to the Userinfo Endpoint, passing the access token value in the Authorization header using the Bearer authentication scheme.

### Response

<code>200</code> <code>application/json</code>

The UserInfo Response is represented as a signed and encrypted JWT. So, before being able to extract the claims you will have to decrypt and verify the signature.

### Example

***Request***

```http
GET /userinfo HTTP/1.1
Host: server.example.com
Authorization: Bearer SlAV32hkKG
```

***Response***

This is a response example containing all possible claims for a Belgian account:

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "http://itsme.services/v2/claim/validityFrom": {

## User Discovery Request

### Public- And Private-Key

```text
POST https://idp.[e2e/prd].itsme.services/v2/user_discovery_sessions
POST https://idp.[e2e/prd].itsme.services/v2/user_discovery_sessions/
{user_discovery_session_id}
```

#### Parameters

<table>
<tbody>
<tr><td>client_id<br>REQUIRED</td><td>It identifies your application. This parameter value is generated during registration.</td></tr>
<tr><td>client_assertion<br>REQUIRED</td><td>Is a set of identity and security information, in the form of a JWT, used as an authentication method. To ensures that the request to get the id token and access token is made only from your application, and not from a potential attacker that may have intercepted the authorization code, the JWT MUST be signed, and MAY also be encrypted. If both signing and encryption are performed, it MUST be signed then encrypted, with the result being a Nested JWT (refer to this page for more information).
The JWT contains the following claims.<br>&lt;table&gt;
&lt;tbody&gt;
&lt;tr&gt;&lt;td&gt;iss&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The issuer of the token. This value MUST be the same as the client_id.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;sub&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The subject of the token. This value MUST be the same as the client_id.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;aud&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The full URL of the resource you&amp;#x27;re using the JWT to authenticate to. Set this to https://idp.[e2e/prd.itsme.services/v2/backchannel/authentication&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;jti&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;An unique identifier for the token, containing maximum 255 characters.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;exp&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The expiration time of the token in seconds since January 1, 1970 UTC.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;iat&lt;br&gt;OPTIONAL&lt;/td&gt;&lt;td&gt;The time at which the JWT was issued.&lt;/td&gt;&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;</td></tr>
<tr><td>client_assertion_type<br>REQUIRED</td><td>Specifies the type of assertion. Set this to urn:ietf:params:oauth:client-assertion-type:jwt-bearer.</td></tr>
</tbody>
</table>

##### Example

```text
POST https://idp.[e2e/prd].itsme.services/v2/user_discovery_sessions OR
POST https://idp.[e2e/prd].itsme.services/v2/user_discovery_sessions/
{user_discovery_session_id}
Host: idp.[e2e/prd].itsme.services
Content-Type: application/x-www-form-urlencoded
client_assertion=eyJraWQiO...
&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer
```

#### Response PendingUserDiscoverySession

200 application/json

<table>
<tbody>
<tr><td>user_discovery_session_id</td><td>Unique session identifier as a string</td></tr>
<tr><td>status</td><td>PENDING_USER_DISCOVERY</td></tr>
<tr><td>qr_code</td><td>Base64-encoded image of the QR code. The QR code might differ from the previous one (dynamic QR code).</td></tr>
<tr><td>expires_at</td><td>String in YYYY-MM-DDThh:mm:ssZ date format specified by ISO 8601</td></tr>
</tbody>
</table>

##### Example

```text
{"user_discovery_session_id" : "abcdef...",
 "status" : "PENDING_USER_DISCOVERY",
 "user_discovery_token" : {
  "qr_code" : "/9j/4AAQSkZJRgABAQAAZABk...",
  "expires_at" : "2025-01-01T00:00:00Z"}}
```

#### Response DiscoveredUserDiscoverySession

<table>
<tbody>
<tr><td>user_discovery_session_id</td><td>Unique session identifier as a string</td></tr>
<tr><td>Status</td><td>USER_DISCOVERED</td></tr>
<tr><td>user_identifier_token</td><td>This token is a single-use user identifier. It is used to initiate the Authentication process in the OIDC CIBA Flow (POST /backchannel/authentication), and is not a persistent user identifier. It cannot be used to map or store user accounts in your database for future sessions.</td></tr>
</tbody>
</table>

##### Example

```text
{"user_discovery_session_id" : "abcdef...",
 "status" : "USER_DISCOVERED",
 "user_identifier_token" : "abcdef..."}}
```

## Authentication Request

### Public- And Private-Key

```text
POST https://idp.[e2e|prd].itsme.services/v2/backchannel/authentication
```

Top of Form

Note: Depending on the identity document used to create an itsme® account and the country issuing it, not all claims are always available or formated the same way. Please refer to this page to check which claims are available in which cases.

#### Signed authentication Request

This endpoint only accepts a signed Request Object (request JWT). All authentication parameters need to be included as claims. Requests with plain form parameters are not supported.

#### Parameters

<table>
<tbody>
<tr><td>Request<br>REQUIRED</td><td>&lt;table&gt;
&lt;tbody&gt;
&lt;tr&gt;&lt;td&gt;client_id&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;It identifies your application. This parameter value is generated during registration.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;scope&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;It allows your application to express the desired scope of the access request. Each scope returns a set of user attributes. The scopes an application should request depend on which user attributes your application needs. Once the user authorizes the requested scopes, his details are returned through the UserInfo Endpoint.

All scope values must be space-separated.

The basic (and required) scopes are openid and service. Beyond that, your application can ask for additional standard scopes values which map to sets of related claims are: profile email address phone eid&lt;br&gt;&amp;lt;table&amp;gt;
&amp;lt;tbody&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;service&amp;lt;br&amp;gt;REQUIRED&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;It indicates the itsme® service your application intends to use, e.g. service:TEST_code by replacing &amp;amp;quot;TEST_code&amp;amp;quot; with the service code generated during registration.&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;openid&amp;lt;br&amp;gt;REQUIRED&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;It indicates that your application intends to use the OpenID Connect protocol to verify a user&amp;amp;#x27;s identity by returning a sub claim which represents a unique identifier for the authenticated user.&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;profile&amp;lt;br&amp;gt;OPTIONAL&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;Returns claims that represent basic profile information, specifically family_name, given_name, name, gender, locale, picture and birthdate.

If requested, a value SHALL always be returned for the above claims except for the given_name claim which MAY NOT be returned if the user doesn&amp;amp;#x27;t have any first name(s).&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;email&amp;lt;br&amp;gt;OPTIONAL&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;Returns the email claim, which contains the user&amp;amp;#x27;s email address, and email_verified, which is a boolean indicating whether the email address was verified by the user.

If requested, a value SHALL always be returned for the email_verified claim only if email claim is filled with a value, whereas the email claim SHALL always be returned only if the user gave us an email address.&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;address&amp;lt;br&amp;gt;OPTIONAL&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;Returns user&amp;amp;#x27;s postal address, represented as JSON Object containing some or all of these members formatted street_address postal_code locality

If requested, a value SHALL always be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;phone&amp;lt;br&amp;gt;OPTIONAL&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;Returns the phone_number claim, which contains the user&amp;amp;#x27;s phone number, and phone_number_verified, which is a boolean indicating whether the phone number was verified by the user.

If requested, a value SHALL always be returned for the above claims.&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;idDocument&amp;lt;br&amp;gt;OPTIONAL&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;Returns the following claims, providing complete information about the ID document used to create the user&amp;amp;#x27;s itsme account:
http://itsme.services/v2/claim/IDDocumentSN
http://itsme.services/v2/claim/IDDocumentType
http://itsme.services/v2/claim/IDIssuingCountry
http://itsme.services/v2/claim/validityFrom and http://itsme.services/v2/claim/validityTo.

If requested, a value SHALL always be returned for the above claims, except for http://itsme.services/v2/claim/validityFrom which is only available on Belgian documents.&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;eid&amp;lt;br&amp;gt;OPTIONAL&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;Returns the http://itsme.services/v2/claim/BENationalNumber claim, which contains the unique identification number of natural persons who are registered in Belgium, and http://itsme.services/v2/claim/BEeidSn, which is a string indicating the Belgian ID card number.

If requested, a value SHALL always be returned for the above claims.&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;/tbody&amp;gt;
&amp;lt;/table&amp;gt;&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;login_hint_token&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The user identifier token you receive from the discovery step.&lt;br&gt;This token must be wrapped in a JWT with the following payload:&lt;br&gt;{ &amp;quot;type&amp;quot;: &amp;quot;user_identifier_token&amp;quot;, 
  &amp;quot;value&amp;quot;: &amp;quot;&amp;lt;user_identifier_token&amp;gt;&amp;quot;}&lt;br&gt;The JWT (in compact serialization) is then used as the value for the login_hint_token parameter in the CIBA authentication request.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;id_token_hint&lt;br&gt;NOT SUPPORTED&lt;/td&gt;&lt;td&gt;Not accepted in this API. Use login_hint_token.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;login_hint&lt;br&gt;NOT SUPPORTED&lt;/td&gt;&lt;td&gt;Not accepted in this API. Use login_hint_token.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;acr_values&lt;br&gt;OPTIONAL&lt;/td&gt;&lt;td&gt;Indicates the authentication method required to process the request, represented as a space-separated list of tag values, ordered by preference.

Possible values : http://itsme.services/v2/claim/acr_basic http://itsme.services/v2/claim/acr_advanced

Note : if these two values are provided only the most constraining authentication method will be applied, e.g. http://itsme.services/v2/claim/acr_advanced.&lt;br&gt;&amp;lt;table&amp;gt;
&amp;lt;tbody&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;http://itsme.services/v2/
claim/acr_basic&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;It lets the user to choose either fingerprint usage (if device is compatible) or itsme® code. If the acr_values parameter is not specified, this is the default authentication method.&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;tr&amp;gt;&amp;lt;td&amp;gt;http://itsme.services/v2/
claim/acr_advanced&amp;lt;/td&amp;gt;&amp;lt;td&amp;gt;It forces the user to use his itsme® code.&amp;lt;/td&amp;gt;&amp;lt;/tr&amp;gt;
&amp;lt;/tbody&amp;gt;
&amp;lt;/table&amp;gt;&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;requested_expiry&lt;br&gt;OPTIONAL&lt;/td&gt;&lt;td&gt;A positive integer that allows the client to suggest the desired lifetime (in seconds) for the pending authentication request. The server may take this into account or override it to improve user experience.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;client_notification_token&lt;br&gt;NOT SUPPORTED IN POLL&lt;br&gt;REQUIRED IN PING&lt;/td&gt;&lt;td&gt;Mandatory in PING mode. A bearer token to be used by itsme® when&lt;br&gt;sending our PING. Will allow you to authenticate our PING request.&lt;br&gt;Max 1024 chars.&lt;/td&gt;&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;</td></tr>
<tr><td>client_assertion_type<br>REQUIRED</td><td>Specifies the type of assertion. Set this to urn:ietf:params:oauth:client-assertion-type:jwt-bearer.</td></tr>
<tr><td>client_assertion<br>REQUIRED</td><td>Is a set of identity and security information, in the form of a JWT, used as an authentication method. To ensures that the request to get the id token and access token is made only from your application, and not from a potential attacker that may have intercepted the authorization code, the JWT MUST be signed, and MAY also be encrypted. If both signing and encryption are performed, it MUST be signed then encrypted, with the result being a Nested JWT (refer to this page for more information).

The JWT contains the following claims.<br>&lt;table&gt;
&lt;tbody&gt;
&lt;tr&gt;&lt;td&gt;iss&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The issuer of the token. This value MUST be the same as the client_id.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;sub&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The subject of the token. This value MUST be the same as the client_id.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;aud&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The full URL of the resource you&amp;#x27;re using the JWT to authenticate to. Set this to https://idp.[e2e/prd].itsme.services/v2/token.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;jti&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;An unique identifier for the token, containing maximum 255 characters.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;exp&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The expiration time of the token in seconds since January 1, 1970 UTC.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;iat&lt;br&gt;OPTIONAL&lt;/td&gt;&lt;td&gt;The time at which the JWT was issued.&lt;/td&gt;&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;</td></tr>
</tbody>
</table>

##### Example

```text
POST https://idp.[e2e|prd].itsme.services/v2/backchannel/authentication
Host: idp.[e2e/prd].itsme.services
Content-Type: application/x-www-form-urlencoded
request=eyJraWQiOi...
&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer
&client_assertion=eyJraWQiOiJsdGFjZXNidy...
```

Where the following is the JWT payload of request:

```text
{"aud": "https://idp.e2e.itsme.services/v2",
 "login_hint_token": {
 	"type": "subject_code",
 	"value": "mqxews5ukc53ltb1jgj9qe9rnfnwwhyga18m"},
 "nbf": "2023-08-25T14:56:12.870Z",
 "scope": "openid service:TEST_LOGIN profile email",
 "iss": "s6BhdRkqt3",
 "claims": "{id_token:{name:null,gender:null}}",
 "exp": "1712757579",
 "iat": "1712757579",
 "jti": "4LTCqACC2ESC5BWCnN3j58EnA"}
```

#### Response

200 application/json

<table>
<tbody>
<tr><td>auth_req_id<br>REQUIRED</td><td>&lt;table&gt;
&lt;tbody&gt;
&lt;tr&gt;&lt;td&gt;&lt;/td&gt;&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;<br>&lt;table&gt;
&lt;tbody&gt;
&lt;tr&gt;&lt;td&gt;Unique identifier of the authentication request, generated by the OpenID Provider. Used by the client to poll the token endpoint. Treated as opaque.&lt;/td&gt;&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;</td></tr>
<tr><td>Expires_in<br>REQUIRED</td><td>Lifetime of the auth_req_id in seconds. After this period, the client must not use it.</td></tr>
<tr><td>Interval<br>OPTIONAL</td><td>&lt;table&gt;
&lt;tbody&gt;
&lt;tr&gt;&lt;td&gt;&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;Minimum number of seconds the client must wait between token polling requests. Default is 5 if not provided.&lt;/td&gt;&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;</td></tr>
</tbody>
</table>

##### Example

```text
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
{"auth_req_id": "1c266114-a1be-4252-8ad1-04986c5b9ac1",
 "expires_in": 120,
 "interval": 2}
```

## PING callback

This callback will only happen if your service is configured for Ping mode.

Once the end user has confirmed the action in their itsme® app, we will send a POST request on your preregistered callback endpoint.

That request will contain your "client_notification_token" as a bearer token. It will use the application/json media type and will only contain the "auth_req_id" as body content.

You should respond to that callback with calling the endpoint POST /token

Example

```text
POST /cb HTTP/1.1
Host: idp.[e2e/prd].itsme.services
Authorization: Bearer 8d67dc78-7faa-4d41-aabd-67707b374255
Content-Type: application/json
{"auth_req_id": "1c266114-a1be-4252-8ad1-04986c5b9ac1"}
```

## Token Request

### Public- And Private-Key

```text
POST https://idp.[e2e/prd].itsme.services/v2/token
```

During this step, your application has to authenticate itself to our server using the public- and private-key pair method.

The parameters below must be included in the body of the POST request, not in the query string.

#### Parameters

<table>
<tbody>
<tr><td>client_id<br>REQUIRED</td><td>It identifies your application. This parameter value is generated during registration.</td></tr>
<tr><td>grant_type<br>REQUIRED</td><td>Fixed value &quot;urn:openid:params:grant-type:ciba&quot;</td></tr>
<tr><td>client_assertion_type<br>REQUIRED</td><td>Specifies the type of assertion. Set this to urn:ietf:params:oauth:client-assertion-type:jwt-bearer.</td></tr>
<tr><td>auth_req_id<br>REQUIRED</td><td>&lt;table&gt;
&lt;tbody&gt;
&lt;tr&gt;&lt;td&gt;&lt;/td&gt;&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;<br>&lt;table&gt;
&lt;tbody&gt;
&lt;tr&gt;&lt;td&gt;Unique identifier received in the response of the authentication request, generated by the OpenID Provider. Treated as opaque.&lt;/td&gt;&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;</td></tr>
<tr><td>client_assertion<br>REQUIRED</td><td>Is a set of identity and security information, in the form of a JWT, used as an authentication method. To ensures that the request to get the id token and access token is made only from your application, and not from a potential attacker that may have intercepted the authorization code, the JWT MUST be signed, and MAY also be encrypted. If both signing and encryption are performed, it MUST be signed then encrypted, with the result being a Nested JWT (refer to this page for more information).

The JWT contains the following claims.<br>&lt;table&gt;
&lt;tbody&gt;
&lt;tr&gt;&lt;td&gt;iss&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The issuer of the token. This value MUST be the same as the client_id.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;sub&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The subject of the token. This value MUST be the same as the client_id.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;aud&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The full URL of the resource you&amp;#x27;re using the JWT to authenticate to. Set this to https://idp.[e2e/prd].itsme.services/v2/token.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;jti&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;An unique identifier for the token, containing maximum 255 characters.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;exp&lt;br&gt;REQUIRED&lt;/td&gt;&lt;td&gt;The expiration time of the token in seconds since January 1, 1970 UTC.&lt;/td&gt;&lt;/tr&gt;
&lt;tr&gt;&lt;td&gt;iat&lt;br&gt;OPTIONAL&lt;/td&gt;&lt;td&gt;The time at which the JWT was issued.&lt;/td&gt;&lt;/tr&gt;
&lt;/tbody&gt;
&lt;/table&gt;</td></tr>
</tbody>
</table>

##### Example

```text
POST https://idp.[e2e/prd].itsme.services/v2/token
Host: idp.[e2e/prd].itsme.services
Content-Type: application/x-www-form-urlencoded
grant_type=urn%3Aopenid%3Aparams%3Agrant-type%3Aciba&
auth_req_id= YOUR_AUTH_REQ_ID&
client_id=YOUR_CLIENT_ID&
client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&
client_assertion=PHNhbWxwOl...
Where the following is the JWT payload of client_assertion:
{"iss": "s6BhdRkqt3",
 "aud": "https://idp.e2e.itsme.services/v2/token",
 "exp": 1537820086,
 "iat": 1537819486,
 "nbf": 1537818886,
 "jti": "4LTCqACC2ESC5BWCnN3j58EnA",
 "scope": "openid email example-scope",
 "client_notification_token": "8d67dc78-7faa-4d41-aabd-67707b374255",
 "login_hint_token": "eyJhbGciOiJub25lIn0..."}
```

#### Response

200 application/json

<table>
<tbody>
<tr><td>access_token<br>REQUIRED</td><td>Allows an application to retrieve consented user information from the UserInfo Endpoint.</td></tr>
<tr><td>token_type<br>REQUIRED</td><td>Provides your application with the information required to successfully utilize the access token. Returned value is Bearer.</td></tr>
<tr><td>expires_in<br>REQUIRED</td><td>Access token lifetime (in seconds)</td></tr>
<tr><td>id_token<br>OPTIONAL</td><td>A security token that contains information about the authentication of an user, and potentially other requested claim data&#x27;s. The id_token value is represented as a signed and encrypted JWT. So, before being able to use the ID Token claims you will have to decrypt and verify the signature (refer to this page for more information).</td></tr>
</tbody>
</table>

##### Example

```text
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
{"access_token": "G5kXH2wHvUra0sHlDy1iTkDJgsgUO1bN",
 "token_type": "Bearer",
 "refresh_token": "4bwc0ESC_IAhflf-ACC_vjD_ltc11ne-8gFPfA2Kx16",
 "expires_in": 120,
 "id_token": "eyJhbGciOiJSUzI1NiIsImtpZ..."}
```

##### Example of a decrypted id_token:

```text
{"sub": "6g2k9rgglem2dttw5d51ulkxpv24phwatiu6",
 "aud": "WXw9DMqkEv",
 "birthdate": "1974-10-23",
 "gender": "male",
 "name": "John Ronald R Tolkien",
 "iss": "https://idp.prd.itsme.services/v2",
 "nonce": "nonce",
 "exp": 1699538407,
 "iat": 1699538107}
```

## Userinfo Request

### Public- And Private-Key

#### Request

```text
GET https://idp.[e2e/prd].itsme.services/v2/userinfo
```

The UserInfo Endpoint returns previously consented user profile information to your application. In other words, if the required claims are not returned in the ID Token, you can obtain the additional claims by presenting the access token to the itsme® UserInfo Endpoint. This is achieved by sending a HTTP GET request to the Userinfo Endpoint, passing the access token value in the Authorization header using the Bearer authentication scheme.

##### Example

```text
GET /userinfo HTTP/1.1
Host: server.example.com
Authorization: Bearer SlAV32hkKG
```

#### Response

200 application/json

The UserInfo Response is represented as a signed and encrypted JWT. So, before being able to extract the claims you will have to decrypt and verify the signature (refer to this page for more information).

##### Example

This is an response example containing all possible claims for a Belgian account:

```text
HTTP/1.1 200 OK
Content-Type: application/json
{"http://itsme.services/v2/claim/validityFrom": {
 "http://itsme.services/v2/claim/BEeidSn": "2018-11-08T00:00:00Z"},
 "sub": "e3xad7upx64grm14ttpnx4c586ve8gy0gp38",
 "birthdate": "1978-11-01",
 "http://itsme.services/v2/claim/claim_citizenship_as_iso": "BEL",
 "gender": "male",
 "http://itsme.services/v2/claim/birthdate_as_string": "01.11.1978",
 "http://itsme.services/v2/claim/IDDocumentType": "I",
 "iss": "https://oidc.uat.itsme.services/clientsecret-oidc/csapi/v0.1",
 "http://itsme.services/v2/claim/validityTo": { 	"http://itsme.services/v2/claim/BEeidSn": "2028-11-10T00:00:00Z"},
 "http://itsme.services/v2/claim/claim_citizenship": "BE",
 "locale": "FR",
 "http://itsme.services/v2/claim/issuance_locality": {	"http://itsme.services/v2/claim/BEeidSn": "BRUXELLES"},
 "email": "test@itsme.be",
 "http://itsme.services/v2/claim/place_of_birth": {
 	"city": "Brussels",
 	"formatted": "Brussels"},
"address": {
	"locality": "TONGEREN",
	"street_address": "Jekerstraat 39",
	"postal_code": "3700",
	"formatted": "Jekerstraat 39 3700 TONGEREN"},
"email_verified": false,
"http://itsme.services/v2/claim/claim_device": {
	"os": "ANDROID",
	"appName": "be.bmid.itsme.uat",
	"appRelease": "4.0.0",
	"deviceLabel": "lucye",
	"debugEnabled": false,
	"deviceId": "c22de2331dd249bba063afd3507fe3a4f",
	"osRelease": "9",
	"manufacturer": "LGE",
	"deviceLockLevel": "true",
	"rooted": false,
	"deviceModel": "LG-H870",
	"msisdn": "0032485694175"},
"http://itsme.services/v2/claim/BENationalNumber": "99060427181",
"phone_number_verified": true,
"given_name": "George",
"picture": "https://oidc.uat.itsme.services/clientsecret-oidc/csapi/v0.1/picture",
"http://itsme.services/v2/claim/verificationDate": {
	"http://itsme.services/v2/claim/place_of_birth": "2023-04-12T15:02:23Z",
	"birthdate": "2023-04-12T15:02:23Z",
	"address": "2023-04-12T15:02:23Z",	"http://itsme.services/v2/claim/claim_citizenship_as_iso": "2023-04-12T15:02:23Z",
	"gender": "2023-04-12T15:02:23Z",
	"http://itsme.services/v2/claim/birthdate_as_string": "2023-04-12T15:02:23Z",
	"http://itsme.services/v2/claim/BENationalNumber": "2023-04-12T15:02:23Z",
	"given_name": "2023-04-12T15:02:23Z",
	"http://itsme.services/v2/claim/claim_citizenship": "2023-04-12T15:02:23Z",
	"picture": "2023-04-12T15:02:23Z",
	"name": "2023-04-12T15:02:23Z",
	"http://itsme.services/v2/claim/IDDocumentSN": "2023-04-12T15:02:23Z",
	"http://itsme.services/v2/claim/BEeidSn": "2023-04-12T15:02:23Z",
	"family_name": "2023-04-12T15:02:23Z",
	"http://itsme.services/v2/claim/physical_person_photo": "2023-04-12T15:02:23Z"},
"aud": "WXw9DMqkEv",
"http://itsme.services/v2/claim/IDIssuingCountry": {	"http://itsme.services/v2/claim/place_of_birth": "BEL",
	"birthdate": "BEL",
	"address": "BEL",
	"http://itsme.services/v2/claim/claim_citizenship_as_iso": "BEL",
	"gender": "BEL",
	"http://itsme.services/v2/claim/birthdate_as_string": "BEL",	"http://itsme.services/v2/claim/BENationalNumber": "BEL",
	"given_name": "BEL",
	"http://itsme.services/v2/claim/claim_citizenship": "BEL",
	"picture": "BEL",
	"name": "BEL",
	"http://itsme.services/v2/claim/IDDocumentSN": "BEL",
	"http://itsme.services/v2/claim/BEeidSn": "BEL",
	"family_name": "BEL",
	"http://itsme.services/v2/claim/physical_person_photo": "BEL"},
"name": "George Tǎnka",
"http://itsme.services/v2/claim/IDDocumentSN": "431522485012",
"phone_number": "+32 485694175",
"http://itsme.services/v2/claim/BEeidSn": "431522485012",
"family_name": "Tǎnka",
"http://itsme.services/v2/claim/physical_person_photo": {
"format": "image/jpeg",
"value": "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAIBAQ...},
"nbf": 1681314190,
"exp": 1681314490,
"iat": 1681314190}
```

