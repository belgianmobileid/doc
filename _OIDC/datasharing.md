---
layout: OIDC
title: Data Sharing API
permalink: datasharing/
nav_order: 6
toc_list: true
---

# Overview

itsme® API is based on the Authorization Code Flow of OpenID Connect 1.0. The API can be used to verify your end-users' identity and obtain some information about them. For the exact user data that can be requested, please see the <a href="#authorization-request">Authorization Request</a> parameters.

The diagram below describes the **Data Sharing** process and how your systems should integrate with itsme® :
  
 ![Sequence diagram describing the OpenID flow](/doc/public/images/OpenID_SeqDiag.png)

To get to this result please make sure you 

<ol>
  <li>add itsme® button to your front-end page so the user can indicate he wishes to authenticate with itsme® : <a href="https://design.itsme-id.com/499ca0b4f/p/9567c9-itsme-button" target="blank">itsme® button specifications</a>.</li>
  <li>create the <a href="#AuthNReq" >Authorization Request</a> to authenticate the User. This request will redirect the user to the itsme® app. itsme® will then authenticates the user by asking him 
    <ul type>
	  <li>to scan the QR code on the itsme® sign-in page</li>	
      <li>authorize the release of some information to your application</li>
      <li>to provide his credentials (itsme® code, fingerprint or FaceID)</li>
    </ul><br>It is also in this Authorization Request that you will be able to request claims about the user and the Data Sharing event.</li>
  <li><a href="#AuthNResp" >collect the Authorization Code</a> once the user has been authenticated and redirected by itsme® to your mobile or web application.</li>
  <li><a href="#TokenReq" >exchange the Authorization Code for an ID token</a> (e.g. identifying the user) and an Access Token.</li>
  <li>Obtain the additional claims by <a href="#UserInfoReq" >presenting the access token to the itsme® UserInfo Endpoint</a> if the required claims are not returned in the ID token.</li>
  <li>Confirm the success of the operation and display a success message.</li>
</ol>

# Onboarding

To make use of our services, you will need to contact our Customer Care team at <a href="mailto:onboarding@itsme-id.com">onboarding@itsme-id.com</a>. Based on your requirements, they will invite you to our self-service Portal where you will be able to configure an account.  A clientID will be generated, linked to your account, that you will need to include in your <a href="#AuthNReq" >Authorization Request</a>.

Each partner can contain multiple "services". Each service should correspond to one user flow at your side and can be of type Authentication, Identification, Data Sharing or Confirmation. The service code will also be required in your Authorization Request.

For each service, you will have to provide one or a few "redirect_uri", which are the landing page(s) where the end user will be sent after authenticating with itsme®. Only the URIs whitelisted in a service will be allowed in your Authorization Request, so they have to be fully determined before you can use the service. This whitelisting works on an "exact match" basis, including the full (case sensitive) path and query string so please communicate the exact string you are planning to use in your Authorization Request.

# Guides

{% include_relative chapters/generate_itsme_button.md %}

## Securing the exchange of information

To protect the exchange of sensitive information and ensure the requested information gets issued to a legitimate application and not some other party, the OpenID Connect protocol uses JSON Web Token (JWT) which can be signed and/or encrypted. Among the methods described in OpenID specification, itsme® supports 2 authentication methods to secure communications between your backend and itsme®:

<ul>
  <li>"Private key JWT" is based on a public/private key pair (asymmetric encryption). It is therefore the most secure option</li>
  <li>"Client secret" is based on a shared Secret key (symmetric encryption). It can be easier to implement in some cases</li>
</ul>

<aside class="notice">You will have to choose between one of these methods when registering your project.
</aside>

### Public-private key pair and JWKSet URI

This method uses a pair of keys (1 public, 1 private) to encrypt and decrypt senders’ and recipients’ sensitive data. It is also known as public-key cryptography or asymetric encryption.

<aside class="notice">This method requires that each party exposes its public keys in the form of a JWK Set document on a publicly accessible URI, and keep its private keys for itself. 
</aside>

You can retrieve the itsme® JWK Set from the URI mentioned as <code>jwks_uri</code> in our <a href="https://belgianmobileid.github.io/doc/authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a>.

<aside class="notice">Refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more on signing and encrypting tokens.
</aside>

<aside class="notice">Whatever the tool you are choosing to create your key pairs, don't forget to send your JWK Set URI by email to <a href = "mailto: onboarding@itsme.be">onboarding@itsme-id.com</a> and itsme® will make sure to complete the configuration for you in no time!
</aside>

<aside class="notice">The algorithms – needed to sign and encrypt a JWT – are listed in the <a href="https://belgianmobileid.github.io/doc/authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a> for more information.
</aside>

### Secret key method

Secret key cryptography method uses the same secret key to encrypt and decrypt sensitive information. This approach is the inverse of public- and private-key encryption.

This method requires the exchange of a static secret to be held by both the sender and the data receiver. The secret value will be provided by itsme® when registering your project.

<aside class="notice">The algorithms – needed to sign and encrypt a JWT – are listed in the <a href="https://belgianmobileid.github.io/doc/datasharing/#itsme-discovery-document" target="blank">itsme® Discovery document</a> for more information.
</aside>

<aside class="notice">If you choose to go with the secret key method, you will be able to specify if the ID Token JWT needs to be signed with the an asymmetric algorithm (e.g. <code>RS256</code>) or with a symmetric algorithm (e.g. : <code>HS256</code>). When using the <code>RS256</code> algorithm, our public keys will be needed to verify the signature. This information can be found in our <a href="https://belgianmobileid.github.io/doc/datasharing/#itsme-discovery-document" target="blank">itsme® Discovery document</a>, using the key <code>jwks_uri</code>.
</aside>

### Key rotation procedure
### for public-private key pair and JWKSet URI

itsme® backend has cache mechanism in place, which is sporadic (from 30min to 24h). During this time, we will keep on using old keys.
<aside class="notice">use "Cache-Control: max-age=" HTTP header (min 30min) to lower waiting time.</aside>

#### Rotating signing key:
<ul>
<li>Add the new key to JWK set, with a new “kid”</li>
<li>Start using the new key to sign JWTs</li>
<li>When the flow is validated with the new key, remove the old one from the JWK set</li>
</ul>

#### Rotating encryption key:
<ul>
<li>Replace the old key with the new one in JWK set, but still support old and new keys in decryption process</li>
<li>Wait 24h (or wait for “max-age” amount of time, if specified)</li>
<li>Decommission the old key completely</li>
</ul>

Changing the key could come along with changing the jwkset url. If that is the case, communicate new available jwkset url to onboarding@itsme-id.com. It is not be possible to be perfectly in sync, a few failed flows should be expected in the lapse of time between jwkset url update and the key update at the partner’s side. Smoother way would be:
<ul>
<li>Copy the old jwkSet on the new URL</li>
<li>the URL is communicated & registered by itsme®</li>
<li>Rotate the keys in the jwkSet on the new URL as per rotating keys info above</li>
</ul>

### for secret key method

Please, reach out to onboarding@itsme-id.com in case the secret key should be rotated.

### PKCE-enhanced flow

Whatever the chosen authentication method, itsme® also supports an extra security extension named Proof of Key for Code Exchange (<a href="https://datatracker.ietf.org/doc/html/rfc7636" target="blank">PKCE</a>). This additionnal layer of security is intended to mitigate some Authorization Code interception attacks. For this mechanism to achieve its full potential, PKCE has to be made mandatory in your flow, which is an option we can enable for you (strongly recommended). Please ask our onboarding team to do so when registering your project.

<aside class="notice">If this option is not enabled, you are still free to use PKCE for some added security but requests without the PKCE <code>code_challenge</code> will be accepted as well at itsme® side.</aside>

PKCE implies choosing a random string, named <code>code_verifier</code>, and then generating a SHA256 hash of that string, named <code>code_challenge</code>. The code_challenge has to be sent along with the Authorization Request, while the code_verifier must be sent with the Token Request, allowing our backend to make sure both requests are issued by the same source.

<aside class="notice"><code>code_verifier</code> MUST contain only the unreserved characters [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~", with a minimum length of 
43 characters and a maximum length of 128 characters.</aside>

<code>code_challenge</code> can then be obtained via this kind of instructions:

```
var hash = code_verifier.createHash('sha256');
var code_challenge = base64url.encode(hash);
```

### Signing, encrypting and decoding JWTs

Libraries implementing JWT and the JOSE specs JWS, JWE, JWK, and JWA are listed <a href="https://openid.net/certified-open-id-developer-tools/" target="blank">here</a>. For testing purposes only, we could advise the use of <a href="https://mkjwk.org/" target="blank">https://mkjwk.org/</a> for JWK generation and <a href="https://mkjose.org/" target="blank"> https://mkjose.org/</a> for payload check => these are 2 open-source tools which will help you visualize JWK mechanisms, client assertion construct. Please DO NOT generate production private keys on any website. Rather opt for the relevant SDK library mentioned <a href="https://openid.net/certified-open-id-developer-tools/" target="blank">here</a>.


{% include_relative chapters/certificates_and_website_security.md %}

## Handling responses

Whenever a partner is sending a request to the itsme OIDC endpoints he will get a response back. According to the OIDC protocol, and depending on the endpoint that was contacted, partners can get a 

<ul>
  <li>response where some parameters are added to the query component of the redirection URI using the <code>application/x-www-form-urlencoded</code> format, or</li>
  <li>response displayed directly on our itsme® sign-in page ;</li>
  <li>response using the <code>application/json</code> media type</li>
</ul>

Alongside the type of response an HTTP status code is sent that shows whether the request was successful or not. If it was not, you can tell by the code and the message in the response what went wrong, why it went wrong and whether there is something the partner can do about it.

### A successful response

An HTTP status <code>200 OK</code> or <code>302 Found</code> is issued whenever your request was a success. You see this type of response in our examples like the one where we successfully retrieve the <a href="https://belgianmobileid.github.io/doc/datasharing/#example-1" target="blank">Token Response</a> : 

```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache

{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzc
    yI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg5
    NzYxMDAxIiwKICJhdWQiOiAiczZCaGRSa3F0MyIsCiAibm9uY2UiOiAibi0wUzZ
    fV3pBMk1qIiwKICJleHAiOiAxMzExMjgxOTcwLAogImlhdCI6IDEzMTEyODA5Nz
    AKfQ.ggW8hZ1EuVLuxNuuIJKX_V8a_OMXzR0EHR9R6jgdqrOOF4daGU96Sr_P6q
    Jp6IcmD3HP99Obi1PRs-cwh3LO-p146waJ8IhehcwL7F09JdijmBqkvPeB2T9CJ
    NqeGpe-gccMg4vfKjkM8FcGvnzZUN4_KSP0aAp1tOJ1zZwgjxqGByKHiOtX7Tpd
    QyHE5lcMiKPXfEIQILVq0pc_E2DzL7emopWoaoZTF_m0_N0YzFC6g6EJbOEoRoS
    K5hoDalrcvRYLSrQAZZKflyuVCyixEoV9GfNQC3_osjzw2PAithfubEEBLuVVk4
    XUVrWOLrLl0nx7RkKU8NXNHq-rvKMzqg"
  "access_token": "SlAV32hkKG",
  "token_type": "Bearer",
  "expires_in": 3600,
}
```

### The error responses

Things will sometimes go wrong. So, OpenID Connect defines a number of rules regarding the format of errors returned from our endpoints. 

***Authorization Endpoint errors***

If the request fails due to a missing, invalid, or mismatching redirection URI, or if the client identifier is missing or invalid,... the Authorization Endpoint will inform you of the error our itsme® sign-in page.

 ![Authorization Endpoint error reponse](/doc/public/images/AuthorizationEndpoint_ErrorResponse.png)
 
If the User denies the access request or the User authentication fails, the Authorization Endpoint will inform you by adding the following parameters to the query component of the redirection URI using the <code>application/x-www-form-urlencoded</code> format :

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
          <td>{% include parameter.html name="access_denied" req="" %}</td>
          <td>The User or the Authorization Endpoint denied the request.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="login_required" req="" %}</td>
          <td>The Authorization Endpoint requires User authentication. This error MAY be returned when the <code>prompt</code> parameter value in the Authorization Request is <code>none</code></td>
        </tr>
        <tr>
          <td>{% include parameter.html name="interaction_required" req="" %}</td>
          <td>The Authorization Endpoint requires User interaction of some form to proceed. This error MAY be returned when the <code>prompt</code> parameter value in the Authorization Request is <code>none</code>, but the Autorization Request cannot be completed without displaying a user interface for User interaction.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="unsupported_request" req="" %}</td>
          <td>The request contains a not supported parameter.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="invalid_client_id" req="" %}</td>
          <td>The request contains an invalid <code>client_id</code>.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="invalid_redirect_uri" req="" %}</td>
          <td>The request contains an invalid redirect URI.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="unsupported_grant_type" req="" %}</td>
          <td>Grant type not supported.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="invalid_grant" req="" %}</td>
          <td>Invalid grant.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="invalid_scope" req="" %}</td>
          <td>The requested scope is invalid, unknown, or malformed.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="unsupported_display" req="" %}</td>
          <td>Only <code>page</code> is supported.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="unauthorized_client" req="" %}</td>
          <td>Unknown or unspecified <code>client_id</code>.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="unsupported_response_type" req="" %}</td>
          <td>The Authorization Endpoint does not support obtaining an authorization code using this method.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="invalid_request_object" req="" %}</td>
          <td>The <code>request</code> parameter contains an invalid Request Object.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="invalid_request_uri" req="" %}</td>
          <td>The <code>request_uri</code> in the Authorization Request returns an error or contains invalid data.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="invalid_request" req="" %}</td>
          <td>Oauth2 parameters do not match Request object.</td>
        </tr>
        <tr>
          <td>{% include parameter.html name="temporary_unavailable" req="" %}</td>
          <td>The authorization server is currently unable to handle the request due to a temporary overloading or maintenance of the server.</td>
        </tr>
       </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="error_description" req="OPTIONAL" %}</td>
      <td>Human-readable text providing additional information, used to assist the developer in understanding the error that occurred.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="state" req="" %}</td>
      <td>The string value provided in the Authorization Request. You SHOULD validate that the value returned matches the one supplied.</td>
    </tr>
  </tbody>
</table>

For example :

```http
HTTP/1.1 302 Found Location: https://client.example.com/cb?error=access_denied&state=xyz
```

***Token Endpoint errors***

If the request fails the Token Endpoint responds with an HTTP 400 (Bad Request) status code (unless specified otherwise) and includes the following parameters in the entity-body of the HTTP response using the <code>application/json</code> media type :

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
            <td>{% include parameter.html name="invalid_client" req="" %}</td>
            <td>Client authentication failed (e.g., unknown client, no client authentication included, or unsupported authentication method).</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="invalid_grant" req="" %}</td>
            <td>The provided authorization grant (e.g., authorization code, resource owner credentials) is invalid, expired or does not match the redirection URI used in the authorization request.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="unauthorized_client" req="" %}</td>
            <td>The authenticated client is not authorized to use this authorization grant type. Can also be caused by an invalid client_assertion.</td>
          </tr>
       </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="detail" req="OPTIONAL" %}</td>
      <td>Human-readable text providing additional information, used to assist the developer in understanding the error that occurred.</td>
    </tr>
  </tbody>
</table>

For example :

```http
HTTP/1.1 400 Bad Request 
Content-Type: application/json;charset=UTF-8 Cache-Control: no-store Pragma: no-cache 

{ 
  "error":"invalid_request" 
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
      <td>The access token provided is expired, revoked, malformed, or  invalid for other reasons.</td>
    </tr>
   </tbody>
</table>

For example :

```http
HTTP/1.1 401 Unauthorized 
WWW-Authenticate: Bearer realm="example"
```

***Revocation Endpoint errors***

If the request fails the Revoke Endpoint responds with an HTTP 400 (Bad Request) status code and includes the fllowing parameters in the entity-body of the HTTP response using the <code>application/json</code> media type :

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
            <td>{% include parameter.html name="invalid_client" req="" %}</td>
            <td>Client authentication failed (e.g., unknown client, no client authentication included, or unsupported authentication method).</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="invalid_grant" req="" %}</td>
            <td>The provided authorization grant (e.g., authorization code, resource owner credentials) is invalid, expired or does not match the redirection URI used in the authorization request.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="unauthorized_client" req="" %}</td>
            <td>The authenticated client is not authorized to use this authorization grant type.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="unsupported_token_type" req="" %}</td>
            <td>itsme® does not support the revocation of the presented access token.</td>
          </tr>
       </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="error_description" req="OPTIONAL" %}</td>
      <td>Human-readable text providing additional information, used to assist the developer in understanding the error that occurred.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="state" req="" %}</td>
      <td>The string value provided in the Authorization Request. You SHOULD validate that the value returned matches the one supplied.</td>
    </tr>
  </tbody>
</table>

For example:

```http
HTTP/1.1 400 Bad Request 
Content-Type: application/json;charset=UTF-8 Cache-Control: no-store Pragma: no-cache 

{ 
  "error":"invalid_request" 
}
```

{% include_relative chapters/map_user.md %}

{% include_relative chapters/user_data.md %}


# API reference

{% include_relative chapters/itsme_discovery_document.md %}

## Authorization Request

{% tabs AuthorizationRequest %}

{% tab AuthorizationRequest Public- and private-key %}

<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/authorization</code></b>

{% endtab %}

{% tab AuthorizationRequest Secret Key %}

<<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/authorization</code></b>

If your onboarding happened before the 25th of June 2025, then URL was:<br>
<b><code>GET https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/clientsecret-oidc/csapi/v0.1/connect/authorize</code></b>

{% endtab %}

{% endtabs %}

<aside class="notice">When implementing the <b>Data Sharing</b> service, you MUST request at least one user claim, either via the <code>scope</code> parameter - <code>profile</code>, <code>email</code>, <code>address</code> ... - or via the <code>claims</code> parameter - <code>name</code>, <code>birthdate</code>, <code>http://itsme.services/v2/claim/claim_citizenship</code> ...
</aside>

{% include_relative chapters/authorization_request.md %}


### Example

{% tabs AuthorizationExample %}

{% tab AuthorizationExample Public- and private-key %}

***Request***

```http
GET /v2/authorization HTTP/1.1
Host: server.example.com

response_type=code
&client_id=abcd1234
&redirect_uri=https://client.example.org/cb
&scope=openid+service:EXAMPLE+profile+eid+phone+email+address
&state=anystate
&nonce=anonce
&prompt=login
&max_age=1
&claims={"id_token":{
  "name":null,
  "gender":null,
	"http://itsme.services/v2/claim/BENationalNumber":null,
	"http://itsme.services/v2/claim/claim_citizenship":null,
	"http://itsme.services/v2/claim/place_of_birth":null,
	"http://itsme.services/v2/claim/physical_person_photo":null,
	"http://itsme.services/v2/claim/birthdate_as_string":null,
	"http://itsme.services/v2/claim/validityFrom":null,
	"http://itsme.services/v2/claim/validityTo":null,
	"http://itsme.services/v2/claim/IDDocumentSN":null}}
```

***Response***

```http
HTTP/1.1 302 Found
Location: https://client.example.org/cb?
  code=SplxlOBeZQQYbYS6WxSbIA
  &state=af0ifjsldkj
```

{% endtab %}

{% tab AuthorizationExample Secret key %}


***Request***

```http
GET /authorize HTTP/1.1
Host: server.example.com

response_type=code
&client_id=abcd1234
&redirect_uri=https://client.example.org/cb
&scope=openid+service:EXAMPLE+profile+eid+phone+email+address
&state=anystate
&nonce=anonce
&prompt=login
&max_age=1
&claims={"id_token":{
  "name":null,
  "gender":null,
	"http://itsme.services/v2/claim/BENationalNumber":null,
	"http://itsme.services/v2/claim/claim_citizenship":null,
	"http://itsme.services/v2/claim/place_of_birth":null,
	"http://itsme.services/v2/claim/physical_person_photo":null,
	"http://itsme.services/v2/claim/birthdate_as_string":null,
	"http://itsme.services/v2/claim/validityFrom":null,
	"http://itsme.services/v2/claim/validityTo":null,
	"http://itsme.services/v2/claim/IDDocumentSN":null}}
```

***Response***

```http
HTTP/1.1 302 Found
Location: https://client.example.org/cb?
  code=SplxlOBeZQQYbYS6WxSbIA
  &state=af0ifjsldkj
```

{% endtab %}

{% endtabs %}


<a id="TokenReq"></a>
{% include_relative chapters/token_request.md %}

<a id="UserInfoReq"></a>
{% include_relative chapters/userinfo_request_variant_b.md %}

<a id="RevokeReq"></a>
{% include_relative chapters/revoke_request.md %}



