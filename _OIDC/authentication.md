---
layout: OIDC
title: Authentication API
permalink: authentication/
nav_order: 4
toc_list: true
---

# Overview

itsme® API is based on the Authorization Code Flow of OpenID Connect 1.0. The API can be used to verify the end-users' identity and obtain basic profile information about gien end-users. 

The diagram below describes the **Authentication** process and how your systems should integrate with itsme® :
  
 ![Sequence diagram describing the OpenID flow](/doc/public/images/OpenID_SeqDiag.png)

To get to this result please make sure you 

<ol>
  <li>add itsme® button to your front-end page so the user can indicate he wishes to authenticate with itsme® : <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/buttons-1518207548" target="blank">itsme® button specifications</a>.</li>
  <li>create the <a href="#AuthNReq" >Authorization Request</a> to authenticate the User. This request will redirect the user to the itsme® app. itsme® will then authenticates the user by asking him 
    <ul type>
      <li>to enter his phone number on the itsme® sign-in page</li> 
      <li>authorize the release of some information to your application</li>
      <li>to provide his credentials (itsme® code, fingerprint or FaceID)</li>
    </ul><br>It is also in this Authorization Request that you will be able to request claims about the user and the Authentication event.</li>
  <li><a href="#AuthNResp" >collect the Authorization Code</a> once the user has been authenticated and redirected by itsme® to your mobile or web application.</li>
  <li><a href="#TokenReq" >exchange the Authorization Code for an ID token</a> (e.g. identifying the user) and an Access Token.</li>
  <li>Obtain the additional claims by <a href="#UserInfoReq" >presenting the access token to the itsme® UserInfo Endpoint</a> if the required claims are not returned in the ID token.</li>
  <li>Confirm the success of the operation and display a success message.</li>
</ol>

# Guides

## Generate itsme® button

First, you will need to create a button to allow your users to authenticate with itsme®. Check the <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/buttons-1518207548" target="blank">Button design guide</a> before you start the integration. 

Upon clicking this button, the user will be redirected to our Front-End. itsme® then take care of authenticating him.

## Securing the exchange of information

To protect the exchange of sensitive information and ensure the requested information gets issued to a legitimate application and not some other party, the OpenID Connect protocol uses JSON Web Token (JWT) which can be signed and/or encrypted. Among the methods described in OpenID specification, itsme® supports 2 authentication methods to secure communications between your backend and itsme®:

<ul>
  <li>"Private key JWT" is based on a public/private key pair (asymmetric encryption). It is therefore the most secure option</li>
  <li>"Client secret" is based on a shared Secret key (symmetric encryption). It can be easier to implement in some cases</li>
</ul>

<aside class="notice">You will have to choose between one of these methods when <a href="https://belgianmobileid.github.io/doc/getting-started.html#getting-started" target="blank">registering your project</a>.
</aside>

### Public-private key pair and JWKSet URI

This method uses a pair of keys (1 public, 1 private) to encrypt and decrypt senders’ and recipients’ sensitive data. It is also known as public-key cryptography or asymetric encryption.

<aside class="notice">This method requires that each party exposes its public keys in the form of a JWK Set document on a publicly accessible URI, and keep its private keys for itself. 
</aside>

You can retrieve the itsme® JWK Set from the URI metioned as <code>jwks_uri</code> in our <a href="https://belgianmobileid.github.io/doc/authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a>.

<aside class="notice">Refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more on signing and encrypting tokens.
</aside>

<aside class="notice">Whatever the tool you are choosing to create your key pairs, don't forget to send your JWK Set URI by email to <a href = "mailto: onboarding@itsme.be">onboarding@itsme.be</a> and itsme® will make sure to complete the configuration for you in no time!
</aside>

<aside class="notice">The algorithms – needed to sign and/or encrypt a JWT or to authenticate to our Token Endpoint – are listed in the <a href="https://belgianmobileid.github.io/doc/authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a> for more information.
</aside>


### Secret key method

Secret key cryptography method uses the same secret key to encrypt and decrypt sensitive information. This approach is the inverse of public- and private-key encryption.

This method requires the exchange of a static secret to be held by both the sender and the data receiver. The secret value will be provided by itsme® when <a href="https://belgianmobileid.github.io/doc/getting-started.html#getting-started" target="blank">registering your project</a>.

<aside class="notice">The algorithms – needed to sign and/or encrypt a JWT or to authenticate to our Token Endpoint – are listed in the <a href="https://belgianmobileid.github.io/doc/authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a> for more information.
</aside>

<aside class="notice">If you choose to go with the secret key method, you will be able to specify if the ID Token JWT needs to be signed with the an asymmetric algorithm (e.g. <code>RS256</code>) or with a symmetric algorithm (e.g. : <code>HS256</code>). When using the <code>RS256</code> algorithm, our public keys will be needed to verify the signature. This information can be found in our <a href="https://belgianmobileid.github.io/doc/authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a>, using the key <code>jwks_uri</code>.
</aside>

### PKCE-enhanced flow

Whatever the chosen authentication method, itsme® also supports an extra security extension named Proof of Key for Code Exchange (<a href="https://datatracker.ietf.org/doc/html/rfc7636" target="blank">PKCE</a>). This additionnal layer of security is intended mitigate some Authorization Code interception attacks. We strongly advise to enable enforcement of this mechanism. Please ask our onboarding team to do so when registering your project.

PKCE implies choosing a random string, named <code>code_verifier</code>, and then generating a SHA256 hash of that string, named <code>code_challenge</code>. The code_challenge has to be sent along with the Authorization Request, while the code_verifier must be sent with the Token Request, allowing our backend to make sure both requests are issued by the same source.

<aside class="notice"><code>code_verifier</code> MUST contain only the unreserved characters [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~", with a minimum length of 
43 characters and a maximum length of 128 characters.</aside>

<code>code_challenge</code> can then be obtained via this kind of instructions:

```
var hash = code_verifier.createHash('sha256');
var code_challenge = base64url.encode(hash);
```

### Signing, encrypting and decoding JWTs

Libraries implementing JWT and the JOSE specs JWS, JWE, JWK, and JWA are listed <a href="https://openid.net/developers/jwt/" target="blank">here</a>.


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

An HTTP status <code>200 OK</code> or <code>302 Found</code> is issued whenever your request was a success. You see this type of response in our examples like the one where we successfully retrieve the <a href="https://belgianmobileid.github.io/doc/authentication/#example-1" target="blank">Token Response</a> : 

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
            <td>The authenticated client is not authorized to use this authorization grant type.</td>
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

## Mapping the user

### Mapping using <code>sub</code> claim

To sign in successfully in your web desktop, mobile web or mobile application, a given user must be mapped to a user account in your database. By default, your application Server will use the subject identifier, or <code>sub</code> claim, in the ID Token to identify and verify a user account. The <code>sub</code> claim is a string that uniquely identifies a given user account. The benefit of using a <code>sub</code> claim is that it will not change, even if other user attributes (email, phone number, etc) associated with that account are updated.

If no user record is storing the <code>sub</code> claim value, then you should allow the user to associate his new or existing account to the <code>sub</code>.

All these flows are depicted in the itsme® B2B portal.

### Benefit of <code>sub</code> claim

The benefit of using a <code>sub</code> claim is that it will not change, not even if other user attributes (email, phone number, etc.) associated with that account are updated.

### Deleting and re-creating an itsme® account

In a limited number of cases (e.g. technical issue,…) a user could ask itsme® to ‘delete’ his account. As a result the specific account will be ‘archived’ (for compliancy reasons) and thus also the unique identifier(s) (e.g. "sub").

If the same user would opt to re-create an itsme® afterwards, he will need to re-bind his itsme® account with your application server, in the same way as for the initial binding. After successful re-binding you will need to overwrite the initial reference with the new <code>sub</code> claim value in your database.


# API reference

<a id="OpenIDConfig"></a>
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


<a id="AuthNReq"></a>
## Authorization Request

{% tabs AuthorizationRequest %}

{% tab AuthorizationRequest Public- and private-key %}

<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/authorization</code></b>

### Parameters

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>It identifies your application. This parameter value is generated during registration.</td>
    </tr>
     <tr>
      <td>{% include parameter.html name="response_type" req="REQUIRED" %}</td>
      <td>This defines the processing flow to be used when forming the response. Because itsme® supports the Authorization Code Flow, this value MUST be <code>code</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="scope" req="REQUIRED" %}</td>
      <td>
        It allows your application to express the desired scope of the access request. Each scope returns a set of user attributes. The scopes an application should request depend on which user attributes your application needs. Once the user authorizes the requested scopes, his details are returned in an ID Token and are also available through the UserInfo Endpoint.<br><br>All scope values must be space-separated.<br><br>The basic (and required) scopes are <code>openid</code> and <code>service</code>. Beyond that, your application can ask for additional standard scopes values which map to sets of related claims are: <code>profile</code> <code>email</code> <code>address</code> <code>phone</code> <code>eid</code><br />
        <table>
          <tr>
            <td>{% include parameter.html name="service" req="REQUIRED" %}</td><td>It indicates the itsme® service your application intends to use, e.g. <code>service:TEST_code</code> by replacing "TEST_code" with the service code generated during registration.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="openid" req="REQUIRED" %}</td><td>It indicates that your application intends to use the OpenID Connect protocol to verify a user's identity by returning a <code>sub</code> claim which represents a unique identifier for the authenticated user.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="profile" req="OPTIONAL" %}</td><td>Returns claims that represent basic profile information, specifically <code>family_name</code>, <code>given_name</code>, <code>name</code>, <code>gender</code>, <code>locale</code>, <code>picture</code> and <code>birthdate</code>.<br><br>If requested, a value SHALL always be returned for the above claims except for the <code>given_name</code> claim which MAY NOT be returned if the user doesn't have any first name(s).</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="email" req="OPTIONAL" %}</td><td>Returns the <code>email</code> claim, which contains the user's email address, and <code>email_verified</code>, which is a boolean indicating whether the email address was verified by the user.<br><br>If requested, a value SHALL always be returned for the <code>email_verified</code> claim only if <code>email</code> claim is filled with a value, whereas the <code>email</code> claim SHALL always be returned only if the user gave us an email address.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="address" req="OPTIONAL" %}</td><td>Returns user's postal address, represented as JSON Object containing some or all of these members <code>formatted</code> <code>street_address</code> <code>postal_code</code> <code>locality</code><br><br>If requested, a value SHALL always be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="phone" req="OPTIONAL" %}</td><td>Returns the <code>phone_number</code> claim, which contains the user's phone number, and <code>phone_number_verified</code>, which is a boolean indicating whether the phone number was verified by the user.<br><br>If requested, a value SHALL always be returned for the above claims.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="eid" req="OPTIONAL" %}</td><td>Returns the <code>http://itsme.services/v2/claim/BENationalNumbe</code> claim, which contains the unique identification number of natural persons who are registered in Belgium, and <code>http://itsme.services/v2/claim/BEeidSn</code>, which is a string indicating the Belgian ID card number.<br><br>If requested, a value SHALL always be returned for the above claims.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirect_uri" req="REQUIRED" %}</td>
      <td>It is the URL to which users are redirected once the authentication is complete. <br><br>The following restrictions apply to redirect URIs:
        <tabul>
          <tabli>The redirect URI MUST match the value preregistered during the registration.</tabli>
          <tabli>The redirect URI MUST begin with the scheme <code>https</code> (refer to <a href="https://belgianmobileid.github.io/doc/authentication/#certificates-and-website-security" target="blank">this section</a> for more information). There is an exception for localhost redirect URIs that are only permitted for development purposes, it’s not for use in production.</tabli>
          <tabli>The redirect URI SHALL NOT be a custom URL.</tabli>
          <tabli>The fragment identifier introduced by a hash mark <code>#</code> SHALL NOT be used.</tabli>
          <tabli>The redirect URI is case-sensitive. Its case MUST match the case of the URL path of your running application. For example, if your application includes as part of its path <code>.../abc/response-oidc</code>, do not specify <code>.../ABC/response-oidc</code> in the redirect URI. Because the web browser treats paths as case-sensitive, cookies associated with <code>.../abc/response-oidc</code> MAY be excluded if redirected to the case-mismatched <code>.../ABC/response-oidc</code> URL.</tabli>
          <tabli>If relevant (in case you have a mobile app) make sure that your redirect URIs support the <a href="https://developer.apple.com/ios/universal-links/" target="blank">Universal links</a> and <a href="https://developer.android.com/training/app-links" target="blank">App links</a> mechanism. Functionally, it will allow you to have only one single link that will either open your desktop web application, your mobile app or your mobile site on the User’s device. Universal links and App links are standard web links (http://mydomain.com) that point to both a web page and a piece of content inside an app. When a Universal Link is opened, the app OS checks to see if any installed app is registered for that domain. If so, the app is launched immediately without ever loading the web page. If not, the web URL is loaded into the webbrowser.</tabli>
        </tabul>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="state" req="Strongly RECOMMENDED" %}</td>
      <td>Specifies any string value that your application uses to maintain state between your Authorization Request and the Authorization Server's response. You can use this parameter for several purposes, such as directing the user to the correct resource in your application and mitigating cross-site request forgery.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="nonce" req="Strongly RECOMMENDED" %}</td>
      <td>A string value used to associate a session with an ID Token, and to mitigate replay attacks. The value is passed through unmodified from the Authorization Request to the ID Token.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="ui_locales" req="OPTIONAL" %}</td>
      <td>Indicates the user's preferred languages for the itsme® sign-in page, represented as a space-separated list of language tag values, ordered by preference.<br><br>Possible values : <code>fr</code> <code>nl</code> <code>de</code> <code>en</code></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="display" req="OPTIONAL" %}</td>
      <td>Specify how the itsme® sign-in page should be displayed to the user. If set to <code>touch</code>, it SHOULD displays the itsme® sign-in page with a device that leverages a touch interface. If set to <code>page</code>, the itsme® sign-in UI SHOULD be consistent with a full page view of the User-Agent. If the <code>display</code> parameter is not specified, this is the default display mode.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="acr_values" req="OPTIONAL" %}</td>
      <td>Indicates the authentication method required to process the request, represented as a space-separated list of tag values, ordered by preference.<br><br>Possible values : <code>http://itsme.services/v2/claim/acr_basic</code> <code>http://itsme.services/v2/claim/acr_advanced</code><br><br><b>Note</b> : if these two values are provided only the most constraining authentication method will be applied, e.g. <code>http://itsme.services/v2/claim/acr_advanced</code>.<br />
        <table>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/acr_basic" req="" %}</td><td>It lets the user to choose either fingerprint usage (if device is compatible) or itsme® code. If the <code>acr_values</code> parameter is not specified, this is the default authentication method.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/acr_advanced" req="" %}</td><td>It forces the user to use his itsme® code.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="claims" req="OPTIONAL" %}</td>
      <td>Allows to request specific user's details ("claims"). You can choose to receive those claims either in the ID Token (from /token endpoint) or in the UserInfo object (from /userinfo endpoint).<br />It MUST be a JSON object containing an <code>{"id_token":{...}</code> member or a <code>{"userinfo":{...}</code> member respectively. This member will then contain all the desired claims together with indication whether the claim is voluntary (returned if available) or essential (flow will stop if unavailable) - see example below.<br><b>Note</b>: to avoid the need of a /userinfo request, itsme® recommends to retrieve the claims directly from the ID Token.<br><br>Supported claims are listed below.<br />
        <table>
          <tr>
            <td>{% include parameter.html name="name" req="OPTIONAL" %}</td><td>Returns user's full name in displayable form including all name parts, possibly including titles and suffixes.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="given_name" req="OPTIONAL" %}</td><td>Returns user's given name(s) or first name(s). Note that in some cultures, people can have multiple given names; all can be present, with the names being separated by space characters.<br><br>If requested, a value MAY NOT be returned if the user doesn't have any first name(s).</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="family_name" req="OPTIONAL" %}</td><td>Returns user's surname(s) or last name(s). Note that in some cultures, people can have multiple family names or no family name; all can be present, with the names being separated by space characters.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="birthdate" req="OPTIONAL" %}</td><td>Return user's birthday, represented as a string in YYYY-MM-DD date format.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID documents. Users with a BE document will always be 16 years old or more, users with a NL document will always be 18 or more.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/birthdate_as_string" req="OPTIONAL" %}</td><td>Returns user's birthday. It is considered as official or at least coming unprocessed from the ID document.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents. Users with a BE document will always be 16 years old or more, users with a NL document will always be 18 or more.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="gender" req="OPTIONAL" %}</td><td>Returns user's gender. Possible values are : <code>female</code> <code>male</code> <code>unknown</code> <code>n/a</code> (note: Belgian accounts can only be <code>female</code> or <code>male</code>)<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="locale" req="OPTIONAL" %}</td><td>Returns user's mobile phone language, represented as a string format. Possible values are : <code>NL</code> <code>FR</code> <code>DE</code> <code>EN</code><br><br>If requested, a value MAY NOT be returned for this claim.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="picture" req="OPTIONAL" %}</td><td>Returns user's ID picture, represented as a URL string. This URL refers to an image file (for example, a JPEG, JPEG2000, or PNG image file).<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID documents.<br /><br />
            Accessing this URL has to be done with your bearer token. Example:<br />
            <code>
              GET /v2/picture HTTP/1.1<br />
              Host: idp.prd.itsme.services<br />
              Authorization: Bearer SlAV32hkKG
            </code></td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="email" req="OPTIONAL" %}</td><td>Returns user's email address.<br><br>If requested, a value MAY NOT be returned if the user doesn't gave us an email address.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="email_verified" req="OPTIONAL" %}</td><td>Returns <code>true</code> if the user's e-mail address is verified; otherwise <code>false</code>.<br><br><b>Note</b> : currently, itsme® always returns <code>false</code> for this claim because the email verification feature is not yet implemented in our systems.<br><br>If requested, a value SHALL NOT be returned if the <code>email</code> claim is not filled with a value.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="phone_number" req="OPTIONAL" %}</td><td>Returns user's phone number, represented as a string format. For example : <code>[+][country code] [subscriber number including area code]</code>.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="phone_number_verified" req="OPTIONAL" %}</td><td>Returns <code>true</code> if the user's phone number is verified; otherwise <code>false</code>.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="address" req="OPTIONAL" %}</td><td>Returns user's postal address, represented as JSON Object containing some or all of these members <code>formatted</code> <code>street_address</code> <code>postal_code</code> <code>locality</code>.<br><br>If requested, a value SHALL always be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/claim_citizenship" req="OPTIONAL" %}</td><td>Returns user's nationality. The format is directly depending on the underlying ID document: for Belgian ID documents this is represented as a string, and for Dutch ID documents this is represented in the <a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a> format.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/claim_citizenship_as_iso" req="OPTIONAL" %}</td><td>Returns user's nationality. The format is always the <a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a> format. Please be aware that this claim is computed by itsme® for users with a Belgian ID document on a best effort basis. For the original value as stored on the ID document, see http://itsme.services/v2/claim/claim_citizenship above.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID documents.</td>
          </tr>
           <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/place_of_birth" req="OPTIONAL" %}</td><td>Returns user's place of birth, represented as a JSON Object containing some or all of these members <code>formatted</code> <code>city</code> <code>country</code>.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/physical_person_photo" req="OPTIONAL" %}</td><td>Returns user's ID picture, represented as a JSON Object containing some or all of these members <code>format</code> <code>value</code>.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/BEeidSn" req="OPTIONAL" %}</td><td>Returns user's Belgian ID document number, represented as a string with 12 digits in the form xxx-xxxxxxx-yy. (the check-number yy is the remainder of the division of xxxxxxxxxx by 97) for Belgian citizens, or starting with a letter and nine digits in the form B xxxxxxx xx for EU/EEA/Swiss citizens.<br><br>If requested, a value SHALL always be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/claim_device" req="OPTIONAL" %}</td><td>Returns user's phone information, represented as a JSON Object containing some or all of these members <code>os</code> <code>appName</code> <code>appRelease</code> <code>deviceLabel</code> <code>debugEnabled</code> <code>deviceID</code>	<code>osRelease</code> <code>manufacturer</code> <code>deviceLockLevel</code> <code>smsEnabled</code> <code>rooted</code> <code>msisdn</code> <code>deviceModel</code>	<code>sdkRelease</code>.<br><br>If requested, a value MAY NOT be returned for this claim.</td>       
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/transaction_info" req="OPTIONAL" %}</td><td>Returns information about the itsme® transaction, represented as a JSON Object containing some or all of these members <code>securityLevel</code> <code>bindLevel</code> <code>appRelease</code>.<br><br>If requested, a value MAY NOT be returned for this claim.</td>
           </tr> 
           <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/BENationalNumber" req="OPTIONAL" %}</td><td>Returns user's Belgian unique identification number, represented as a string with 11 digits in the form YY.MM.DD-xxx.cd where YY.MM.DD is the birthdate of the person, xxx a sequential number (odd for males and even for females) and cd a check-digit. Some exceptions could apply.<br><br>If requested, a value SHALL always be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/validityFrom" req="OPTIONAL" %}</td><td>Returns user's Belgian ID document issuance date, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. Can only be returned in combination with claim http://itsme.services/v2/claim/BEeidSn.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID document.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/validityTo" req="OPTIONAL" %}</td><td>Returns user's Belgian ID card expiry date, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. Can only be returned in combination with claim http://itsme.services/v2/claim/BEeidSn.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and MAY NOT be returned for users with a Dutch ID document.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/verificationDate" req="OPTIONAL" %}</td><td>Returns the date when the user's document was read for the last time, represented as a string in YYYY-MM-DDThh:mm:ss date format specified by ISO 8601.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID document.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/IDDocumentSN" req="OPTIONAL" %}</td><td>Returns the Dutch ID card/passport number, represented as a string composed of letters at positions 1 and 2 ; letters or digits from positions 3-8: ; and a digit at position 9. The letter ‘O’ is not used in the document numbers. The digit ‘0’ (zero) MAY be used.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/IDDocumentType" req="OPTIONAL" %}</td><td>Returns the Dutch ID card/passport document type.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="request_uri" req="OPTIONAL" %}</td>
      <td>A URL using the https scheme referencing a resource containing a JWT whose claims are the request parameters. The <code>request_uri</code> parameter is used to secure parameters in the Authorization Request from tainting or inspection when sending the request to the itsme® Authorization Endpoint.<br><br>If the <code>request_uri</code> parameter is used, the JWT MUST be signed and MUST contain the claims <code>iss</code> (issuer) and <code>aud</code> (audience) as members. The <code>iss</code> value SHOULD be your <code>client_id</code>. The <code>aud</code> value SHOULD be set to <code>https://idp.[e2e/prd].itsme.services/v2/authorization</code>. The JWT MAY also be encrypted. If both signing and encryption are performed, it MUST be signed then encrypted, with the result being a Nested JWT (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).<br><br>The following restrictions apply to request URIs:
        <tabul>
          <tabli>The request URI MUST be preregistered during the registration.</tabli>
          <tabli>The request URI MUST contain the TCP port number <code>443</code>. Example : https://test.istme.be:443/p/test</tabli>
          <tabli>The request URI MUST begin with the scheme <code>https</code> (refer to <a href="https://belgianmobileid.github.io/doc/authentication/#certificates-and-website-security" target="blank">this section</a> for more information). The usage of localhost request URIs that are not permitted.</tabli>
          <tabli>The request URI JWT MUST be publicly accessible.</tabli>
        </tabul>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="request" req="OPTIONAL" %}</td>
      <td>It represents the request as a JWT whose Claims are the request parameters. The <code>request</code> parameter is used to secure parameters in the Authorization Request from tainting or inspection when sending the request to the itsme® Authorization Endpoint.<br><br>If the <code>request</code> parameter is used, the JWT MUST be signed and MUST contain the claims <code>iss</code> (issuer) and <code>aud</code> (audience) as members. The <code>iss</code> value SHOULD be your <code>client_id</code>. The <code>aud</code> value SHOULD be set to <code>https://idp.[e2e/prd].itsme.services/v2/authorization</code>. The JWT MAY also be encrypted. If both signing and encryption are performed, it MUST be signed then encrypted, with the result being a Nested JWT (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code_challenge" req="OPTIONAL" %}</td>
       <td>A challenge derived from the code verifier by applying a S256 hash. This parameter is REQUIRED if you requested PKCE to be enforced.
       </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code_challenge_method" req="OPTIONAL" %}</td>
       <td>Code verifier transformation method.<br><br>It MUST be set to <code>S256</code>.
       </td>
    </tr>
  </tbody>
</table>

<a id="AuthNResp"></a>
### Response

<code>302</code> <code>application/x-www-form-urlencoded</code>

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="code" req="" %}</td>
      <td>An intermediate opaque credential of 36 characters used to retrieve the ID Token and Access Token.<br><br><b>Note</b> : the code has a lifetime of 3 minutes.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="state" req="" %}</td>
      <td>The string value provided in the Authorization Request. You SHOULD validate that the value returned matches the one supplied.</td>
    </tr>
  </tbody>
</table>

{% endtab %}

{% tab AuthorizationRequest Secret Key %}

<b><code>GET https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/clientsecret-oidc/csapi/v0.1/connect/authorize</code></b>

### Parameters

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>It identifies your application. This parameter value is generated during registration.</td>
    </tr>
     <tr>
      <td>{% include parameter.html name="response_type" req="REQUIRED" %}</td>
      <td>This defines the processing flow to be used when forming the response. Because itsme® supports the Authorization Code Flow, this value MUST be <code>code</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="scope" req="REQUIRED" %}</td>
      <td>
        It allows your application to express the desired scope of the access request. Each scope returns a set of user attributes. The scopes an application should request depend on which user attributes your application needs. Once the user authorizes the requested scopes, his details are returned in an ID Token and are also available through the UserInfo Endpoint.<br><br>All scope values must be space-separated.<br><br>The basic (and required) scopes are <code>openid</code> and <code>service</code>. Beyond that, your application can ask for additional standard scopes values which map to sets of related claims are: <code>profile</code> <code>email</code> <code>address</code> <code>phone</code> <code>eid</code><br />
        <table>
          <tr>
            <td>{% include parameter.html name="service" req="REQUIRED" %}</td><td>It indicates the itsme® service your application intends to use, e.g. <code>service:TEST_code</code> by replacing "TEST_code" with the service code generated during registration.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="openid" req="REQUIRED" %}</td><td>It indicates that your application intends to use the OpenID Connect protocol to verify a user's identity by returning a <code>sub</code> claim which represents a unique identifier for the authenticated user.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="profile" req="OPTIONAL" %}</td><td>Returns claims that represent basic profile information, specifically <code>family_name</code>, <code>given_name</code>, <code>name</code>, <code>gender</code>, <code>locale</code>, <code>picture</code> and <code>birthdate</code>.<br><br>If requested, a value SHALL always be returned for the above claims except for the <code>given_name</code> claim which MAY NOT be returned if the user doesn't have any first name(s).</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="email" req="OPTIONAL" %}</td><td>Returns the <code>email</code> claim, which contains the user's email address, and <code>email_verified</code>, which is a boolean indicating whether the email address was verified by the user.<br><br>If requested, a value SHALL always be returned for the <code>email_verified</code> claim only if <code>email</code> claim is filled with a value, whereas the <code>email</code> claim SHALL always be returned only if the user gave us an email address.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="address" req="OPTIONAL" %}</td><td>Returns user's postal address, represented as JSON Object containing some or all of these members <code>formatted</code> <code>street_address</code> <code>postal_code</code> <code>locality</code><br><br>If requested, a value SHALL always be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="phone" req="OPTIONAL" %}</td><td>Returns the <code>phone_number</code> claim, which contains the user's phone number, and <code>phone_number_verified</code>, which is a boolean indicating whether the phone number was verified by the user.<br><br>If requested, a value SHALL always be returned for the above claims.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="eid" req="OPTIONAL" %}</td><td>Returns the <code>http://itsme.services/v2/claim/BENationalNumbe</code> claim, which contains the unique identification number of natural persons who are registered in Belgium, and <code>http://itsme.services/v2/claim/BEeidSn</code>, which is a string indicating the Belgian ID card number.<br><br>If requested, a value SHALL always be returned for the above claims.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirect_uri" req="REQUIRED" %}</td>
      <td>It is the URL to which users are redirected once the authentication is complete. <br><br>The following restrictions apply to redirect URIs:
        <tabul>
          <tabli>The redirect URI MUST match the value preregistered during the registration.</tabli>
          <tabli>The redirect URI MUST begin with the scheme <code>https</code> (refer to <a href="https://belgianmobileid.github.io/doc/authentication/#certificates-and-website-security" target="blank">this section</a> for more information). There is an exception for localhost redirect URIs that are only permitted for development purposes, it’s not for use in production.</tabli>
          <tabli>The redirect URI SHALL NOT be a custom URL.</tabli>
          <tabli>The fragment identifier introduced by a hash mark <code>#</code> SHALL NOT be used.</tabli>
          <tabli>The redirect URI is case-sensitive. Its case MUST match the case of the URL path of your running application. For example, if your application includes as part of its path <code>.../abc/response-oidc</code>, do not specify <code>.../ABC/response-oidc</code> in the redirect URI. Because the web browser treats paths as case-sensitive, cookies associated with <code>.../abc/response-oidc</code> MAY be excluded if redirected to the case-mismatched <code>.../ABC/response-oidc</code> URL.</tabli>
          <tabli>If relevant (in case you have a mobile app) make sure that your redirect URIs support the <a href="https://developer.apple.com/ios/universal-links/" target="blank">Universal links</a> and <a href="https://developer.android.com/training/app-links" target="blank">App links</a> mechanism. Functionally, it will allow you to have only one single link that will either open your desktop web application, your mobile app or your mobile site on the User’s device. Universal links and App links are standard web links (http://mydomain.com) that point to both a web page and a piece of content inside an app. When a Universal Link is opened, the app OS checks to see if any installed app is registered for that domain. If so, the app is launched immediately without ever loading the web page. If not, the web URL is loaded into the webbrowser.</tabli>
        </tabul>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="state" req="Strongly RECOMMENDED" %}</td>
      <td>Specifies any string value that your application uses to maintain state between your Authorization Request and the Authorization Server's response. You can use this parameter for several purposes, such as directing the user to the correct resource in your application and mitigating cross-site request forgery.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="nonce" req="Strongly RECOMMENDED" %}</td>
      <td>A string value used to associate a session with an ID Token, and to mitigate replay attacks. The value is passed through unmodified from the Authorization Request to the ID Token.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="ui_locales" req="OPTIONAL" %}</td>
      <td>Indicates the user's preferred languages for the itsme® sign-in page, represented as a space-separated list of language tag values, ordered by preference.<br><br>Possible values : <code>fr</code> <code>nl</code> <code>de</code> <code>en</code></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="display" req="OPTIONAL" %}</td>
      <td>Specify how the itsme® sign-in page should be displayed to the user. If set to <code>touch</code>, it SHOULD displays the itsme® sign-in page with a device that leverages a touch interface. If set to <code>page</code>, the itsme® sign-in UI SHOULD be consistent with a full page view of the User-Agent. If the <code>display</code> parameter is not specified, this is the default display mode.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="acr_values" req="OPTIONAL" %}</td>
      <td>Indicates the authentication method required to process the request, represented as a space-separated list of tag values, ordered by preference.<br><br>Possible values : <code>http://itsme.services/v2/claim/acr_basic</code> <code>http://itsme.services/v2/claim/acr_advanced</code><br><br><b>Note</b> : if these two values are provided only the most constraining authentication method will be applied, e.g. <code>http://itsme.services/v2/claim/acr_advanced</code>.<br />
        <table>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/acr_basic" req="" %}</td><td>It lets the user to choose either fingerprint usage (if device is compatible) or itsme® code. If the <code>acr_values</code> parameter is not specified, this is the default authentication method.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/acr_advanced" req="" %}</td><td>It forces the user to use his itsme® code.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="claims" req="OPTIONAL" %}</td>
      <td>Allows to request specific user's details ("claims"). You can choose to receive those claims either in the ID Token (from /token endpoint) or in the UserInfo object (from /userinfo endpoint).<br />It MUST be a JSON object containing an <code>{"id_token":{...}</code> member or a <code>{"userinfo":{...}</code> member respectively. This member will then contain all the desired claims - see example below.<br><b>Note</b>: to avoid the need of a /userinfo request, itsme® recommends to retrieve the claims directly from the ID Token.<br><br>Supported claims are listed below.<br />
        <table>
          <tr>
            <td>{% include parameter.html name="name" req="OPTIONAL" %}</td><td>Returns user's full name in displayable form including all name parts, possibly including titles and suffixes.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="given_name" req="OPTIONAL" %}</td><td>Returns user's given name(s) or first name(s). Note that in some cultures, people can have multiple given names; all can be present, with the names being separated by space characters.<br><br>If requested, a value MAY NOT be returned if the user doesn't have any first name(s).</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="family_name" req="OPTIONAL" %}</td><td>Returns user's surname(s) or last name(s). Note that in some cultures, people can have multiple family names or no family name; all can be present, with the names being separated by space characters.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="birthdate" req="OPTIONAL" %}</td><td>Return user's birthday, represented as a string in YYYY-MM-DD date format.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID documents. Users with a BE document will always be 16 years old or more, users with a NL document will always be 18 or more.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/birthdate_as_string" req="OPTIONAL" %}</td><td>Returns user's birthday. It is considered as official or at least coming unprocessed from the ID document.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents. Users with a BE document will always be 16 years old or more, users with a NL document will always be 18 or more.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="gender" req="OPTIONAL" %}</td><td>Returns user's gender. Possible values are : <code>female</code> <code>male</code> <code>unknown</code> <code>n/a</code> (note: Belgian accounts can only be <code>female</code> or <code>male</code>)<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="locale" req="OPTIONAL" %}</td><td>Returns user's mobile phone language, represented as a string format. Possible values are : <code>NL</code> <code>FR</code> <code>DE</code> <code>EN</code><br><br>If requested, a value MAY NOT be returned for this claim.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="picture" req="OPTIONAL" %}</td><td>Returns user's ID picture, represented as a URL string. This URL refers to an image file (for example, a JPEG, JPEG2000, or PNG image file).<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID documents.<br /><br />
            Accessing this URL has to be done with your bearer token. Example:<br />
            <code>
              GET /v2/picture HTTP/1.1<br />
              Host: idp.prd.itsme.services<br />
              Authorization: Bearer SlAV32hkKG
            </code></td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="email" req="OPTIONAL" %}</td><td>Returns user's email address.<br><br>If requested, a value MAY NOT be returned if the user doesn't gave us an email address.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="email_verified" req="OPTIONAL" %}</td><td>Returns <code>true</code> if the user's e-mail address is verified; otherwise <code>false</code>.<br><br><b>Note</b> : currently, itsme® always returns <code>false</code> for this claim because the email verification feature is not yet implemented in our systems.<br><br>If requested, a value SHALL NOT be returned if the <code>email</code> claim is not filled with a value.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="phone_number" req="OPTIONAL" %}</td><td>Returns user's phone number, represented as a string format. For example : <code>[+][country code] [subscriber number including area code]</code>.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="phone_number_verified" req="OPTIONAL" %}</td><td>Returns <code>true</code> if the user's phone number is verified; otherwise <code>false</code>.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="address" req="OPTIONAL" %}</td><td>Returns user's postal address, represented as JSON Object containing some or all of these members <code>formatted</code> <code>street_address</code> <code>postal_code</code> <code>locality</code>.<br><br>If requested, a value SHALL always be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/claim_citizenship" req="OPTIONAL" %}</td><td>Returns user's nationality. The format is directly depending on the underlying ID document: for Belgian ID documents this is represented as a string, and for Dutch ID documents this is represented in the <a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a> format.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/claim_citizenship_as_iso" req="OPTIONAL" %}</td><td>Returns user's nationality. The format is always the <a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a> format. Please be aware that this claim is computed by itsme® for users with a Belgian ID document on a best effort basis. For the original value as stored on the ID document, see http://itsme.services/v2/claim/claim_citizenship above.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID documents.</td>
          </tr>
           <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/place_of_birth" req="OPTIONAL" %}</td><td>Returns user's place of birth, represented as a JSON Object containing some or all of these members <code>formatted</code> <code>city</code> <code>country</code>.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/physical_person_photo" req="OPTIONAL" %}</td><td>Returns user's ID picture, represented as a JSON Object containing some or all of these members <code>format</code> <code>value</code>.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/BEeidSn" req="OPTIONAL" %}</td><td>Returns user's Belgian ID document number, represented as a string with 12 digits in the form xxx-xxxxxxx-yy. (the check-number yy is the remainder of the division of xxxxxxxxxx by 97) for Belgian citizens, or starting with a letter and nine digits in the form B xxxxxxx xx for EU/EEA/Swiss citizens.<br><br>If requested, a value SHALL always be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/claim_device" req="OPTIONAL" %}</td><td>Returns user's phone information, represented as a JSON Object containing some or all of these members <code>os</code> <code>appName</code> <code>appRelease</code> <code>deviceLabel</code> <code>debugEnabled</code> <code>deviceID</code>	<code>osRelease</code> <code>manufacturer</code> <code>deviceLockLevel</code> <code>smsEnabled</code> <code>rooted</code> <code>msisdn</code> <code>deviceModel</code>	<code>sdkRelease</code>.<br><br>If requested, a value MAY NOT be returned for this claim.</td>       
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/transaction_info" req="OPTIONAL" %}</td><td>Returns information about the itsme® transaction, represented as a JSON Object containing some or all of these members <code>securityLevel</code> <code>bindLevel</code> <code>appRelease</code>.<br><br>If requested, a value MAY NOT be returned for this claim.</td>
           </tr> 
           <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/BENationalNumber" req="OPTIONAL" %}</td><td>Returns user's Belgian unique identification number, represented as a string with 11 digits in the form YY.MM.DD-xxx.cd where YY.MM.DD is the birthdate of the person, xxx a sequential number (odd for males and even for females) and cd a check-digit. Some exceptions could apply.<br><br>If requested, a value SHALL always be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID documents.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/validityFrom" req="OPTIONAL" %}</td><td>Returns user's Belgian ID document issuance date, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. Can only be returned in combination with claim http://itsme.services/v2/claim/BEeidSn.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL NOT be returned for users with a Dutch ID document.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/validityTo" req="OPTIONAL" %}</td><td>Returns user's Belgian ID card expiry date, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. Can only be returned in combination with claim http://itsme.services/v2/claim/BEeidSn.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and MAY NOT be returned for users with a Dutch ID document.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/verificationDate" req="OPTIONAL" %}</td><td>Returns the date when the user's document was read for the last time, represented as a string in YYYY-MM-DDThh:mm:ss date format specified by ISO 8601.<br><br>If requested, a value MAY NOT be returned for users with a Belgian ID document, and SHALL always be returned for users with a Dutch ID document.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/IDDocumentSN" req="OPTIONAL" %}</td><td>Returns the Dutch ID card/passport number, represented as a string composed of letters at positions 1 and 2 ; letters or digits from positions 3-8: ; and a digit at position 9. The letter ‘O’ is not used in the document numbers. The digit ‘0’ (zero) MAY be used.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/IDDocumentType" req="OPTIONAL" %}</td><td>Returns the Dutch ID card/passport document type.<br><br>If requested, a value SHALL always be returned for this claim.</td>
          </tr> 
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="request_uri" req="OPTIONAL" %}</td>
      <td>A URL using the https scheme referencing a resource containing a JWT whose claims are the request parameters. The <code>request_uri</code> parameter is used to secure parameters in the Authorization Request from tainting or inspection when sending the request to the itsme® Authorization Endpoint.<br><br>If the <code>request_uri</code> parameter is used, the JWT MUST be signed and MUST contain the claims <code>iss</code> (issuer) and <code>aud</code> (audience) as members. The <code>iss</code> value SHOULD be your <code>client_id</code>. The <code>aud</code> value SHOULD be set to <code>https://idp.[e2e/prd].itsme.services/v2/authorization</code>. The JWT MAY also be encrypted. If both signing and encryption are performed, it MUST be signed then encrypted, with the result being a Nested JWT (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).<br><br>The following restrictions apply to request URIs:
        <tabul>
          <tabli>The request URI MUST be preregistered during the registration.</tabli>
          <tabli>The request URI MAY contain any TCP port number. Example : https://test.istme.be:443/p/test</tabli>
          <tabli>The request URI MUST begin with the scheme <code>https</code> (refer to <a href="https://belgianmobileid.github.io/doc/authentication/#certificates-and-website-security" target="blank">this section</a> for more information). The usage of localhost request URIs that are not permitted.</tabli>
          <tabli>The request URI JWT MUST be publicly accessible.</tabli>
        </tabul>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="request" req="OPTIONAL" %}</td>
      <td>It represents the request as a JWT whose Claims are the request parameters. The <code>request</code> parameter is used to secure parameters in the Authorization Request from tainting or inspection when sending the request to the itsme® Authorization Endpoint.<br><br>If the <code>request</code> parameter is used, the JWT MUST be signed and MUST contain the claims <code>iss</code> (issuer) and <code>aud</code> (audience) as members. The <code>iss</code> value SHOULD be your <code>client_id</code>. The <code>aud</code> value SHOULD be set to <code>https://idp.[e2e/prd].itsme.services/v2/authorization</code>. The JWT MAY also be encrypted. If both signing and encryption are performed, it MUST be signed then encrypted, with the result being a Nested JWT (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code_challenge" req="OPTIONAL" %}</td>
       <td>A challenge derived from the code verifier by applying a S256 hash. This parameter is REQUIRED if you requested PKCE to be enforced.
       </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code_challenge_method" req="OPTIONAL" %}</td>
       <td>Code verifier transformation method.<br><br>It MUST be set to <code>S256</code>.
       </td>
    </tr>
  </tbody>
</table>


<a id="AuthNResp"></a>
### Response

<code>302</code> <code>application/x-www-form-urlencoded</code>

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="code" req="" %}</td>
      <td>An intermediate opaque credential of 36 characters used to retrieve the ID Token and Access Token.<br><br><b>Note</b> : the code has a lifetime of 3 minutes.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="state" req="" %}</td>
      <td>The string value provided in the Authorization Request. You SHOULD validate that the value returned matches the one supplied.</td>
    </tr>
  </tbody>
</table>

{% endtab %}

{% endtabs %}


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
  &state=anystate
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

{% tabs UserInfoExample %}

{% tab UserInfoExample Public- and private-key %}

***Request***

```http
GET /userinfo HTTP/1.1
Host: server.example.com
Authorization: Bearer SlAV32hkKG
```

***Response***

```http
HTTP/1.1 200 OK
Content-Type: application/json

  {
   "sub": "248289761001",
   "name": "Jane Doe",
   "given_name": "Jane",
   "family_name": "Doe",
   "preferred_username": "j.doe",
   "email": "janedoe@example.com",
   "picture": "http://example.com/janedoe/me.jpg"
  }
```

{% endtab %}

{% tab UserInfoExample Secret key %}

***Request***

```http
GET /userinfo HTTP/1.1
Host: server.example.com
Authorization: Bearer SlAV32hkKG
```

***Response***

```http
HTTP/1.1 200 OK
Content-Type: application/json

  {
   "sub": "248289761001",
   "name": "Jane Doe",
   "given_name": "Jane",
   "family_name": "Doe",
   "preferred_username": "j.doe",
   "email": "janedoe@example.com",
   "picture": "http://example.com/janedoe/me.jpg"
  }
```

{% endtab %}

{% endtabs %}



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

