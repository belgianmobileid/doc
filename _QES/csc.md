---
layout: QES
title: CSC Qualified Signature
permalink: QES-CSC/
nav_order: 5
toc_list: true
---

# Introduction

itsme® is a trusted identity provider allowing partners to use verified identities for authentication, authorization and signature on web desktop, mobile web and mobile applications. 

The CSC API is an API built based on the CSC specification version 1.0.4.0. See <a href="https://cloudsignatureconsortium.org">https://cloudsignatureconsortium.org</a> and <a href="https://cloudsignatureconsortium.org/resources/download-api-specifications/">https://cloudsignatureconsortium.org/resources/download-api-specifications</a> to get the specification. The spec is implemented based on the OAuth2 specification.

The objective of this document is to provide all the information needed to integrate the AUTH service using the OAuth specifications.

At this moment only the Hash Signing variant is available and documented. In this variant, a remote Signature Creation Application (SCA) will provide the What You See Is What You Sign (WYSIWYS) experience to the User, provide the hash of the data to be signed to the itsme® service and use the returned digital signature value to format the signature in one of the AdES formats.

# Particularities compared to the CSC Specification

<ul>
  <li>No implementation of / no support for:
    <ul>
      <li>Auth/Login method</li>
      <li>Credentials/Authorize</li>
      <li>Credentials/ExtendTransaction</li>
      <li>Credentials/sendOTP</li>
      <li>Signatures/Timestamp</li>
    </ul>
  </li>
  <li>OAuth2/Token request
    <ul>
      <li>This operation supports both <code>application/json</code> and <code>application/x-www-form-urlencoded</code></li>
    </ul>
  </li>
</ul>


# Audience

This document is intended to be read by developers of any Signature Creation Application party. Partners who wish to use the itsme sign service through an existing SCA should refer to this SCA instead.

# Prerequisites

Before you can integrate your application with itsme® Sign service, you MUST set up a project in the <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7" target="blank">itsme® B2B portal</a> to obtain all the needed information.

Please be aware that we support performing multiple signatures with 1 itsme® action, but this is an extra option. If you want to make use of it, be sure to mention it to the Onboarding team while setting up your project.

# Integrating Sign services

The itsme® Sign flow goes through the steps shown in the sequence diagram below.

![Sequence diagram describing the CSC Hash Signing flow](/doc/public/images/csc-sequence.svg)

<aside class="notice">The <b>BASE_URL</b> to be used in this flow will be communicated during your onboarding process</aside>

## 1. Getting endpoint info

To simplify implementations and increase flexibility, a JSON document is available containing key-value pairs which provide details about CSC configuration, such as the different endpoints, the base URI, region and so on.

The method requires a post with a JSON body where you can provide the language of the document you want to retrieve. Supported languages are; EN, FR, NL, DE and their respective ISO language codes. If the language is not supported, English will be used.

Example:

```
POST /info
{
  "lang": "{{EN | FR | NL | DE}}"
}
```
response:
```
{
  "specs": "1.0.3.0",
  "name": "itsme®",
  "logo": "https://itsmeprdweucscgeneral.blob.core.windows.net/public/logo.jpg",
  "region": "BE",
  "lang": "EN-US",
  "description": "itsme®, your digital ID and a smarter way to sign with your smartphone.",
  "authType": [ "oauth2code" ],
  "oauth2": "https://sign.prd.itsme.services/csc/v0/oauth2/authorize",
  "methods": [ "info", "auth/revoke", "oauth2/authorize", "oauth2/token", "credentials/list", "credentials/info", "signatures/signHash" ]
}
```
<aside class="notice">Although the version of the spec mentioned 1.0.3.0, the CSC Sign implementation is fully compliant with version 1.0.4.0. In fact, the specification of 1.0.4.0 explicitly (and confusingly) mentions that specific value.</aside>


## 2. Authorization request

Starts the OAuth 2.0 authorization server using an Authorization Code flow to request authorization for the user to access the remote service resources. The authorization is returned in the form of an authorization code, which the signature application SHALL then use to obtain an access token with the `oauth2/token` method. After a successful authorization, the server shall send a redirect to the given redirect URI.

Below you will find the mandatory and optional query parameters to integrate in the HTTPS GET request:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>The ClientId you received during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirect_uri" req="REQUIRED" %}</td>
      <td>The URI to which the authentication response should be sent. This must exactly match the redirect URI or regex redirect URI (including query string) configured during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="scope" req="REQUIRED" %}</td>
      <td>The value has to be <code>service</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="response_type" req="REQUIRED" %}</td>
      <td>The value has to be <code>code</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="lang" req="optional" %}</td>
      <td>The language in which the authorization request is displayed. Supported values are NL, DE, EN FR and their respective ISO language codes. If no value is specified or the language isn't supported, defaults to EN.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="state" req="optional" %}</td>
      <td>The state property is an optional value and is returned in the response of the authorize request. This allows you to maintain a session between your request and our response.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="account_token" req="REQUIRED" %}</td>
      <td>
        This is the JWT token as defined in RFC 7519 and the CSC documentation.<br />
        <code>account_token = base64UrlEncode(&lt;JWT_Header&gt;) + "." + base64UrlEncode(&lt;JWT_Payload&gt;) + "." + base64UrlEncode(&lt;JWT_Signature&gt;)</code><br />
        whereby
        <div class="highlight language-plaintext highlighter-rouge"><pre class="highlight"><code>&lt;JWT_Header&gt; = {
          "typ": "JWT",
          "alg": "HS256"
        }</code></pre></div>
        <div class="highlight language-plaintext highlighter-rouge"><pre class="highlight"><code>&lt;JWT_Payload&gt; = {
          "sub": "&lt;Account_ID&gt;", ‘Account ID
          "iat": &lt;Unix_Epoch_Time&gt;, ‘Issued At Time
          "jti": "&lt;Token_Unique_Identifier&gt;", ‘JWT ID
          "iss": "&lt;Signature_Application_Name&gt;", ‘Issuer
          "azp": "&lt;client_id&gt;" ‘Authorized presenter
        }</code></pre></div>
        <div class="highlight language-plaintext highlighter-rouge"><pre class="highlight"><code>&lt;JWT_Signature&gt; = HMACSHA256(
          base64UrlEncode(&lt;JWT_Header&gt;) + "." +
          base64UrlEncode(&lt;JWT_Payload&gt;),
          SHA256(&lt;client_secret&gt;)
        )</code></pre></div>
        Parameters:
        <table>
          <tbody>
            <tr>
              <td>{% include parameter.html name="typ" req="REQUIRED" %}</td>
              <td>MUST be the value <code>JWT</code>.</td>
            </tr>
            <tr>
              <td>{% include parameter.html name="alg" req="REQUIRED" %}</td>
              <td>MUST be the value <code>HS256</code>.</td>
            </tr>
            <tr>
              <td>{% include parameter.html name="sub" req="REQUIRED" %}</td>
              <td>The client-defined account_id that allows the RSSP to identify the account or user initiating the authorization transaction.</td>
            </tr>
            <tr>
              <td>{% include parameter.html name="iat" req="REQUIRED" %}</td>
              <td>The Unix Epoch time when the account_token was issued. The value is used to determine the age of the JWT. The RSSP SHOULD define the lifetime of the JWT and SHALL accept or reject an account_token based on its own expiration policy.</td>
            </tr>
            <tr>
              <td>{% include parameter.html name="jti" req="REQUIRED" %}</td>
              <td>A unique identifier for the JWT. This protects from replay attacks performed by reusing the same account_token.</td>
            </tr>
            <tr>
              <td>{% include parameter.html name="iss" req="OPTIONAL" %}</td>
              <td>The name of the issuer of the token (e.g. the commercial name of the signature application).</td>
            </tr>
            <tr>
              <td>{% include parameter.html name="azp" req="REQUIRED" %}</td>
              <td>The unique client_id previously assigned to the signature application by the remote service.</td>
            </tr>
          </tbody>
        </table>
        Implementation notes
        <ul>
          <li>itsme SHALL securely share the OAuth 2.0 client_id and client_secret with the SCA as part of the <a href="#prerequisites">onboarding process</a>.</li>
          <li>The JWT_signature required to generate the account_token SHALL be calculated with the HMAC function, using as shared secret the SHA256 hash of the OAuth 2.0 client_secret.</li>
          <li>The SCA MUST register in advance with itsme the list of Account_ID parameters associated with those users that are authorized to access a restricted authorization server.</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="clientData" req="not supported" %}</td>
      <td>As clientData can expose confidential data, we do not support it.</td>
    </tr>
  </tbody>
</table>

Example:

```
GET /oauth/authorize?
response_type=code
&client_id={ClientId}}
&redirect_uri={RedirectUrl}
&scope=service
&lang={EN | FR | NL | DE}
&state=example
&account_token={AccountToken}
```

## 3. Capturing the authorization code

If the user is successfully authenticated and authorizes access to the Identification Request, the authorization server will return an authorization code and the provided state.

Example:

 ```
{
  302  Found
  Location: {RedirectUrl}?
  code=66353038303864632D306665392D346563352D393633352D3565616431383639376261357C426561726572
  &state=example
}
```

## 4. Requesting a token

Obtain an access token from the authorization server by passing the clientId and clientSecret in the body. After a successful request, the authorization server will return a bearer or SAD token, depending on the scope in the <code>oauth2/authorize</code> method.

Below you will find the mandatory and optional parameters to integrate in the HTTPS POST request body formatted as application/json:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="grant_type" req="REQUIRED" %}</td>
      <td>For the moment <code>authorization_code</code> is the only supported value.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>The ClientId you received during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_secret" req="REQUIRED" %}</td>
      <td>The Client Secret you received during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code" req="REQUIRED" %}</td>
      <td>The code returned by the authorize request.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirect_url" req="REQUIRED" %}</td>
      <td>Should be equal to the redirect URI provided in the authorize request.</td>
    </tr>
  </tbody>
</table>

Example:
```
POST /oauth2/token
{
  "grant_type": "authorization_code",
  "client_id": "{ClientId}",
  "client_secret": "{ClientSecret}",
  "code": "66353038303864632D306665392D346563352D393633352D3565616431383639376261357C426561726572",
  "redirect_uri": "{RedirectUrl}"
}
```
response:
```
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmN2VlM2ZiNS0yOWRhLTQ5OTktYTZmMy01NTE1YTYwN2RlYTYiLCJuYW1lIjoiOXdxOWlpOG5kaWxmMzZrM3VvemVoOGdua2pzODRzY210aTc3IiwiQXNwTmV0LklkZW50aXR5LlNlY3VyaXR5U3RhbXAiOiJZSU02T0lVM0RNNUhUSEhGUEpUU09FSUM3Rk9ORzVXNiIsImV4cCI6MTU4MDM5ODYyOCwiaXNzIjoiY3NjX2FwaSIsImF1ZCI6ImNzY19hcGkifQ.kJERr_vNQaRabwSulL0Xbi2RBmrpXypvrxcGDC58nUQ",
  "refresh_token": null,
  "token_type": "Bearer",
  "expires_in": 3600
}
```

## 5. Getting credential id('s)  

Returns the list of credentials associated with a user identifier, an itsme® user will always have exactly 1 credential.

This POST request contains only 1 parameter:
<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="maxResults" req="REQUIRED" %}</td>
      <td>The maximum number of items to return from this call. The value MUST be between 1 and 300.</td>
    </tr>
  </tbody>
</table>
Example:
```
POST /credentials/list
Content-Type: application/json
Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmN2VlM2ZiNS0yOWRhLTQ5OTktYTZmMy01NTE1YTYwN2RlYTYiLCJuYW1lIjoiOXdxOWlpOG5kaWxmMzZrM3VvemVoOGdua2pzODRzY210aTc3IiwiQXNwTmV0LklkZW50aXR5LlNlY3VyaXR5U3RhbXAiOiJZSU02T0lVM0RNNUhUSEhGUEpUU09FSUM3Rk9ORzVXNiIsImV4cCI6MTU4MDM5ODYyOCwiaXNzIjoiY3NjX2FwaSIsImF1ZCI6ImNzY19hcGkifQ.kJERr_vNQaRabwSulL0Xbi2RBmrpXypvrxcGDC58nUQ
{
  "maxResults": 10
}
```
response:
```
{
  "credentialIDs": [
      "f7642e62-72eb-4e83-8825-80c67d402c03"
  ]
}
```

## 6. Obtaining credential info

Retrieve the credential and return the certificate chain associated with it. Using the Certificate Info, the SCA can calculate the hash of the document to be signed.

Below you will find the mandatory and optional parameters to integrate in the HTTPS POST request body formatted as application/json:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="credentialID" req="REQUIRED" %}</td>
      <td>The credentialId obtained in the <code>credentials/list</code> method.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="certificates" req="REQUIRED" %}</td>
      <td>The only value supported right now is <code>chain</code>. This means that the full certificate chain will be returned.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="certInfo" req="Optional" %}</td>
      <td>Supported values are <code>true</code> or <code>false</code>. If set to <code>true</code> various parameters will contain information from the end entity certificate. The default value is is <code>false</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="authInfo" req="Optional" %}</td>
      <td>We do not support this setting.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="lang" req="Optional" %}</td>
      <td>The same value as provided in the authorize request.</td>
    </tr>
  </tbody>
</table>

Example:

```
{
  POST /credentials/info
  Content-Type: application/json
  Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmN2VlM2ZiNS0yOWRhLTQ5OTktYTZmMy01NTE1YTYwN2RlYTYiLCJuYW1lIjoiOXdxOWlpOG5kaWxmMzZrM3VvemVoOGdua2pzODRzY210aTc3IiwiQXNwTmV0LklkZW50aXR5LlNlY3VyaXR5U3RhbXAiOiJZSU02T0lVM0RNNUhUSEhGUEpUU09FSUM3Rk9ORzVXNiIsImV4cCI6MTU4MDM5ODYyOCwiaXNzIjoiY3NjX2FwaSIsImF1ZCI6ImNzY19hcGkifQ.kJERr_vNQaRabwSulL0Xbi2RBmrpXypvrxcGDC58nUQ
  {
    "credentialID": "f7642e62-72eb-4e83-8825-80c67d402c03",
    "certificates": "chain",
    "certInfo": true,
    "lang": "{EN | FR | NL | DE}"
  }
}
```
response:
```
{
  "description": null,
  "key": {
      "status": "enabled",
      "algo": [
          "1.2.840.113549.1.1.11"
      ],
      "len": 2048
  },
  "cert": {
      "status": "valid",
      "certificates": [
          ...
      ],
      "issuerDN": "Provided if certInfo is true",
      "serialNumber": "Provided if certInfo is true",
      "subjectDN": "Provided if certInfo is true",
      "validFrom": "Provided if certInfo is true",
      "validTo": "Provided if certInfo is true"
  },
  "authMode": "oauth2code",
  "SCAL": "2",
  "PIN": {
      "presence": "false",
      "label": null,
      "description": null
  },
  "OTP": {
      "presence": "false",
      "type": null,
      "ID": null,
      "provider": null,
      "format": null,
      "label": null,
      "description": null
  },
  "multiSign": true
}
```

## 7. Authorization request (Dance 2)

This GET request should include the following query parameters:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>The ClientId you received during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirect_uri" req="REQUIRED" %}</td>
      <td>The URI to which the authentication response should be sent. This must exactly match the redirect URI or regex redirect URI (including query string) configured during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="scope" req="REQUIRED" %}</td>
      <td>The value has to be <code>credential</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="response_type" req="REQUIRED" %}</td>
      <td>The value has to be <code>code</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="lang" req="optional" %}</td>
      <td>The language in which the authorization request is displayed. Supported values are NL, DE, EN FR and their respective ISO language codes. If no value is specified or the language isn't supported, defaults to EN.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="state" req="optional" %}</td>
      <td>The state property is an optional value and is returned in the response of the authorize request. This allows you to maintain a session between your request and our response.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="account_token" req="REQUIRED" %}</td>
      <td>This is the JWT token as defined in RFC 7519 and the CSC documentation. See description <a href="#2-authorization-request">above</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="credentialID" req="REQUIRED" %}</td>
      <td>The credentialId obtained in the <code>credentials/list</code> method.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="numSignatures" req="REQUIRED" %}</td>
      <td>This value must be set to 1.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="hash" req="REQUIRED" %}</td>
      <td>A base64url-encoded hash value to be signed. It allows the server to bind the SAD to the hash, thus preventing an authorization to be used to sign a different content. Multiple hashes are supported with a comma-seperated list.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="description" req="Optional" %}</td>
      <td>An optional description about the document being signed. This value will be visible in the itsme application.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="clientData" req="not supported" %}</td>
      <td>As clientData can expose confidential data, we do not support it.</td>
    </tr>
  </tbody>
</table>

Example:

```
GET /oauth/authorize?
response_type=code
&client_id={{ClientId}}
&redirect_uri={{RedirectUrl}}
&scope=credential
&lang={{EN | FR | NL | DE}}
&state=test
&credentialID=f7642e62-72eb-4e83-8825-80c67d402c03
&numSignatures=1
&hash=w6uP8Tcg6K2QR905Rms8iXTlksL6OD1KOWBxTK7wxPI%3d
&description=exampleDescription
```

## 8. Capturing the authorization code

If the user is successfully authenticated and authorizes access to the Identification Request, the authorization server will return an authorization code and the provided state.

Example:

 ```
{
  302  Found
  Location: {RedirectUrl}?
  code=66353038303864632D306665392D346563352D393633352D3565616431383639376261357C426561726572
  &state=example
}
```

## 9. Requesting a token

Obtain an access token from the authorization server by passing the clientId and clientSecret in the body. After a successful request, the authorization server will return a bearer or SAD token, depending on the scope in the <code>oauth2/authorize</code> method.

Below you will find the mandatory and optional parameters to integrate in the HTTPS POST request body formatted as application/json:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="grant_type" req="REQUIRED" %}</td>
      <td>For the moment <code>authorization_code</code> is the only supported value.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>The ClientId you received during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="client_secret" req="REQUIRED" %}</td>
      <td>The Client Secret you received during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="code" req="REQUIRED" %}</td>
      <td>The code returned by the authorize request.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirect_url" req="REQUIRED" %}</td>
      <td>Should be equal to the redirect URI provided in the authorize request.</td>
    </tr>
  </tbody>
</table>

Example:
```
POST /oauth2/token
{
  "grant_type": "authorization_code",
  "client_id": "{ClientId}",
  "client_secret": "{ClientSecret}",
  "code": "61316261316233612D383732392D346239312D613534322D3037643635393933623134617C534144",
  "redirect_uri": "{RedirectUrl}"
}
```
response:
```
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmN2VlM2ZiNS0yOWRhLTQ5OTktYTZmMy01NTE1YTYwN2RlYTYiLCJuYW1lIjoiOXdxOWlpOG5kaWxmMzZrM3VvemVoOGdua2pzODRzY210aTc3IiwiQXNwTmV0LklkZW50aXR5LlNlY3VyaXR5U3RhbXAiOiJZSU02T0lVM0RNNUhUSEhGUEpUU09FSUM3Rk9ORzVXNiIsImV4cCI6MTU4MDM5ODYyOCwiaXNzIjoiY3NjX2FwaSIsImF1ZCI6ImNzY19hcGkifQ.kJERr_vNQaRabwSulL0Xbi2RBmrpXypvrxcGDC58nUQ",
  "refresh_token": null,
  "token_type": "Bearer",
  "expires_in": 3600
}
```

## 10. Sign hash

Calculate the remote digital signature of the hash value provided in the request. This method requires credential authorization in the form of Signature ctivation Data (SAD) in the request body and the bearer token in the headers.

Below you will find the mandatory and optional parameters to integrate in the HTTPS POST request body formatted as application/json:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="credentialID" req="Required" %}</td>
      <td>The credentialId retrieved from the <code>credentials/list</code> method.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="SAD" req="Required" %}</td>
      <td>The SAD token retrieved from the <code>oauth2/token</code> method.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="hash" req="Required" %}</td>
      <td>Array containing the base64 value(s) of the hash(es) provided in the <code>oauth2/authorize</code> method.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="signAlgo" req="Required" %}</td>
      <td>The OID of the algorithm to use for signing as provided in the <code>credentials/info</code> response.</td>
    </tr>
  </tbody>
</table>

Example:

```
POST /signatures/signhash
Content-Type: application/json
Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmN2VlM2ZiNS0yOWRhLTQ5OTktYTZmMy01NTE1YTYwN2RlYTYiLCJuYW1lIjoiOXdxOWlpOG5kaWxmMzZrM3VvemVoOGdua2pzODRzY210aTc3IiwiQXNwTmV0LklkZW50aXR5LlNlY3VyaXR5U3RhbXAiOiJZSU02T0lVM0RNNUhUSEhGUEpUU09FSUM3Rk9ORzVXNiIsImV4cCI6MTU4MDM5ODYyOCwiaXNzIjoiY3NjX2FwaSIsImF1ZCI6ImNzY19hcGkifQ.kJERr_vNQaRabwSulL0Xbi2RBmrpXypvrxcGDC58nUQ
{
  "credentialID": "f7642e62-72eb-4e83-8825-80c67d402c03",
  "SAD": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwZmZhMDZlNy1lNmUyLTQ2NTgtYmE4OC1hODFiMzMwN2JkZGUiLCJuYW1lIjoiaGN3OWpoYzFuNmdqODN3OGlwYWx3endmeG16a2Vmc2x4MGl0IiwiQXNwTmV0LklkZW50aXR5LlNlY3VyaXR5U3RhbXAiOiJaUjdRUFNIVjNJWFJSS0k3WlZSQVlPR0hQNlRJR0ZWUyIsIkNyZWRlbnRpYWwiOiJ0cnVlIiwiZXhwIjoxNTYyMTQyNDE4LCJpc3MiOiJjc2NfYXBpIiwiYXVkIjoiY3NjX2FwaSJ9.KJvjsN6Ao3ZqJBaifoku2MlUNdwdhJX8RZ_IO68Z5hg",
  "hash": [
    "w6uP8Tcg6K2QR905Rms8iXTlksL6OD1KOWBxTK7wxPI="
  ],
  "signAlgo": "1.2.840.113549.1.1.11"
}
```
response:
```
{
  "signatures": [
    "i0H6bbiwVcxGDjGeNn2qhY...gbWbs6/pp9lWe4w6o5UG3BZhiZUfQ=="
  ]
}
```

## 11. Revoke session

Revoke an active active token with this request. When the signature application needs to terminate a session, it is RECOMMENDED to invoke this method to prevent further access by reusing the token. Otherwise the session will be deleted after one hour.

Below you will find the mandatory and optional parameters to integrate in the HTTPS POST request body formatted as application/json:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="token" req="Required" %}</td>
      <td>The access token retrieved in the first <code>oauth2/token</code> method.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="token_type_hint" req="Required" %}</td>
      <td>This value MUST be <code>access_token</code></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="clientData" req="Not supported" %}</td>
      <td>As clientData can expose confidential data, we do not support it.</td>
    </tr>
  </tbody>
</table>

Example:

```
POST /auth/revoke
Content-Type: application/json
Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmN2VlM2ZiNS0yOWRhLTQ5OTktYTZmMy01NTE1YTYwN2RlYTYiLCJuYW1lIjoiOXdxOWlpOG5kaWxmMzZrM3VvemVoOGdua2pzODRzY210aTc3IiwiQXNwTmV0LklkZW50aXR5LlNlY3VyaXR5U3RhbXAiOiJZSU02T0lVM0RNNUhUSEhGUEpUU09FSUM3Rk9ORzVXNiIsImV4cCI6MTU4MDM5ODYyOCwiaXNzIjoiY3NjX2FwaSIsImF1ZCI6ImNzY19hcGkifQ.kJERr_vNQaRabwSulL0Xbi2RBmrpXypvrxcGDC58nUQ
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmN2VlM2ZiNS0yOWRhLTQ5OTktYTZmMy01NTE1YTYwN2RlYTYiLCJuYW1lIjoiOXdxOWlpOG5kaWxmMzZrM3VvemVoOGdua2pzODRzY210aTc3IiwiQXNwTmV0LklkZW50aXR5LlNlY3VyaXR5U3RhbXAiOiJZSU02T0lVM0RNNUhUSEhGUEpUU09FSUM3Rk9ORzVXNiIsImV4cCI6MTU4MDM5ODYyOCwiaXNzIjoiY3NjX2FwaSIsImF1ZCI6ImNzY19hcGkifQ.kJERr_vNQaRabwSulL0Xbi2RBmrpXypvrxcGDC58nUQ",
  "token_type_hint": "access_token"
}
```
response:
```
204 NOCONTENT
```

# Appendixes

## Supported character set

The character set we support for free text fields is ISO 8859-15. You can buy the specification [on ISO website](https://www.iso.org/standard/29505.html) or find a free version [on Wikipedia](https://en.wikipedia.org/wiki/ISO/IEC_8859-15#Codepage_layout). You might be interested in knowing that, although most usual characters are supported, some softwares-generated characters like curly apostrophes and long dashes are not part of ISO 8859-15. If you provide a non-supported character in a free text field the signing flow will be stopped and you will receive an error message back.