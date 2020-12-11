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
  <tbody>
    <tr>
      <td>{% include parameter.html name="client_id" req="REQUIRED" %}</td>
      <td>It identifies the client. This parameter value is generated during registration.</td>
    </tr>
     <tr>
      <td>{% include parameter.html name="response_type" req="REQUIRED" %}</td>
      <td>This defines the processing flow to be used when forming the response. Because itsme® uses the Authorization Code Flow, this value MUST be <code>code</code>.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="scope" req="REQUIRED" %}</td>
      <td>
        It allows the application to express the desired scope of the access request. Each scope returns a set of user attributes. The scopes an application should request depend on which user attributes the application needs. Once the user authorizes the requested scopes, his details are returned in an ID Token and are also available through the UserInfo Endpoint.<br><br>All scope values must be space-separated.<br><br>The basic (and required) scopes is <code>openid</code> and <code>service</code>. Beyond that, your application can ask for additional standard scopes values which map to sets of related claims : <code>profile</code> <code>email</code> <code>address</code> <code>phone</code><br />
        <table>
          <tr>
            <td>{% include parameter.html name="service" req="REQUIRED" %}</td><td>It indicates the itsme® service your application intends to use, e.g. <code>service:TEST_code</code> by replacing "TEST_code" with the service code generated during registration.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="openid" req="REQUIRED" %}</td><td>It indicates that your application intends to use the OpenID Connect protocol to verify a user's identity by returning a <code>sub</code> claim which represents a unique identifier for the authenticated user.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="profile" req="OPTIONAL" %}</td><td>Returns claims that represent basic profile information, including <code>family_name</code>, <code>given_name</code>, <code>name</code>, <code>gender</code> and <code>birthdate</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="email" req="OPTIONAL" %}</td><td>Returns the <code>email</code> claim, which contains the user's email address, and <code>email_verified</code>, which is a boolean indicating whether the email address was verified by the user.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="address" req="OPTIONAL" %}</td><td>Returns the information about the user's postal address. The value of the address member is a JSON structure containing some or all of these members <code>formatted</code> <code>street_address</code> <code>postal_code</code> <code>locality</code> <code>country</code></td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="phone" req="OPTIONAL" %}</td><td>Returns the <code>phone</code> claim, which contains the user's phone number, and <code>phone_number_verified</code>, which is a boolean indicating whether the phone number was verified by the user.</td>
          </tr> 
        </table>
      </td>
    </tr>
  </tbody>
</table>





<table>
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

