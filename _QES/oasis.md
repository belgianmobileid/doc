---
layout: QES
title: OASIS Qualified Signature
permalink: QES-OASIS/
nav_order: 4
toc_list: true
---

# Introduction

itsme® is a trusted identity provider allowing partners to use verified identities for authentication and authorization on web desktop, mobile web and mobile applications. 

The objective of this document is to provide all the information needed to integrate the **Sign** service. This implementation of the **Sign** service is based on Oasis Digital Signature Services (DSS) protocol, using an asynchronous pattern in a pre-2.0 fashion.

At this moment only the Hash(es) Signing variant is available and documented. In this variant, an external Signature Creation Application (SCA) will provide the What You See Is What You Sign (WYSIWYS) experience to the User, provide the hash of the data to be signed to the itsme® service and use the returned digital signature value to format the signature in one of the AdES formats.

# Audience

This document is intended to be read by developers of any Signature Creation Application party. Partners who wish to use the itsme sign service through an existing SCA should refer to this SCA instead.

# Prerequisites

Before you can integrate your application with itsme® Sign service, you MUST set up a project in the <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7" target="blank">itsme® B2B portal</a> to obtain all the needed information.

Please be aware that we support performing up to 70 signatures within 1 itsme® action, but this is an extra option. If you want to make use of it, be sure to mention it to the Onboarding team while setting up your project.

# Integrating Sign services

The itsme® Sign flow goes through the steps shown in the sequence diagram below.

![Sequence diagram describing the Oasis Hash Signing flow](/doc/public/images/Oasis_Hash_Signing_SeqDiag.png)

<ol>
  <li>The User indicates on your end he wishes to sign a document with itsme®</li>
  <li>Your web desktop, mobile web or mobile SCA application sends a request to itsme® Integration Layer Back-End in order to create the User’s Identification session and obtain the User’s signing certificate to be include in the data to be signed.</li>
  <li>itsme® returns the session id and the redirect URL specific to the User to your SCA Back-End.</li>
  <li>Your SCA Front-End redirects the User to the Integration Layer Front-End of itsme®, meaning that the User will be identified in the meanwhile (in case the <i>"userCode"</i> is transmitted by the SCA, this step will be skipped as the user will already be identified). If the User has no signature certificate yet, the certificate creation process will be initiated automatically.</li>
  <li>Finally, when the User is authenticated and has a signature certificate, he is redirected to the your SCA Front-End. The redirection to your SCA Front-End SHOULD be (almost) transparent to the User (with a possible displaying of a spinner) as the laps of time between step 5 and step 11 of this diagram SHOULD be extremely short.</li>
  <li>Your SCA Back-End contacts the itsme® Integration Layer Back-End to get the signature certificate of the User.</li>
  <li>The itsme® Integration Layer Back-End returns your SCA Back-End the signer information as well as the signature certificate of the User.</li>
  <li>Your SCA Back-End constructs the data to be signed and the hash(es) of the signature(s) will be computed by yourself. We support up to 70 hashes in 1 flow. The value of a hash MUST be base64url encoded.</li> 
  <li>Your SCA Back-End will provide the hash(es) to the itsme® Integration Layer Back-End to request the digital signature value.</li>
  <li>A session id and redirect URL are returned by itsme® to your SCA Back-End.</li>
  <li>Your SCA frontend will then redirect the User to the signature webpage of itsme®, where he is guided through the itsme part of the signing flow.</li>    
  <li>The session of the User at itsme® side ends as the process is finished and the User is redirected to your SCA Front-End.</li>
  <li>Your SCA Back-End will contact the itsme® Integration Layer Back-End to check the signature status (same endpoint as for creating the signature session).</li>
  <li>itsme® then returns the signature completion status and the digital signature value(s).</li>
  <li>At this stage, your SCA is able to confirm the success of the operation and display a success message.</li>
</ol>

<aside class="notice">The <b>BASE_URL</b> to be used in this flow will be communicated during your onboarding process</aside>

## 1. Checking itsme® Sign configuration

Two JSON documents are available to ease the integration of itsme sign service:
<ul>
  <li>The discovery document</li>
  <li>The swagger of the B2B interface</li>
</ul>

### Discovery document

To simplify implementations and increase flexibility, the following key-value pairs about itsme® configuration can be retrieved from a JSON document:

<ul>
  <li>the signature policies</li>
  <li>commitment types</li>
  <li>supported languages</li>
</ul>

The JSON document for itsme® Sign service may be retrieved from <a href="BASE_URL/qes-partners/1.0.0/.well-known/configuration" target="blank">BASE_URL/qes-partners/1.0.0/.well-known/configuration</a>.

Please note we are using SSLMA as authentication method, combined with IP filtering, as specified in [SSLMA Authentication](#sslma-authentication). If you need to access the discovery document before setting up the connectivity, you can use the public version here (this one is updated manually, while the previous one is automatically generated): <a href="/doc/public/resources/qesdiscovery.json" target="blank">https://belgianmobileid.github.io/doc/public/resources/qesdiscovery.json</a>

### B2B interface swagger

The swagger of the B2B interface (for the back-end to back-end calls) may be retrieved from <a href="/doc/public/resources/qesB2B.json" target="blank">https://belgianmobileid.github.io/doc/public/resources/qesB2B.json</a>

## 2. Starting a new User identification session

This section relates to the step 2 of the sequence diagram.

First, you will forge a HTTPS POST request that MUST be sent to the itsme® User Identification Endpoint, which is BASE_URL/qes-partners/1.0.0/user_identification. Please note we are using SSLMA as authentication method, combined with IP filtering, as specified in [SSLMA Authentication](#sslma-authentication).

Below you will find the mandatory and optional parameters to integrate in the HTTPS POST request body formatted as application/json:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="partnerCode" req="REQUIRED" %}</td>
      <td>This MUST be the client identifier you received when registering your application during the <a href="#prerequisites">onboarding process</a>. This parameter will be translated to a label describing the customer for which the User is signing the document.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="userCode" req="OPTIONAL" %}</td>
      <td>The userCode is the unique identifier created by itsme for a user connecting with a Service Provider. A user has a different user code at each Service Provider. You SHOULD provide a <i>"userCode"</i> known by itsme if you already have authenticated the User who needs to sign the document. Providing a userCode will bypass the identification screen (user won't have to enter his phone number).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="serviceCode" req="REQUIRED" %}</td>
      <td>It MUST contain the value of the serviceCode defined for your application during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="lang" req="REQUIRED" %}</td>
      <td>This parameters defines the recommended language to be used for GUI interaction.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirectUrl" req="REQUIRED" %}</td>
      <td>This is the URL to which the User will be redirected to your remote SCA. This MUST exactly match the redirect URL of the specified service defined when registering your application during the [onboarding process](#prerequisites).</td>
    </tr>
  </tbody>
</table>

Example:

```
POST /BASE_URL/qes-partners/1.0.0/user_identification HTTP/1.1
{
  "partnerCode":"myClientID",
  "serviceCode":"myServiceCode",
  "redirectUrl":"https://myServiceRedirectUrl.partner.be?sessionID=myCustomSessionID",
  "userCode":"endUserUserCode",
  "lang":"FR"
}
```

## 3. Capturing the Identification Response

This section relates to the step 3 of the sequence diagram.

### Capturing a successful Identification Code

If the User is successfully authenticated and authorizes access to the Identification Request, itsme® will return a response to your server component. This is achieved by returning an Identification Response to the <i>"redirectUrl"</i> specified previously in the Identification Request (preserving the URL parameters).

You MAY receive a set-cookie header back from this call, but you SHOULD ignore it, it is never used in this context.

The response will contain:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="status" req="ALWAYS" %}</td>
      <td>It is the status of User Identification Request.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="statusReason" req="OPTIONAL" %}</td>
      <td>It explains the reason of a failure. No reason is given in case the request status is pending or success.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="asyncRespID" req="ALWAYS" %}</td>
      <td>This parameter is the identifier of a User identification session.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="identificationUrl" req="ALWAYS" %}</td>
      <td>This is the itsme® URL of the signature welcome page. On this webpage the User will identify himself by entering his mobile phone number.</td>
    </tr>
  </tbody>
</table>

 <aside class="notice">Although the swagger specifies asyncRespId in the request, you must ask asyncRespID instead (with a capital D).</aside>

Example:

 ```
{
  "status": "OK",
  "asyncRespID": "4kpr55zdi2mk9ns27awgngkltoenfy04gi9b",
  "identificationUrl": "https://uatmerchant.itsme.be/qes/identify_yourself?language=FR&q=ss4liz8kjk1xxz8taj3nbxae7zqty6eq"
}
```

### Handling Error Response

See [Appendixes](#appendixes) to get more information on the error codes.

## 4. Redirecting the end user

This section relates to the step 4 of the sequence diagram.

The next step is to redirect the end user to our Front-End, so that we can process the identification session. You must do that by forging a GET request towards the url specified at previous step, in the parameter `identificationUrl`. Please note there is no built-in parameter designed to let you getting your session context back after the redirection to your FE (a parameter similar to the 'state' parameter in OpenID). However, you MAY add any query parameter to the URL specified in `identificationUrl` and it will be preserved during the redirection, effectively allowing you to craft a custom parameter for finding back your session context. Also, please note that the duration of the identification process may strongly vary from a few seconds to a few minutes, depending on whether or not we need to create a certificate for this end user.

## 5. Requesting the User identification session status  

This section relates to the step 6 of the sequence diagram.

By calling the Identification Session Status Endpoint, you are checking the status of the User identification session. This endpoint is BASE_URL/qes-partners/1.0.0/user_identification/status. Please note we are using SSLMA as authentication method, combined with IP filtering, as specified in [SSLMA Authentication](#SSLMA).

Below you will find the mandatory and optional parameters to integrate in the HTTPS POST request body formatted as application/json:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="partnerCode" req="REQUIRED" %}</td>
      <td>This MUST be the client identifier you received when registering your application during the <a href="#prerequisites">onboarding process</a>. This parameter will be translated to a label describing the customer for which the User is signing the document.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="serviceCode" req="REQUIRED" %}</td>
      <td>It MUST contain the value It MUST contain the value of the serviceCode defined for your application during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="asyncRespID" req="REQUIRED" %}</td>
      <td>This parameter is the identifier of a User identification session. This value MUST be retrieved from the Identification Response.</td>
    </tr>
  </tbody>
</table>

Example:

```
POST /BASE_URL/qes-partners/1.0.0/user_identification/status HTTP/1.1
{
  "partnerCode":"myPartnerCode",
  "serviceCode":"myServiceCode",
  "asyncRespID":"4kpr55zdi2mk9ns27awgngkltoenfy04gi9b"
}
```

## 6. Capturing the User identification status info

This section relates to the step 7 of the sequence diagram.

If the Identification Session Status Request has been sucessfully validated we will return an HTTP 200 OK response as in the example aside. In other words, you will get the confirmation that the User can perform a Sign transaction with itsme® and retrieve the User certificate reference value.

The response body will include the following values:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="status" req="ALWAYS" %}</td>
      <td>It is the status of User Identification Request.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="userCode" req="OPTIONAL" %}</td>
      <td>The userCode is the unique identifier created by itsme for a user connecting with a Service Provider. A user has a different user code at each Service Provider. Is always returned if the status indicates a successful identification.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="certificate" req="ALWAYS" %}</td>
      <td>The certificate created for the User, under PEM format. Only the final certificate is returned here (not the full chain). Is always returned if the status indicates a successful identification.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="fullCertificateChain" req="ALWAYS" %}</td>
      <td>The certificate created for the User, under PEM format. The full chain is returned here. Is always returned if the status indicates a successful identification.</td>
    </tr>
  </tbody>
</table>

Example:

```
{
  "status": "OK",
  "userCode": "9o8f04wm1g0bdc8gmgcuxp2ehgn7txh0x2kq",
  "certificate": "-----BEGIN CERTIFICATE-----\nMIIGojCCBIqgAwIBAgIUPekSHohW1BwH+TyPTsGVIA3LinEwDQYJKoZIhvcNAQEL\nBQAwTjELMAkGA1UEBhMCQk0xGTAXBgNVBAoMEFF1b1ZhZGlzIExpbWl0ZWQxJDAi\nBgNVBAMMG1F1b1ZhZGlzIE5vIFJlbGlhbmNlIElDQSBHMzAeFw0yMTAxMTExNDQ5\nMjVaFw0yMTA4MDUxODA5MjhaMG8xCzAJBgNVBAYTAkJFMRAwDgYDVQQHDAdCcnVz\nc2VsMRQwEgYDVQQFEws4OTExMjQzMzUxODENMAsGA1UEBAwEVGVzdDERMA8GA1UE\nKgwIU3RlcGhhbmUxFjAUBgNVBAMMDVRlc3QgU3RlcGhhbmUwggEiMA0GCSqGSIb3\nDQEBAQUAA4IBDwAwggEKAoIBAQC6by7/bmX8EB7h1B4hFwBVbQjDWwrV8U9uiZVq\nQRlPPfjGaWI19q5KzuUD1OfntsQn2gUW8xfrNi07jm0PbJ/IMlVQt/awKU7uYcwF\nx0NyyUTDPzf6L+mj9WF+NQjD4S5aWMBK9eB9tg+PxK+AC3Al2TI20VQTzYuzutCF\ndFBMgIOo7XktRl3zy2IKz8BBXEIFhfuhZTpyEqrLWw5nI0SZ5Cdicxx/baIUylVi\nw93lD2YZ1gmwqRXgbtGFVhRLWLUldq/SNXM8gdFeOyczLALz23pPE+UQS1YCOChs\nQzoOmivxKOxrTGEkuYhoRM7d64l0e26ncFP7IajU6TxJ6/wNAgMBAAGjggJVMIIC\nUTAfBgNVHSMEGDAWgBR8sacoMBd5cnponmoZD9ZuoTXIPjB3BggrBgEFBQcBAQRr\nMGkwOAYIKwYBBQUHMAKGLGh0dHA6Ly90cnVzdC5xdW92YWRpc2dsb2JhbC5jb20v\ncXZuaWNhZzMuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcGRldi5xdW92YWRp\nc2dsb2JhbC5jb20wWgYDVR0gBFMwUTBEBgorBgEEAb5YAYMQMDYwNAYIKwYBBQUH\nAgEWKGh0dHA6Ly93d3cucXVvdmFkaXNnbG9iYWwuY29tL3JlcG9zaXRvcnkwCQYH\nBACL7EABAjApBgNVHSUEIjAgBggrBgEFBQcDAgYIKwYBBQUHAwQGCisGAQQBgjcK\nAwwwOwYDVR0fBDQwMjAwoC6gLIYqaHR0cDovL2NybC5xdW92YWRpc2dsb2JhbC5j\nb20vcXZuaWNhZzMuY3JsMB0GA1UdDgQWBBSGZhmrmw5uOtQhC8rUItFME0QGwzAO\nBgNVHQ8BAf8EBAMCBsAwNAYKKoZIhvcvAQEJAQQmMCQCAQGGH2h0dHA6Ly90cy5x\ndW92YWRpc2dsb2JhbC5jb20vYmUwgYsGCCsGAQUFBwEDBH8wfTAVBggrBgEFBQcL\nAjAJBgcEAIvsSQEBMAgGBgQAjkYBATAIBgYEAI5GAQQwEwYGBACORgEGMAkGBwQA\njkYBBgEwOwYGBACORgEFMDEwLxYpaHR0cHM6Ly93d3cucXVvdmFkaXNnbG9iYWwu\nY29tL3JlcG9zaXRvcnkTAmVuMA0GCSqGSIb3DQEBCwUAA4ICAQBqzBPGLtFdBjLT\n2c9faYHPHFrH9BIA0NjXPAis61KwGtl00sJYunSVKC+3+Mmnq3p0P+ur/JvIPp58\nIjUzVs1Sa+SRRRjVxA+NzAo6ZhdUXzq/+8pW3PWqWmDdB08RI/QPkFDo9jQPtuv+\niTgPbOd79y1uR49bdfYrmrb66lNulUMmKI66QzlTUcGGVkyXsh0D7RgJjlWZAW3m\n+TmpDm62GbpNLuzBXeG9A5zMQvfRkBz4efEXKJS+c2YsR3h0sl5fy0ZFAaRjGnFM\nxh/GF0aW4KlvPCh9mzubkPwraDsMsCziihCARZsyDtLvYgeRUIzCqfKKPsPWPQs8\nTG0QCVVvJTglgFY1OYE7+9SO0BlM3GWe5utwpOtobKnnCxc6ZJn4x2LiTibEZTRR\nIohEIp8XCmgxw6nhkJrdvml3V9vFulMYB+YBOnTi93LR/yL/fQvprO1otFtk52pI\nttvWSaC31klAgn2x+0SDK+ZsF6hT1JhPjtSV7srQDbrtijVKp4Kik8GbqRkLyJmf\n1g7vdi/f8S6U142Ge7YJAL0Y+xb6Gl0GZs5QGhdRioHq1qOvFtdcitgK0JDz+ZlO\nipHe66JI84cGWAdB0TkzuwYKM7Bt1YluhnyRP3iVGj91An6eBK9uTE9BzlPXeD3s\nZ8MR3qInvxGZnJsnbUJIYh+sDse0bw==\n-----END CERTIFICATE-----\n",
  "fullCertificateChain": "-----BEGIN CERTIFICATE-----\nMIIGojCCBIqgAwIBAgIUPekSHohW1BwH+TyPTsGVIA3LinEwDQYJKoZIhvcNAQEL\nBQAwTjELMAkGA1UEBhMCQk0xGTAXBgNVBAoMEFF1b1ZhZGlzIExpbWl0ZWQxJDAi\nBgNVBAMMG1F1b1ZhZGlzIE5vIFJlbGlhbmNlIElDQSBHMzAeFw0yMTAxMTExNDQ5\nMjVaFw0yMTA4MDUxODA5MjhaMG8xCzAJBgNVBAYTAkJFMRAwDgYDVQQHDAdCcnVz\nc2VsMRQwEgYDVQQFEws4OTExMjQzMzUxODENMAsGA1UEBAwEVGVzdDERMA8GA1UE\nKgwIU3RlcGhhbmUxFjAUBgNVBAMMDVRlc3QgU3RlcGhhbmUwggEiMA0GCSqGSIb3\nDQEBAQUAA4IBDwAwggEKAoIBAQC6by7/bmX8EB7h1B4hFwBVbQjDWwrV8U9uiZVq\nQRlPPfjGaWI19q5KzuUD1OfntsQn2gUW8xfrNi07jm0PbJ/IMlVQt/awKU7uYcwF\nx0NyyUTDPzf6L+mj9WF+NQjD4S5aWMBK9eB9tg+PxK+AC3Al2TI20VQTzYuzutCF\ndFBMgIOo7XktRl3zy2IKz8BBXEIFhfuhZTpyEqrLWw5nI0SZ5Cdicxx/baIUylVi\nw93lD2YZ1gmwqRXgbtGFVhRLWLUldq/SNXM8gdFeOyczLALz23pPE+UQS1YCOChs\nQzoOmivxKOxrTGEkuYhoRM7d64l0e26ncFP7IajU6TxJ6/wNAgMBAAGjggJVMIIC\nUTAfBgNVHSMEGDAWgBR8sacoMBd5cnponmoZD9ZuoTXIPjB3BggrBgEFBQcBAQRr\nMGkwOAYIKwYBBQUHMAKGLGh0dHA6Ly90cnVzdC5xdW92YWRpc2dsb2JhbC5jb20v\ncXZuaWNhZzMuY3J0MC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcGRldi5xdW92YWRp\nc2dsb2JhbC5jb20wWgYDVR0gBFMwUTBEBgorBgEEAb5YAYMQMDYwNAYIKwYBBQUH\nAgEWKGh0dHA6Ly93d3cucXVvdmFkaXNnbG9iYWwuY29tL3JlcG9zaXRvcnkwCQYH\nBACL7EABAjApBgNVHSUEIjAgBggrBgEFBQcDAgYIKwYBBQUHAwQGCisGAQQBgjcK\nAwwwOwYDVR0fBDQwMjAwoC6gLIYqaHR0cDovL2NybC5xdW92YWRpc2dsb2JhbC5j\nb20vcXZuaWNhZzMuY3JsMB0GA1UdDgQWBBSGZhmrmw5uOtQhC8rUItFME0QGwzAO\nBgNVHQ8BAf8EBAMCBsAwNAYKKoZIhvcvAQEJAQQmMCQCAQGGH2h0dHA6Ly90cy5x\ndW92YWRpc2dsb2JhbC5jb20vYmUwgYsGCCsGAQUFBwEDBH8wfTAVBggrBgEFBQcL\nAjAJBgcEAIvsSQEBMAgGBgQAjkYBATAIBgYEAI5GAQQwEwYGBACORgEGMAkGBwQA\njkYBBgEwOwYGBACORgEFMDEwLxYpaHR0cHM6Ly93d3cucXVvdmFkaXNnbG9iYWwu\nY29tL3JlcG9zaXRvcnkTAmVuMA0GCSqGSIb3DQEBCwUAA4ICAQBqzBPGLtFdBjLT\n2c9faYHPHFrH9BIA0NjXPAis61KwGtl00sJYunSVKC+3+Mmnq3p0P+ur/JvIPp58\nIjUzVs1Sa+SRRRjVxA+NzAo6ZhdUXzq/+8pW3PWqWmDdB08RI/QPkFDo9jQPtuv+\niTgPbOd79y1uR49bdfYrmrb66lNulUMmKI66QzlTUcGGVkyXsh0D7RgJjlWZAW3m\n+TmpDm62GbpNLuzBXeG9A5zMQvfRkBz4efEXKJS+c2YsR3h0sl5fy0ZFAaRjGnFM\nxh/GF0aW4KlvPCh9mzubkPwraDsMsCziihCARZsyDtLvYgeRUIzCqfKKPsPWPQs8\nTG0QCVVvJTglgFY1OYE7+9SO0BlM3GWe5utwpOtobKnnCxc6ZJn4x2LiTibEZTRR\nIohEIp8XCmgxw6nhkJrdvml3V9vFulMYB+YBOnTi93LR/yL/fQvprO1otFtk52pI\nttvWSaC31klAgn2x+0SDK+ZsF6hT1JhPjtSV7srQDbrtijVKp4Kik8GbqRkLyJmf\n1g7vdi/f8S6U142Ge7YJAL0Y+xb6Gl0GZs5QGhdRioHq1qOvFtdcitgK0JDz+ZlO\nipHe66JI84cGWAdB0TkzuwYKM7Bt1YluhnyRP3iVGj91An6eBK9uTE9BzlPXeD3s\nZ8MR3qInvxGZnJsnbUJIYh+sDse0bw==\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\n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\nkkqOMnepX7XL8b93SQ==\n-----END CERTIFICATE-----\n-----BEGIN CERTIFICATE-----\nMIIF4zCCA8ugAwIBAgIUb+hkbaVtQEL4Cn75Hf92Ml0TY7EwDQYJKoZIhvcNAQEF\nBQAweTELMAkGA1UEBhMCQk0xGTAXBgNVBAoTEFF1b1ZhZGlzIExpbWl0ZWQxJTAj\nBgNVBAsTHFJvb3QgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxKDAmBgNVBAMTH1F1\nb1ZhZGlzIE5vIFJlbGlhbmNlIFJvb3QgQ0EgRzIwHhcNMTEwODA1MTgwOTI4WhcN\nMjEwODA1MTgwOTI4WjB5MQswCQYDVQQGEwJCTTEZMBcGA1UEChMQUXVvVmFkaXMg\nTGltaXRlZDElMCMGA1UECxMcUm9vdCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEo\nMCYGA1UEAxMfUXVvVmFkaXMgTm8gUmVsaWFuY2UgUm9vdCBDQSBHMjCCAiIwDQYJ\nKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJdyE2e1rsufqr2+llJFg0Oo9EnTvTw/\nScne0ZbBIOeBUIspNnGTQ/nTKL7/BaM52CM73bbiDoEOG2utz9pLfAJOSYYzXRQr\necWdUA7/0ru+FRfGzXIQj07G5m/FYRWQOs2NO0mm65iUpxedn3QuX7MqvaLnZemY\nSQXGiNjkqOqFCGFw2FtSFH9LV/B45MO2GW/MaydlUGqMFJzX97QqEFzqO80gwNBe\n/0p1O6U5OvqY6BSFTIAXApYJYSl4etLSzmbH0JQgA4DglWtV4KPYNhn40ouPNhQa\nsVGYPquwwqdiDFjE9fzKQQdo+aid6WBnsELiXSbHr1t4WcFgwOZN5CEs68j8L3e4\nOuDozrr4nmwLkuXuUkUbez0Z7w12ISPbnKd+GlXkVP9SCwqOtqF/lQTaEuk2NWuv\nvrb0AziFhopHXRlNnBARuhWREy3+kpRgp7uV5prUjHmvRijtJKwCthmg0slC7g+E\n3paqIcFApvkYEYzK0RD4pa/HdiOe+x8qQyWq8fI0+RUshsm9zYgsBQexVcQJ62NI\nztEFKhm0KxHTGph7Cy+pewfaNFsjRN1fudSwmPSNQbPfNsv3hVYl0mnDwYSfWJsd\nl90XBbTUDudi13m6OiOa3CyqEJSNYTswH1F2sTPQunMa1yojw2RcKgrN8zS9MDw4\n7y/OXbhQiHOTAgMBAAGjYzBhMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQD\nAgEGMB8GA1UdIwQYMBaAFK/Q7x34Cfk0ER/UV1b54DumYcQ3MB0GA1UdDgQWBBSv\n0O8d+An5NBEf1FdW+eA7pmHENzANBgkqhkiG9w0BAQUFAAOCAgEAXpTQpmOYqgWx\njbSnwOdTd3MMcfzvZBH4zmNRY9t4gORfy7Fz9EvIjqHRe+mLM4pmdG1mwcURkat/\nknpUp+ONt6u9iifGvQ8027MMCSQ0KHmS6PfFWAW8EDxZPInTxhWYCBnnJdIG7wdb\nX9AQpF7RRTy1vXTzMSXfo/+E+1zOLKcfUK1vMR5eB87rrkXe0bEJZQud36W379hy\n71j5TWlLgaSNootVsggapnj8M5WV5QW3iyF9V9/Qg2Fr0JZ1dUMJu8WDiOTKb3i5\nst5EcRLUmSVwcG9eHJhM69jTNxVgA1HtgMdYyGHPuaLwNBnBpJ1n1TXyzZ7lxavj\nOwjRrFKmiqs7tbw07nuVJRI/hioMI5Vsqca8NLu8SC6p2klvQEr8dn/gWvt7gTAo\n0E4I/El/F9SMKkWQlG6pjgDZPh63ZyHuQhGA1D2+tZYHtkFn+3CpQGoPCONZyf5J\nSsTEzANelS3kAS4oApRBU38YFj0xzjQdmzWuh0dIdZubRuC/0rHQDbHtsiuQRk8V\nHJICVj3EjWAbZkW3eMV8kDaLn3x8rPe92KgmI9XT9/C2ZZfnWX/fUah8nAwD5WdW\nbI9Lie7+KxsVovqg3Zpmiu16OVGJp6yWSX3vsuBO+06R+i73ZxFpooNSF9dkiJPn\n8GSeh2lu6LhTwLl5yHBJ7Vcxu9cALW8=\n-----END CERTIFICATE-----\n"
}
```

### Handling Error Response

See [Appendixes](#appendixes) to get more information on the error codes.

## 7. Requesting a new Sign session 

This section relates to the step 9 of the sequence diagram.

In order to intiate the Sign session, you will forge a POST request towards this endpoint: BASE_URL/qes-partners/1.0.0/sign_document. Please note we are using SSLMA as authentication method, combined with IP filtering, as specified in [SSLMA Authentication](#SSLMA). Please note the same endpoint is used for starting the sign session and for requesting the status of this session (also see 'requesting the session status').

Below you will find the mandatory and optional parameters to integrate in the HTTPS POST request body formatted as application/json:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="inDocs" type="object" req="REQUIRED" %}</td>
      <td>This contains the element(s) to be signed. 1 package can contain at most 70 hashes to sign.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="docHash" type="array" req="REQUIRED" level="1" %}</td>
      <td>This parameter MUST contain information related to the document(s) to be signed by itsme®, expressed as an array.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="id" type="string" req="REQUIRED" level="2" %}</td>
      <td>This is the ID of the hash(es) to be signed.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="di" type="array of objects" req="REQUIRED" level="2" %}</td>
      <td>This parameter MUST contain the hash(es) to be signed and their algorithm(s), expressed as an array.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="alg" type="string" req="REQUIRED" level="3" %}</td>
      <td>This MUST be "http://www.w3.org/2001/04/xmlenc#sha256", as only the SHA256 algorithm is supported. See <a href="http://www.w3.org/2001/04/xmlenc#sha256" target="blank">http://www.w3.org/2001/04/xmlenc#sha256</a> for more information.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="value" type="string" req="REQUIRED" level="3" %}</td>
      <td>This is the hash to be signed during the signature flow. The value of the computed hash must be Base64 encoded.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="reqID" type="string" req="REQUIRED" %}</td>
      <td>This is an ID you generate to identify the current request.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="asyncRespID" type="string" req="OPTIONAL" %}</td>
      <td>This parameter MUST be set to 'null' in order to initiate the sign session.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="optInp" type="object" req="REQUIRED" %}</td>
      <td>Those are additional information needed for the signature request.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="lang" type="string" req="OPTIONAL" level="1" %}</td>
      <td>This parameters defines the recommended language to be used for GUI interaction. If not defined, then the language comes from a dedicated cookie. If no cookie, defaults to the browser language.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="itsme" type="object" req="REQUIRED" level="1" %}</td>
      <td>This parameter contains all the information related to itsme® context.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="signer" type="object" req="REQUIRED" level="2" %}</td>
      <td>This is all the information that allows identification of the User in itsme®.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="userCode" type="string" req="REQUIRED" level="3" %}</td>
      <td>The identifier for the User as returned in <a href="#6-capturing-the-user-identification-status-info">step 6</a></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="partnerCode" type="string" req="REQUIRED" level="2" %}</td>
      <td>This MUST be the client identifier you received when registering your application during the <a href="#prerequisites">onboarding process</a>. This parameter will be translated to a label describing the 3rd party for which the User is signing the document.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="serviceCode" type="string" req="REQUIRED" level="2" %}</td>
      <td>It MUST contain the value of the serviceCode defined for your application during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="description" type="array of objects" req="OPTIONAL" level="2" %}</td>
      <td>Is a text you provide as the description of the (package of) document(s). The maximum length is 50 characters. It will be displayed in the itsme App. If providing a description, you MUST provide a value for each language supported by itsme ('en', 'fr', 'nl' and 'de'). Please see <a href="#supported-character-set">Supported character set</a> for encoding concerns.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="lang" type="string" req="REQUIRED" level="3" %}</td>
      <td>The language of this description. MUST be one of 'en', 'fr', 'nl' or 'de'.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="value" type="string" req="REQUIRED" level="3" %}</td>
      <td>The description of the document in the above defined language.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirectUrl" type="string" req="REQUIRED" level="2" %}</td>
      <td>This is the URL to which the User will be redirected (your remote SCA). This MUST exactly match the redirect URL of the specified service defined when registering your application during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="signPolicy" type="object" req="OPTIONAL" level="2" %}</td>
      <td>This is the object of the Signature policy to be used during the Signature. This parameter contains all the information related to the signature policy.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="signPolicyRef" type="string" req="REQUIRED" level="3" %}</td>
      <td>Defines the reference of the signature policy to be used during itsme® Signing flow. In case no specific signature policy is applicable for that specific use case, the itsme® generic qualified signature policy SHOULD be used. The signature policy has to be indicated in the SCA Front-End to the User. The list of available codes can be retrieved from the <a href="#1-checking-itsme-sign-configuration">JSON document</a>.<br>The signature policies used SHOULD be defined during the <a href="#prerequisites">onboarding process</a>. It is up to you to choose your signature policies within the list given by itsme®. If you want to add new signature policies to your list, please ask the itsme® Onboarding team.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="commitmentTypeRef" type="string" req="OPTIONAL" level="3" %}</td>
      <td>Defines the reference of the commitment type to be used during itsme® Signing flow. This parameter is used to display (in the itsme® App) the commitment type of the signature to the User. There is no commitment type by default. If the parameter is not given by the SCA, then nothing is displayed in the itsme® App. You SHOULD use a code that corresponds to a specific commitment type. The list of available codes can be retrieved from the <a href="#1-checking-itsme-sign-configuration">JSON document</a>.<br>The commitment types used SHOULD be defined during the <a href="#prerequisites">onboarding process</a>. It is up to you to choose your commitment types within the list given by itsme®. If you want to add new commitment types to your list, please ask the itsme® Onboarding team.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="signerRole" type="array of objects" req="OPTIONAL" level="3" %}</td>
      <td>Defines the role of the signer. This information is displayed in the itsme® App to show to the signer under which role he will sign the document. If no signer role is provided nothing will be displayed in the itsme® App. This parameter is optional and freely defined in a free text of maximum 50 characters by yourself. You SHOULD provide this free text in all supported languages ('en', 'fr', 'nl' and 'de'). The characters used to define the Signer Role MUST be ISO-8859-1 compatible.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="lang" type="string" req="REQUIRED" level="4" %}</td>
      <td>The language of this role description. MUST be one of 'en', 'fr', 'nl' or 'de'.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="value" type="string" req="REQUIRED" level="4" %}</td>
      <td>The role description of the signer in the above defined language.</td>
    </tr>
  </tbody>
</table>

Example:

```
POST /BASE_URL/qes-partners/1.0.0/sign_document HTTP/1.1
{
  "inDocs": {
    "docHash":[
      {
        "di":[
          {
            "alg":"http://www.w3.org/2001/04/xmlenc#sha256",
            "value":"f4OxZX/x/FO5LcGBSKHWXfwtSx+j1ncoSt3SABJtkGk="
          }
        ],
        "id":"ContractCar20180914u89236456.pdf"
      },
      {
        "di":[
          {
            "alg":"http://www.w3.org/2001/04/xmlenc#sha256",
            "value":"t9I89IEOCiue980A23A+ep/iAJM50+87BxgG65gVwtF="
          }
        ],
        "id":"ContractHome20180915G74.pdf"
      }
    ]
  },
  "reqID": "ReqID4va0acsef3mv5ft1dp71",
  "asyncRespID": null,
  "optInp": {
    "lang": "FR",
    "itsme": {
      "signer": {
        "userCode": "9o8f04wm1g0bdc8gmgcuxp2ehgn7txh0x2kq"
      },
      "partnerCode": "myPartnerCode",
      "serviceCode": "myServiceCode",
      "description": [
        {
          "lang": "EN",
          "value": "Car insurance contract"
        },
        {
          "lang": "FR",
          "value": "Contrat d'assurance voiture"
        },
        {
          "lang": "NL",
          "value": "Contract verzekering auto"
        },
        {
          "lang": "DE",
          "value": "Kfz-Versicherungsvertrag"
        }
      ],
      "redirectUrl": "myServiceRedirectUrl",
      "signPolicy": {
        "signPolicyRef": "ITSME_DEFAULT",
        "commitmentTypeRef":"1.2.840.113549.1.9.16.6.5",
        "signerRole": [
          {
            "lang": "EN",
            "value": "General Manager"
          },
          {
            "lang": "FR",
            "value": "Gestionnaire"
          },
          {
            "lang": "NL",
            "value": "Zaakvoerder"
          },
          {
            "lang": "DE",
            "value": "Manager"
          }
        ]
      }
    }
  }
}
```

## 8. Capturing the Sign Response 

### Getting a successful Sign Response

This section relates to the step 10 of the sequence diagram.

If the Sign Request has been sucessfully validated we will return an HTTP 200 response.

The response body will include the following values:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="result" type="object" req="ALWAYS" %}</td>
      <td>This is the status of the request (pending, success or error).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="maj" type="string" req="ALWAYS" level="1" %}</td>
      <td>This is a general message that will give the status of the request, pending, success or error. In case of failure, the root cause is given. This parameter can take one of the 4 values below:
      <code>"urn:oasis:names:tc:dss:1.0:profiles:asynchronousprocessing:resultmajor:Pending"
      "urn:oasis:names:tc:dss:1.0:resultmajor:Success"
      "urn:oasis:names:tc:dss:1.0:resultmajor:RequesterError"
      "urn:oasis:names:tc:dss:1.0:resultmajor:ResponderError"</code></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="msg" type="string" req="Optional" level="1" %}</td>
      <td>This indicates the origin of the error.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="reqID" type="string" req="ALWAYS" %}</td>
      <td>This is the ID of the request that you transfer.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="respID" type="string" req="ALWAYS" %}</td>
      <td>This parameter is the identifier of a User identification session. This parameter is needed for you to get the status of the signature.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="optOutp" type="object" req="ALWAYS" %}</td>
      <td>Contains additional information needed for the signature request. Please note this parameter is not returned in the other use of this call (see section <a href="#10-requesting-the-sign-session-status">Requesting the Sign session status</a>).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="itsme" type="object" req="ALWAYS" level="1" %}</td>
      <td>Contains all the information related to itsme® context. Please note this parameter is not returned in the other use of this call (see section <a href="#10-requesting-the-sign-session-status">Requesting the Sign session status</a>).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="signingUrl" type="string" req="ALWAYS" level="2" %}</td>
      <td>This signing URL is the link to redirect the User from the SCA frontend  to the itsme® Signing Page. Please note this parameter is not returned in the other use of this call (see section <a href="#10-requesting-the-sign-session-status">Requesting the Sign session status</a>).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="userCode" type="string" req="ALWAYS" level="2" %}</td>
      <td>An identifier for the User, unique among all itsme® accounts and never reused. Use <i>"userCode"</i> in the application as the unique-identifier key for the User. Please note this parameter is not returned in the other use of this call (see section <a href="#10-requesting-the-sign-session-status">Requesting the Sign session status</a>).</td>
    </tr>
  </tbody>
</table>

Example:

```
{
  "result": {
      "maj": "urn:oasis:names:tc:dss:1.0:profiles:asynchronousprocessing:resultmajor:Pending"
  },
  "reqID": "ReqID4va0acsef3mv5ft1dp71",
  "respID": "hjg3ngu3tvvv71k9qg1vyokc2mwmqgqk43iv",
  "optOutp": {
      "itsme": {
          "signingUrl": "https://uatmerchant.itsme.be/qes/prove_its_you_poka?q=34u5jh2dltb1xhsu0g4bshnlziycdhow&language=FR",
          "userCode" : endUserUserCode
      }
  }
}
```

### Handling Error Response

See [Appendixes](#appendixes) to get more information on the error codes.

## 9. Redirecting the end user

This section relates to the steps 11 and 12 of the sequence diagram.

The next step is to redirect the end user to our Front-End, so that we can process the identification session. You must do that by forging a GET request towards the url specified at previous step, in the parameter `signingUrl`. Please note we can only whitelist one URL per serviceCode. As a result, the `signingUrl` will in practice be the same as the `identificationUrl`.

Please note there is no built-in parameter designed to let you getting your session context back after the redirection to your FE (a parameter similar to the 'state' parameter in OpenID). However, you MAY add any query parameter to the URL specified in `signingUrl` and it will be preserved during the redirection, effectively allowing you to craft a custom parameter for finding back your session context. Also, please note that the duration of the identification process may strongly vary from a few seconds to a few minutes, depending on whether or not we need to create a certificate for this end user.

## 10. Requesting the Sign session status

This section relates to the step 13 of the sequence diagram.

This request has to be sent in order to get the information about the Sign session (which you can do as many times as desired for the same signing session, as long as this session is still pending). In order to do so, you will forge a POST request towards BASE_URL/qes-partners/1.0.0/sign_document. Please note we are using SSLMA as authentication method, combined with IP filtering, as specified in [SSLMA Authentication](#SSLMA). Please note the same endpoint is used for starting the sign session and for requesting the status of this session (also see 'Starting sign session').

Below you will find the mandatory and optional parameters to integrate in the HTTPS POST request body formatted as application/json:

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="inDocs" type="string" req="Required" %}</td>
      <td>MUST be 'null'.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="reqID" type="string" req="Required" %}</td>
      <td>This is the ID of the request that you are sending to us.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="asyncRespID" type="string" req="Required" %}</td>
      <td>This parameter is the identifier of a User identification session. You MUST provide here the value of the parameter <i>respId</i> returned in <a href="#8-capturing-the-sign-response">step 8</a>. In case no <i>"asyncRespID"</i> is given in the request, a new session is created (corresponding to <a href="#7-requesting-a-new-sign-session">step 7</a>). <i>Please note you will receive a 409 error if you fill in this parameter with the asyncRespID returned at <a href="#5-requesting-the-user-identification-session-status">step 5</a> instead</i></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="optInp" type="object" req="Required" %}</td>
      <td>Contains additional information needed for the signature request.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="itsme" type="object" req="Required" level="1" %}</td>
      <td>Contains all the information related to itsme® context.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="partnerCode" type="string" req="Required" level="2" %}</td>
      <td>MUST be the client identifier you received when registering your application during the <a href="#prerequisites">onboarding process</a>. Will be translated to a label describing the partner for which the User is signing the document.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="serviceCode" type="string" req="Required" level="2" %}</td>
      <td>MUST contain the value of the serviceCode defined for your application during the <a href="#prerequisites">onboarding process</a>.</td>
    </tr>
  </tbody>
</table>

Example:

```
POST /BASE_URL/qes-partners/1.0.0/sign_document HTTP/1.1
{
  "inDocs": null,
  "reqID": "ReqIDv1prg8pmn9mtive3otsc",
  "asyncRespID": "b99a7d03acb94ea5a4d972aa31bb1c36",
  "optInp": {
    "itsme": {
      "partnerCode":"myPartnerCode",
      "serviceCode":"myServiceCode"
    }
  }
}
```

## 11. Capturing the Sign Status Response

This section relates to the step 14 of the sequence diagram.

### Getting a successful Sign Status Response

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="result" type="object" req="ALWAYS" %}</td>
      <td>Status of the request (pending, success or error).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="maj" type="string" req="ALWAYS" level="1" %}</td>
      <td>General message giving the status of the request, pending, success or error. In case of failure, the root cause is given.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="min" type="string" req="Optional" level="1" %}</td>
      <td>Specific message that, in case of failure, identifies the root cause of the failure.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="msg" type="string" req="Optional" level="1" %}</td>
      <td>Indicates the origin of the error.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="reqID" type="string" req="ALWAYS" %}</td>
      <td>This is the ID of the request that you are sending to us.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="respID" type="string" req="ALWAYS" %}</td>
      <td>Same value as returned in <a href="#8-capturing-the-sign-response">step 8</a> in the parameter respID.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="sigObj" type="array of objects" req="ALWAYS" %}</td>
      <td>Contains the signed hashes within a JSON array. Please note this parameter is not returned in the other use of this call (see section <a href="#7-requesting-a-new-sign-session">Requesting a new Sign session</a>).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="b64Sig" type="object" req="ALWAYS" level="1" %}</td>
      <td>Contains the signed hash within a JSON object. Please note this parameter is not returned in the other use of this call (see section <a href="#7-requesting-a-new-sign-session">Requesting a new Sign session</a>).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="value" type="string" req="ALWAYS" level="2" %}</td>
      <td>This is the base64 encoded hash. The Sign algorithm is SHA256, the Public Key Cryptographic Standard is PKCS1 and the Signature format is « raw ». Please note this parameter is not returned in the other use of this call (see section <a href="#7-requesting-a-new-sign-session">Requesting a new Sign session</a>).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="whichdoc" type="string" req="ALWAYS" level="1" %}</td>
      <td>This is the ID of the hash(es) to be signed, as provided in the first use of this call: <a href="#startSignSession">Requesting a new Sign session</a>. Please note this parameter is not returned in the response to the first use of this call (see section <a href="#8-capturing-the-sign-response">Capturing the sign response</a>).</td>
    </tr>
  </tbody>
</table>

Example:

```
HTTP200 
{
  "result": {
    "maj": "urn:oasis:names:tc:dss:1.0:resultmajor:Success"
  },
  "reqID": "ReqID4va0acsef3mv5ft1dp71",
  "respID": "gl1bb6g0bykali5yl46civwh615qtn5ek28m",
  "sigObj": [
    {
      "b64Sig": {
        "value": "pekb3BX5tyWPn07qq/DIZI3W3qjyXrq2sZcIKpMAV0lGhcP0AzSXVkadlPwcmkOHJBFuCm0C1U6Bc8VrNCZnP6E260DShiasEAoV7ZmFhB4k7om/nXEsBTLPUJTWV9FUk1XyfuAnnbNvvmX7lAvmDyVPELO840ODUX7q8a43NES0ZFpPzbNd7HhqCRHf8UKKLFop7FwTPngc7LarTP6j0iX8PSNaoc/F2pi0Z62qN67UPy/zHmc1/5w718qygy6BSPLXS2csm+OcscN8Bg1JnJOgRLpxFelPpGxYSj/uOojfSXkF/0Kj9n2xlNLZnM+EPIwZCoTjA/4dBPvw5vdD0g=="
      },
      "whichDoc": "myDoc"
    }
  ]
}
```

### Handling Error Response

See [Appendixes](#appendixes) to get more information on the error codes.

# Appendixes

## Handling Error Response

If one of the above request is invalid or unauthorized an error code will be returned to the User using the appropriate HTTPS status code, as listed in the table below:

<table>
  <tbody>
    <tr>
      <th>HTTP status code</th>
      <th>Description</th>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>Returned in case of invalid Request Object.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="409" %}</td>
      <td>Returned in case the User identification flow has been interrupted.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="500" %}</td>
      <td>Internal Server Error.</td>
    </tr>
  </tbody>
</table>

The Error Response will contain the <i>"status"</i> and the `statusReason` value. The following table describes the various error types that can be returned in the `statusReason` value of the error response:

<table>
  <tbody>
    <tr>
      <th>HTTP code</th>
      <th>statusReason</th>
      <th>Description</th>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>NOT_ALLOWED_TO_SIGN</td>
      <td>The user account is not eligible for itsme hash signing. There are a few reasons to this, the most frequent one is that the user account is blocked. In any case, the user has to take action that cannot be initiated at your side and might need to contact the support.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>NO_REQUEST</td>
      <td>user_identification is a POST service. A body SHOULD be inserted into the request. For more information on the structure of this request, you can go to the section related to /user_identification.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>MISSING_PARTNER_CODE</td>
      <td>The request body does not contain the field "partnerCode". This field corresponds to the "Partner Code/Client ID" referenced in your onboarding file.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>MISSING_SERVICE_CODE</td>
      <td>The request body does not contain the field "serviceCode". This field corresponds to the "Service Code" referenced in your onboarding file.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>INVALID_URL</td>
      <td>The field "redirectUrl" is null or its syntax is not correct, URL is invalid. This field corresponds to the "Redirect URL" referenced in your onboarding file.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>INVALID_REQUESTOR</td>
      <td>The "partnerCode" and/or "serviceCode" referenced into the body do not reference an existing partner and/or service. The "partnerCode" corresponds to the "Partner Code/Client ID" referenced in your onboarding file. The "serviceCode" corresponds to the "Service Code" referenced in your onboarding file for a SIGN service.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>UNAUTHORIZED_URL</td>
      <td>The partner and its service have been correctly found by itsme® following referenced "partnerCode" and "serviceCode", but the given "redirectUrl" is not authorized for the partner and/or service mentioned. You did not provide a valid redirectUrl. The "redirectUrl" used here must correspond to the "Redirect URL" referenced in your onboarding file.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>INVALID_LANG</td>
      <td>The "lang" field does not reference a language supported by itsme®. You can consult "BMID Well-Known Configuration" to check which are the languages supported by  itsme®, /well-known/configuration.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>UNEXPECTED_ERROR</td>
      <td>An error occurred during the validation of partner information. You SHOULD try again later. If the error persists, then you SHOULD contact itsme® support team for investigation.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="400" %}</td>
      <td>UNKNOWN</td>
      <td>An unknown error occurred during the request. You SHOULD contact itsme® support team for investigation.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="409" %}</td>
      <td>PENDING</td>
      <td>The User Identification Session you created is  pending. The User is currently following the User Identification flow at itsme® side (web and mobile).</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="409" %}</td>
      <td>REJECTED</td>
      <td>The User had to create a certificate in order to make a signature. However, he rejected his CREATE_CERT action in the itsme® App. A new User Identification session must be initialized. During that session, User has to confirm the CREATE_CERT action.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="409" %}</td>
      <td>EXPIRED</td>
      <td>The User had to create a certificate in order to make a signature. However, he waited too long (more than 3 minutes) before confirming his CREATE_CERT action in the itsme® App and his action expired. A new User Identification Session must be initialized. During that session, User has to confirm the CREATE_CERT action in time.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="409" %}</td>
      <td>UNEXPECTED_ERROR</td>
      <td>An unexpected error occurred during User’s Identification flow. You SHOULD try again later. If the error persists, then you SHOULD contact itsme® support team for investigation.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="409" %}</td>
      <td>No payload</td>
      <td>This error can be thrown in different cases. One frequent case is when the sign_document request is called with an asyncRespID that is not found. Please consult <a href="#10-requesting-the-sign-session-status">section 10</a> for this specific case.</td>
    </tr>
  </tbody>
</table>

## SSLMA Authentication

We make use of SSLMA Authentication with our b2b interface (BASE_URL/qes-partners/1.0.0). This means that the SSL certificate you present upon each call towards this interface must be the one whitelisted in our systems as part of the onboarding process.
We combine this authentication with IP filtering, meaning that we need to whitelist the IP address of your server. This is also part of the onboarding process.

When renewing your certificate (at expiration or for any other reason), please give us some advance notice to make sure the transition happens smoothly. If possible, the new certificate should:
<ul>
  <li>Be issued by the same CA as the previous certificate</li>
  <li>Contain the same Common Name as the previous certificate</li>
</ul>

Those 2 conditions will allow for a streamlined process where you can replace your certificate in a transparent way from the itsme&#174; point of view.

## Supported character set

The character set we support for free text fields is ISO 8859-15. You can buy the specification [on ISO website](https://www.iso.org/standard/29505.html) or find a free version [on Wikipedia](https://en.wikipedia.org/wiki/ISO/IEC_8859-15#Codepage_layout). You might be interested in knowing that, although most usual characters are supported, some softwares-generated characters like curly apostrophes and long dashes are not part of ISO 8859-15. If you provide a non-supported character in a free text field the signing flow will be stopped and you will receive an error message back.