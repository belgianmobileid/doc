---
layout: page
title: Authentication API
permalink: /authentication/
nav_order: 4
---

# Overview

Our itsme® app can be seamlessly be integrated with your web desktop, mobile web or mobile application so you can perform secure identity checks.

The diagram below describes the **Authentication** process and how your backend is integrated within the itsme® architecture :
  
 ![Sequence diagram describing the OpenID flow](OpenID_SeqDiag.png)

<ol>
  <li>The User indicates on your end he wishes to authenticate with itsme®</li>
  <li>Your web desktop, mobile web or mobile application (aka 'Relying Party' in the OpenID Connect specification) sends a request to itsme® (aka 'OpenID Provider' in the OpenID Connect specification) to authenticate the User. This request will redirect the User to the itsme® Front-End. itsme® then authenticates the User by asking him
    <ul type>
      <li>to enter his phone number on the itsme® OpenID web page</li>
      <li>authorize the release of some information’s to your application</li>
      <li>to provide his credentials (itsme® code or fingerprint or FaceID)</li>
    </ul>
  
  If you are building a mobile web or mobile application, the User don’t need to enter his mobile phone number on the itsme® OpenID web page, he will be automatically redirected to the itsme app via the Universal links or App links mechanism.</li>
  <li>Once the User has authorized the request and has been authenticated, itsme® will return an Authorization Code to the Service Provider Front-End, redirecting the user to your mobile or web application.</li>
  <li>The Service Provider Back-End calls the itsme® Token Endpoint and exchanges the Authorization Code for an ID Token identifying the User and an Access Token.</li>
  <li>The Service Provider Back-End MAY request the additional User information from the itsme® userInfo Endpoint by presenting the Access Token obtained in the previous step.</li>
  <li>At this stage you are able to confirm the success of the operation and display a success message.</li>
</ol>

If a user doesn't have the itsme® app, they'll be redirected to a mobile website with more information and download links.


<a name="OpenIDConfig"></a>
# itsme® OpenID Provider configuration


{% tabs itsme_config %}

{% tab itsme_config RSA keys %}

To simplify implementations and increase flexibility, <a href="https://openid.net/specs/openid-connect-discovery-1_0.html" target="blank">OpenID Connect allows the use of a Discovery Document</a>, a JSON document containing key-value pairs which provide details about itsme® configuration, such as the URIs of the 

<ul>
  <li>Authorization, Token and userInfo Endpoints</li>
  <li>supported claims</li>
  <li>JWKSet URL</li>
  <li>...</li>
</ul>

The Discovery document for itsme® can be retrieved from: 

Environment | URL
:-------- | :--------
**SANDBOX** | <a href="https://idp.e2e.itsme.services/v2/.well-known/openid-configuration" target="blank">https://idp.e2e.itsme.services/v2/.well-known/openid-configuration</a>
**PRODUCTION** | <a href="https://idp.prd.itsme.services/v2/.well-known/openid-configuration" target="blank">https://idp.prd.itsme.services/v2/.well-known/openid-configuration</a>

{% endtab %}

{% tab itsme_config Symmetric keys %}

YYY

{% endtab %}

{% endtabs %}


# Generate itsme® button

First, you will need to create a button to allow your users to authenticate with itsme®. See the <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/buttons-1518207548" target="blank">Button design guide</a> before you start the integration. 

Upon clicking this button, we will open a modal view which contains a field that need to be filled by the end user with it’s phone number. Note that mobile web users will skip the phone number step, as they use the itsme® mobile app directly to authenticate.


<a name="AuthNRequest"></a>
# API reference

## Create Authentication Request


{% tabs create_authentication_API %}

{% tab create_authentication_API RSA keys %}

<b><code>GET https://idp.<i>[e2e/prd]</i>.itsme.services/v2/authorization</code></b>

### Parameters

<table>
  <thead>
    <tr>
      <th>Parameter</th><th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>{% include parameter.html name="Param1" req="required" %}</td>
      <td>
        Global description of Param1<br />
        <table>
          <tr>
            <td>{% include parameter.html name="subparam1" req="optional" %}</td><td>description of subparam1</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="subparam2" req="required" %}</td><td>description of subparam2</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="Param2" req="optional" %}</td>
      <td>Global description of Param2</td>
    </tr>
  </tbody>
</table>

XXXXXXXXXXXXXXXXXXXXXXXXXXX

### Response

<code>200</code> <code>application/hal+json</code>

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="code" req="" %}</td>
      <td></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="state" req="" %}</td>
      <td></td>
    </tr>
  </tbody>
</table>


A payment object is returned, as described in Get Payment API.

### Example

**Request**

**Response**

{% endtab %}

{% tab create_authentication_API Symmetric keys %}

YYY

{% endtab %}

{% endtabs %}

