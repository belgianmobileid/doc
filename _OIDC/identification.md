---
layout: OIDC
title: Identification API
permalink: identification/
nav_order: 4
toc_list: true
---

# Overview

itsme® API is based on the Authorization Code Flow of OpenID Connect 1.0. The API can be used to verify your end-users' identity and obtain some information about them. For the exact user data that can be requested, please see the <a href="#authorization-request">Authorization Request</a> parameters.

The diagram below describes the **Identification** process and how your systems should integrate with itsme® :
  
 ![Sequence diagram describing the OpenID flow](/doc/public/images/OpenID_SeqDiag.png)

To get to this result please make sure you 

<ol>
  <li>add itsme® button to your front-end page so the user can indicate he wishes to authenticate with itsme® : <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/buttons-1518207548" target="blank">itsme® button specifications</a>.</li>
  <li>create the <a href="#AuthNReq" >Authorization Request</a> to authenticate the User. This request will redirect the user to the itsme® app. itsme® will then authenticates the user by asking him 
    <ul type>
      <li>to enter his phone number on the itsme® sign-in page</li> 
      <li>authorize the release of some information to your application</li>
      <li>to provide his credentials (itsme® code, fingerprint or FaceID)</li>
    </ul><br>It is also in this Authorization Request that you will be able to request claims about the user and the Identification event.</li>
  <li><a href="#AuthNResp" >collect the Authorization Code</a> once the user has been authenticated and redirected by itsme® to your mobile or web application.</li>
  <li><a href="#TokenReq" >exchange the Authorization Code for an ID token</a> (e.g. identifying the user) and an Access Token.</li>
  <li>Obtain the additional claims by <a href="#UserInfoReq" >presenting the access token to the itsme® UserInfo Endpoint</a> if the required claims are not returned in the ID token.</li>
  <li>Confirm the success of the operation and display a success message.</li>
</ol>

# Onboarding

To make use of our services, you will need to contact our Customer Care team at <a href="mailto:onboarding@itsme-id.com">onboarding@itsme-id.com</a>. Based on your requirements, they will configure for you a new partner in our database. You will receive the clientID corresponding to this partner, that you will need to include in your <a href="#AuthNReq" >Authorization Request</a>.

Each partner can contain multiple "services". Each service should correspond to one user flow at your side and can be of type Authentication, Identification or Confirmation. The service code will also be required in your Authorization Request.

For each service, you will have to provide one or a few "redirect_uri", which are the landing page(s) where the end user will be sent after authenticating with itsme®. Only the URIs whitelisted in a service will be allowed in your Authorization Request, so they have to be fully determined before you can use the service. This whitelisting works on an "exact match" basis, including the full (case sensitive) path and query string so please communicate the exact string you are planning to use in your Authorization Request.

# Guides

## Generate itsme® button

First, you will need to create a button to allow your users to authenticate with itsme®. Check the <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/buttons-1518207548" target="blank">Button design guide</a> before you start the integration. 

Upon clicking this button, the user will be redirected to our Front-End. itsme® then take care of their identification.

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

<aside class="notice">The algorithms – needed to sign and encrypt a JWT – are listed in the <a href="https://belgianmobileid.github.io/doc/identification/#itsme-discovery-document" target="blank">itsme® Discovery document</a> for more information.
</aside>

<aside class="notice">If you choose to go with the secret key method, you will be able to specify if the ID Token JWT needs to be signed with the an asymmetric algorithm (e.g. <code>RS256</code>) or with a symmetric algorithm (e.g. : <code>HS256</code>). When using the <code>RS256</code> algorithm, our public keys will be needed to verify the signature. This information can be found in our <a href="https://belgianmobileid.github.io/doc/identification/#itsme-discovery-document" target="blank">itsme® Discovery document</a>, using the key <code>jwks_uri</code>.
</aside>

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


## Certificates and website security

itsme® requires <code>https</code> connections to guarantee security. With the <code>https</code> protocol, a web site operator obtains a certificate by applying to a certificate authority with a certificate signing request. The certificate request is an electronic document that contains the web site name, company information and the public key. The certificate provider signs the request, thus producing a public certificate. During web browsing, this public certificate is served to any web browser that connects to the web site and proves to the web browser that the provider believes it has issued a certificate to the owner of the web site.

A certificate provider can opt to issue three types of certificates, each requiring its own degree of vetting rigor. In order of increasing rigor (and naturally, cost) they are: Domain Validation, Organization Validation and Extended Validation.

The Domain Validation certificate doesn’t provide sufficient identity guarantees to itsme. So, <b>only the Organization Validation and Extended Validation certificates</b> are supported. For example, using the Let's Encrypt open certificate authority is not suffcient because it only provide standard Domain Validation certificates. 

<aside class="notice">The chain of trust of these certificates need to be publicly accessible, meaning that our systems need to be able to access the root and the intermediate certificates.
</aside>

<aside class="notice">All itsme® API URL we publish use <code>https</code>.
</aside>

<aside class="notice">All requests to our endpoints MUST also use the SNI extension (refer to the <a href="https://datatracker.ietf.org/doc/html/rfc6066#section-3">RFC</a> for more information) of the TLS protocol, that allows our servers to provide you with the correct certificate based on which endpoint you are querying.
</aside>

## Handling responses

Whenever a partner is sending a request to the itsme OIDC endpoints he will get a response back. According to the OIDC protocol, and depending on the endpoint that was contacted, partners can get a 

<ul>
  <li>response where some parameters are added to the query component of the redirection URI using the <code>application/x-www-form-urlencoded</code> format, or</li>
  <li>response displayed directly on our itsme® sign-in page ;</li>
  <li>response using the <code>application/json</code> media type</li>
</ul>

Alongside the type of response an HTTP status code is sent that shows whether the request was successful or not. If it was not, you can tell by the code and the message in the response what went wrong, why it went wrong and whether there is something the partner can do about it.

### A successful response

An HTTP status <code>200 OK</code> or <code>302 Found</code> is issued whenever your request was a success. You see this type of response in our examples like the one where we successfully retrieve the <a href="https://belgianmobileid.github.io/doc/identification/#example-1" target="blank">Token Response</a> : 

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
      <td>{% include parameter.html name="error_description" req="OPTIONAL" %}</td>
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

## itsme® Discovery Document

{% tabs Discovery %}

{% tab Discovery Public- and private-key %}

<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/.well-known/openid-configuration</code></b>

To simplify implementations and increase flexibility, <a href="https://openid.net/specs/openid-connect-discovery-1_0.html" target="blank">OpenID Connect allows the use of a Discovery Document</a>, a JSON document containing key-value pairs which provide details about itsme® configuration, such as the 

<tabul>
  <tabli>Authorization, Token and userInfo Endpoints</tabli>
  <tabli>Supported claims</tabli>
  <tabli>...</tabli>
</tabul>

{% endtab %}

{% tab Discovery Secret key %}

<b><code>GET https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/clientsecret-oidc/csapi/v0.1/.well-known/openid-configuration</code></b>

To simplify implementations and increase flexibility, <a href="https://openid.net/specs/openid-connect-discovery-1_0.html" target="blank">OpenID Connect allows the use of a Discovery Document</a>, a JSON document containing key-value pairs which provide details about itsme® configuration, such as the

<tabul>
  <tabli>Authorization, Token and userInfo Endpoints</tabli>
  <tabli>Supported claims</tabli>
  <tabli>...</tabli>
</tabul>

{% endtab %}

{% endtabs %}


## Authorization Request

{% tabs AuthorizationRequest %}

{% tab AuthorizationRequest Public- and private-key %}

<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/authorization</code></b>

{% endtab %}

{% tab AuthorizationRequest Secret Key %}

<b><code>GET https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/clientsecret-oidc/csapi/v0.1/connect/authorize</code></b>

{% endtab %}

{% endtabs %}

<aside class="notice">When implementing the <b>Identification</b> service, you MUST request at least one user claim, either via the <code>scope</code> parameter - <code>profile</code>, <code>email</code>, <code>address</code> ... - or via the <code>claims</code> parameter - <code>name</code>, <code>birthdate</code>, <code>http://itsme.services/v2/claim/claim_citizenship</code> ...
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
## Token Request

{% tabs TokenRequest %}

{% tab TokenRequest Public- and private-key %}

<b><code>POST https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/token</code></b>

To assert the identity of the user, the <code>code</code> received previously needs to be exchanged for an ID token and access token. During this step, your application has to authenticate itself to our server using the public- and private-key pair method.

<aside class="notice">The parameters below must be included in the body of the POST request, not in the query string.</aside>

### Parameters

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="grant_type" req="REQUIRED" %}</td>
      <td>Set this to <code>authorization_code</code> to tell the Token Endpoint that your application wants to exchange an authorization code for an ID token and access token. </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code" req="REQUIRED" %}</td>
      <td>The intermediate opaque credential received in the Authorization Response.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirect_uri" req="REQUIRED" %}</td>
      <td>It is the URL to which users are redirected once the authentication is complete. It MUST match the value used in the Authorization Request.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code_verifier" req="OPTIONAL" %}</td>
      <td>High-entropy cryptographic random string using the unreserved characters [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~", with a minimum length of 43 characters and a maximum length of 128 characters. This parameter is REQUIRED if you required PKCE to be enforced.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_assertion_type" req="REQUIRED" %}</td>
      <td>Specifies the type of assertion. Set this to <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_assertion" req="REQUIRED" %}</td>
      <td>Is a set of identity and security information, in the form of a JWT, used as an authentication method. To ensures that the request to get the id token and access token is made only from your application, and not from a potential attacker that may have intercepted the authorization code, the JWT MUST be signed, and MAY also be encrypted. If both signing and encryption are performed, it MUST be signed then encrypted, with the result being a Nested JWT (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).<br><br>The JWT contains the following claims.        
        <table>
          <tr>
            <td>{% include parameter.html name="iss" req="REQUIRED" %}</td><td>The issuer of the token. This value MUST be the same as the <code>client_id</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="sub" req="REQUIRED" %}</td><td>The subject of the token. This value MUST be the same as the <code>client_id</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="aud" req="REQUIRED" %}</td><td>The full URL of the resource you're using the JWT to authenticate to. Set this to <code>https://idp.<i>[e2e/prd]</i>.itsme.services/v2/token</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="jti" req="REQUIRED" %}</td><td>An unique identifier for the token, containing maximum 255 characters.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="exp" req="REQUIRED" %}</td><td>The expiration time of the token in seconds since January 1, 1970 UTC.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="iat" req="OPTIONAL" %}</td><td>The time at which the JWT was issued.</td>
          </tr>
        </table>
      </td>
    </tr>
  </tbody>
</table>


### Response

<code>200</code> <code>application/json</code>

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="access_token" req="" %}</td>
      <td>Allows an application to retrieve consented user information from the UserInfo Endpoint.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="token_type" req="" %}</td>
      <td>Provides your application with the information required to successfully utilize the access token. Returned value is <code>Bearer</code>..</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="id_token" req="" %}</td>
      <td>A security token that contains information about the authentication of an user, and potentially other requested claim data's. The <code>id_token</code> value is represented as a signed and encrypted JWT. So, before being able to use the ID Token claims you will have to decrypt and verify the signature (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).</td>      
    </tr>
  </tbody>
</table>

{% endtab %}

{% tab TokenRequest Secret key %}

<b><code>POST https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/clientsecret-oidc/csapi/v0.1/connect/token</code></b>

To assert the identity of the user, the <code>code</code> received previously needs to be exchanged for an ID token and access token. During this step, your application has to authenticate itself to our server using the secret key method.

<aside class="notice">The parameters below must be included in the body of the POST request, not in the query string.</aside>

### Parameters

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="grant_type" req="REQUIRED" %}</td>
      <td>Set this to <code>authorization_code</code> to tell the Token Endpoint that your application wants to exchange an authorization code for an ID koken and access token. </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>It identifies your application. This parameter value is generated during registration.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code" req="REQUIRED" %}</td>
      <td>The intermediate opaque credential received in the Authorization Response.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirect_uri" req="REQUIRED" %}</td>
      <td>It is the URL to which users are redirected once the authentication is complete. It MUST match the value used in the Authorization Request.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_secret" req="REQUIRED" %}</td>
      <td>Contains the a key you reveiced when registering your application. This ensures that the request to get the id token and access token is made only from your application, and not from a potential attacker that may have intercepted the authorization code.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code_verifier" req="OPTIONAL" %}</td>
      <td>High-entropy cryptographic random string using the unreserved characters [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~", with a minimum length of 43 characters and a maximum length of 128 characters. This parameter is REQUIRED if you required PKCE to be enforced.</td>
    </tr>
  </tbody>
</table>


### Response

<code>200</code> <code>application/json</code>

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="access_token" req="" %}</td>
      <td>Allows an application to retrieve consented user information from the UserInfo Endpoint.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="token_type" req="" %}</td>
      <td>Provides your application with the information required to successfully utilize the access token. Returned value is <code>Bearer</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="id_token" req="" %}</td>
      <td>A security token that contains information about the authentication of an user, and potentially other requested claim data's. The <code>id_token</code> value is represented as a signed and encrypted JWT. So, before being able to use the ID Token claims you will have to decrypt and verify the signature (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).</td>      
    </tr>
  </tbody>
</table>

{% endtab %}

{% endtabs %}


### Example

{% tabs TokenExample %}

{% tab TokenExample Public- and private-key %}

***Request***

```http
POST /token HTTP/1.1
Host: openid.c2id.com
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
 &code=SplxlOBeZQQYbYS6WxSbIA
 &redirect_uri=https%3A%2F%2Fclient.example.org%2Fcb
 &client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer
 &client_assertion=PHNhbWxwOl ... ZT
```

***Response***

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


{% endtab %}

{% tab TokenExample Secret key %}

***Request***

```http
POST /token HTTP/1.1
Host: openid.c2id.com
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
 &code=SplxlOBeZQQYbYS6WxSbIA
 &redirect_uri=https%3A%2F%2Fclient.example.org%2Fcb
 &client_id=s6BhdRkqt3
 &client_secret=PHNhbWxwOl ... ZT
```

***Response***

```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache

{
  "id_token": "eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2R0NNIn0..UPzPZWb
     Da_ZvysMK.7ZXAFd24uTT35_gzrdYeuLBPrPR3Gc8VdB7L7MgZWgS4hiP
     72URWNDPbOMLYw4xHx2CVKPGp9K0L05UeSMDcB39n_anV5nZ3BbkNsufx
     RiANOfoxx2W5jsb8Fj5W8F862wRWmClxTOosszauVhD6ZbhpJM0k9Iw7T
     CmwlmK3WMg9aE-gSNlvsjgrfB5QFmgYH2PWF1YdWZ1gCdCw3rz1XvxHPV
     yR9PfSy7SFFEoZos-2Y_rlO4R5_Oel3xy0YA_OucJVnV2x6oblxQ4TBXB
     8YMCYyk3m7aS_S_oEs-2yAGCbQgwKU9jwqytF8Yw5X_rZmcbTpdvAF5qu
     ozfnoiW2ijHxr6xlH_8cibSIjhKOHEPCBTc8AeAb9nHLGrx0H1q02o7nz
     U-TwxUayrHXLBKd72l6aD8RxwCziATzjVWnvVVR7BmvOAV8L8IY_DTGgn
     iH2NlHL6_2KVtuB8czkDjEToE-JUfuzoedja9PTzRp6paO3ZpXSQcLl6a
     6qBe526hMNEiK9VPRWPOJ8xIqwpg3mSeMjdkvSS6A9xJVH_xEy9jzts1n
     k2ge-YGrZZiQt8Do7NCd-ic7_HU8timZ_mfPFc8NDYgr0WtPefDQlC6en
     8sUcMjuhuZOx_A3cQ7Mvoq662meUbkN64z50oBoh8Drora69I85zXQwes
     sR9f4z0th2-XDDrPxPop6yuJx8vMmRQNhN55qvwxgFMTEJyvDNAVfBA9s
     FZlj4hubY3wtYP5nLADjIFLresbrsu6iFQaE7v01FUMMDXcvBi_hw-M9s
     0nBuWsQa2rZRcrVJOK9HVXUxXdUfTNL4MrrG5UzT7gdtcpesXeFVLSJtq
     7HEGlHi3xaefgo4P5GN562CGVUl41BSmoBJT9oS5YJWKJOEOfpcAhYLKM
     5iyMbgOxVz1Fz7z6Pfcd-PRcRlSQlHBXCdhP01AmRw-H_bdoKFIM1D33B
     3AmmEKD6XRe8XM79F_gwySJ3AIWUzVLpJxe1lUphzIgy5O-VleJWyKl3D
     nAkCQwvqV-P-MrjirZckzlDjjfyOlEA_KNAK-PwCvZ5Yh_Wv8f-8LXUWJ
     ewfOCZmOM5pSKYXl-oZ.hfcIWiYPCtQMheNN8FB0Ww"
  "access_token": "SlAV32hkKG",
  "token_type": "Bearer",
  "expires_in": 3600,
}
```

{% endtab %}

{% endtabs %}

Example of a decrypted id_token:

```
{
	"sub": "6g2k9rgglem2dttw5d51ulkxpv24phwatiu6",
	"aud": "WXw9DMqkEv",
	"birthdate": "1974-10-23",
	"gender": "male",
	"name": "John Ronald R Tolkien",
	"iss": "https://oidc.prd.itsme.services/clientsecret-oidc/csapi/v0.1",
	"nonce": "nonce",
	"nbf": 1699538107,
	"exp": 1699538407,
	"iat": 1699538107
}
```

<a id="UserInfoReq"></a>
## UserInfo Request

{% tabs UserInfoRequest %}

{% tab UserInfoRequest Public- and private-key %}

<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/userinfo</code></b>

The UserInfo Endpoint returns previously consented user profile information to your application. In other words, if the required claims are not returned in the ID Token, you can obtain the additional claims by presenting the access token to the itsme® UserInfo Endpoint. This is achieved by sending a HTTP GET request to the Userinfo Endpoint, passing the access token value in the Authorization header using the Bearer authentication scheme.

This is illustrated in the example below.


### Response

<code>200</code> <code>application/json</code>

The UserInfo Response is represented as a signed and encrypted JWT. So, before being able to extract the claims you will have to decrypt and verify the signature (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).


{% endtab %}

{% tab UserInfoRequest Secret key %}

<b><code>GET https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/clientsecret-oidc/csapi/v0.1/connect/userinfo</code></b>

The UserInfo Endpoint returns previously consented user profile information to your application. In other words, if the required claims are not returned in the ID Token, you can obtain the additional claims by presenting the access token to the itsme® UserInfo Endpoint. This is achieved by sending a HTTP GET request to the Userinfo Endpoint, passing the access token value in the Authorization header using the Bearer authentication scheme.

This is illustrated in the example below.


### Response

<code>200</code> <code>application/json</code>

The UserInfo Response is represented as a signed and encrypted JWT. So, before being able to extract the claims you will have to decrypt and verify the signature (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).

{% endtab %}

{% endtabs %}


### Example

***Request***

```http
GET /userinfo HTTP/1.1
Host: server.example.com
Authorization: Bearer SlAV32hkKG
```

***Response***

This is an response example containing all possible claims for a Belgian account:

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
	"http://itsme.services/v2/claim/validityFrom": {
		"http://itsme.services/v2/claim/BEeidSn": "2018-11-08T00:00:00Z"
	},
	"sub": "e3xad7upx64grm14ttpnx4c586ve8gy0gp38",
	"birthdate": "1978-11-01",
	"http://itsme.services/v2/claim/claim_citizenship_as_iso": "BEL",
	"gender": "male",
	"http://itsme.services/v2/claim/birthdate_as_string": "01.11.1978",
	"http://itsme.services/v2/claim/IDDocumentType": "I",
	"iss": "https://oidc.uat.itsme.services/clientsecret-oidc/csapi/v0.1",
	"http://itsme.services/v2/claim/validityTo": {
		"http://itsme.services/v2/claim/BEeidSn": "2028-11-10T00:00:00Z"
	},
	"http://itsme.services/v2/claim/claim_citizenship": "BE",
	"locale": "FR",
	"http://itsme.services/v2/claim/issuance_locality": {
		"http://itsme.services/v2/claim/BEeidSn": "BRUXELLES"
	},
	"email": "test@itsme.be",
	"http://itsme.services/v2/claim/place_of_birth": {
		"city": "Brussels",
		"formatted": "Brussels"
	},
	"address": {
		"locality": "TONGEREN",
		"street_address": "Jekerstraat 39",
		"postal_code": "3700",
		"formatted": "Jekerstraat 39 3700 TONGEREN"
	},
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
		"msisdn": "0032485694175"
	},
	"http://itsme.services/v2/claim/BENationalNumber": "99060427181",
	"phone_number_verified": true,
	"given_name": "George",
	"picture": "https://oidc.uat.itsme.services/clientsecret-oidc/csapi/v0.1/picture",
	"http://itsme.services/v2/claim/verificationDate": {
		"http://itsme.services/v2/claim/place_of_birth": "2023-04-12T15:02:23Z",
		"birthdate": "2023-04-12T15:02:23Z",
		"address": "2023-04-12T15:02:23Z",
		"http://itsme.services/v2/claim/claim_citizenship_as_iso": "2023-04-12T15:02:23Z",
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
		"http://itsme.services/v2/claim/physical_person_photo": "2023-04-12T15:02:23Z"
	},
	"aud": "WXw9DMqkEv",
	"http://itsme.services/v2/claim/IDIssuingCountry": {
		"http://itsme.services/v2/claim/place_of_birth": "BEL",
		"birthdate": "BEL",
		"address": "BEL",
		"http://itsme.services/v2/claim/claim_citizenship_as_iso": "BEL",
		"gender": "BEL",
		"http://itsme.services/v2/claim/birthdate_as_string": "BEL",
		"http://itsme.services/v2/claim/BENationalNumber": "BEL",
		"given_name": "BEL",
		"http://itsme.services/v2/claim/claim_citizenship": "BEL",
		"picture": "BEL",
		"name": "BEL",
		"http://itsme.services/v2/claim/IDDocumentSN": "BEL",
		"http://itsme.services/v2/claim/BEeidSn": "BEL",
		"family_name": "BEL",
		"http://itsme.services/v2/claim/physical_person_photo": "BEL"
	},
	"name": "George Tǎnka",
	"http://itsme.services/v2/claim/IDDocumentSN": "431522485012",
	"phone_number": "+32 485694175",
	"http://itsme.services/v2/claim/BEeidSn": "431522485012",
	"family_name": "Tǎnka",
	"http://itsme.services/v2/claim/physical_person_photo": {
		"format": "image/jpeg",
		"value": "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"
	},
	"nbf": 1681314190,
	"exp": 1681314490,
	"iat": 1681314190
}
```


## Revoke Request

{% tabs RevokeRequest %}

{% tab RevokeRequest Public- and private-key %}

Not applicable.

{% endtab %}

{% tab RevokeRequest Secret key %}

<b><code>POST https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/clientsecret-oidc/csapi/v0.1/connect/revoke</code></b>

The Revocation Endpoint enables your application to notify itsme® that a previously obtained access token is no longer needed and MUST be revoked.

### Parameters

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="token" req="REQUIRED" %}</td>
      <td>The <code>access_token</code> previously obtained that you want to revoke.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="token_type_hint" req="OPTIONAL" %}</td>
      <td>A hint about the type of the token submitted for revocation. You MAY pass this parameter in order to help itsme® to optimize the token lookup. If the server is unable to locate the token using the given hint, it MUST extend its search across all of its supported token types. If used, this is set to <code>access_token</code> because itsme® API don't support refresh tokens.</td>
    </tr>
  </tbody>
</table>

### Response

<code>200</code> 

itsme® responds with HTTP status code 200 if the token has been revoked successfully or if the client submitted an invalid token.

<aside class="notice">Invalid tokens do not cause an error response since your application cannot handle such an error in a reasonable way. Moreover, the purpose of the revocation request, invalidating the particular token, is already achieved.
</aside>

{% endtab %}

{% endtabs %}

### Example

{% tabs RevokeExample %}

{% tab RevokeExample Public- and private-key %}

Not applicable.

{% endtab %}

{% tab RevokeExample Secret key %}

***Request***

```http
POST /connect/revoke HTTP/1.1
Host: server.example.com
Content-Type: application/x-www-form-urlencoded
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW

token=45ghiukldjahdnhzdauz&token_type_hint=refresh_token
```

***Response***


```http
HTTP/1.1 200 OK

```

{% endtab %}

{% endtabs %}


