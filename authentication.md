---
layout: page
title: Authentication
permalink: /authentication/
nav_order: 3
---

# Overview

Our itsme® app can be seamlessly be integrated with your web desktop, mobile web or mobile application so you can perform secure identity checks.

The diagram below describes the **Authentication** process and how your backend is integrated within the itsme® architecture :
  
 ![Sequence diagram describing the OpenID flow](OpenID_Login_SeqDiag.png)

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


# Generate itsme® button

First, you will need to create a button to allow your users to authenticate with itsme®. See the <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/buttons-1518207548" target="blank">Button design guide</a> before you start the integration. 

Upon clicking this button, we will open a modal view which contains a field that need to be filled by the end user with it’s phone number. Note that mobile web users will skip the phone number step, as they use the itsme® mobile app directly to authenticate.


<a name="AuthNRequest"></a>
# API reference

## Create Authentication API

<b><code>GET https://idp.<i>[e2e/prd]</i>.itsme.services/v2/authorization</code></b>

### Parameters

:-------- | :--------| :----- 
**client_id** | Required | It identifies the client. This parameter value is generated during registration. 
**response_type** | Required | This defines the processing flow to be used when forming the response. Because itsme® uses the Authorization Code Flow, this value MUST be <i>"code"</i>.
**scope** | Required | It allows the application to express the desired scope of the access request. Each scope returns a set of user attributes. The scopes an application should request depend on which user attributes the application needs. Once the user authorizes the requested scopes, his details are returned in an ID Token and are also available through the /userinfo endpoint.<br>All scope values must be space-separated.</br><br>Possible scope values : <code>service</code> <code>openid</code> <code>profile</code> <code>email</code> <code>address</code> <code>phone</code></br>
**service** | Required | It indicates the itsme® serivce your application intends to use, e.g. <code>service:TEST_code</code> by replacing "TEST_code" with the service code generated during registration.
**openid** | Required | It  indicates that your application intends to use the OpenID Connect protocol to verify a user's identity by returning a <code>sub</code> claim which represents a unique identifier for the authenticated user.

:-------- | :--------| :----- 
**client_id** | Required | It identifies the client. This parameter value is generated during registration. 
**response_type** | Required | This defines the processing flow to be used when forming the response. Because itsme® uses the Authorization Code Flow, this value MUST be <i>"code"</i>.
**scope** | Required | It allows the application to express the desired scope of the access request. Each scope returns a set of user attributes. The scopes an application should request depend on which user attributes the application needs. Once the user authorizes the requested scopes, his details are returned in an ID Token and are also available through the /userinfo endpoint.<br>All scope values must be space-separated.</br><br>Possible scope values : <code>service</code> <code>openid</code> <code>profile</code> <code>email</code> <code>address</code> <code>phone</code></br>
**service** | Required | It indicates the itsme® serivce your application intends to use, e.g. <code>service:TEST_code</code> by replacing "TEST_code" with the service code generated during registration.
**openid** | Required | It  indicates that your application intends to use the OpenID Connect protocol to verify a user's identity by returning a <code>sub</code> claim which represents a unique identifier for the authenticated user.
**profile** | Optional | Returns claims that represent basic profile information, including <code>family_name</code>, <code>given_name</code>, <code>name</code>, <code>gender</code> and <code>birthdate</code>.
**email** | Optional | Returns the <code>email</code> claim, which contains the user's email address, and <code>email_verified</code>, which is a boolean indicating whether the email address was verified by the user.
**address** | Optional | Returns the information about the user's postal address, including <code>formatted</code>, <code>street_address</code>, <code>postal_code</code>, <code>locality</code> and <code>country</code>.
**phone** | Optional | Returns the <code>phone</code> claim, which contains the user's phone number, and <code>phone_number_verified</code>, which is a boolean indicating whether the phone number was verified by the user.
**redirect_uri** | Required | This is the URI to which the authentication response will be sent. The Redirection URI MUST use the <i>"https"</i> scheme. The Redirection URI MAY NOT use the <i>"http"</i> or an alternate scheme, such as one that is intended to identify a callback into a native application.<br></br><b>Note</b> : <ul><li>this URI MUST be whitelisted in our systems. So, don't forget to send your it by email to onboarding@itsme.be and we’ll make sure to complete the configuration for you in no time!</li><li>Regardless of the application you are building you should make sure that your redirect URIs support the Universal links and App links mechanism. Functionally, it will allow you to have only one single link that will either open your desktop web application, your mobile app or your mobile site on the User’s device. Universal links and App links are standard web links (http://mydomain.com) that point to both a web page and a piece of content inside an app. When a Universal Link is opened, the app OS checks to see if any installed app is registered for that domain. If so, the app is launched immediately without ever loading the web page. If not, the web URL is loaded into the webbrowser. The specifications for the implementation of Universal links and App links can be found in the Appendix.</li></ul>
**state** | Strongly RECOMMENDED | An opaque value used in the Authentication Request, which will be returned unchanged in the Authorization Code. This parameter SHOULD be used for preventing cross-site request forgery (XRSF). <br>When deciding how to implement this, one suggestion is to use a private key together with some easily verifiable variables, for example, your client ID and a session cookie, to compute a hashed value. This will result in a byte value that will be infeasibility difficult to guess without the private key. After computing such an HMAC, base-64 encode it and pass it to the Authorization  Server as <i>"state"</i> parameter. Another suggestion is to hash the current date and time. This requires your application to save the time of transmission in order to verify it or to allow a sliding period of validity.</br>
**nonce** | Strongly RECOMMENDED | A string value used to associate a session with an ID Token, and to mitigate replay attacks. The value is passed through unmodified from the Authentication Request to the ID Token. Sufficient entropy MUST be present in the <i>"nonce"</i> values used to prevent attackers from guessing values. See <a href="http://openid.net/specs/openid-connect-core-1_0.html#NonceNotes" target="blank">OpenID Connect Core specifications</a> for more information.
**login_hint** | Optional | Can be used to pre-fill the phone number field on the itsme® OpenID web page for the User, if your application knows ahead of time which User is trying to authenticate. If provided, this value MUST be a phone number in the format specified for the <i>"phone_number"</i> claim: <i>"<countrycode>+<phonenumber>"</i>. E.g. <i>"login_hint=32+123456789"</i>.</br><br><i>"login_hint"</i> with invalid syntax will be ignored.</br>
**display** | Optional | ASCII string value that specifies how the Authorization Server displays the authentication and consent User interface pages to the User. MUST be <i>"page"</i> if provided.<br>Other values will yield an HTTP ERROR <i>"not_implemented"</i>.</br>
**prompt** | Optional | Space delimited, case sensitive list of ASCII string values that specifies whether the Authorization Server prompts the User for reauthentication and consent. MUST be <i>"consent"</i> if provided. 
**ui_locales** | Optional | User's preferred languages and scripts for the User interface (e.g.: OpenID web page). Supported values are: <i>"fr"</i>, <i>"nl"</i>, <i>"en"</i> and <i>"de"</i>. Any other value will be ignored.
<a name="acrvalues">**acr_values**</a> | Optional | Space-separated string that specifies the acr values that the Authorization Server is being requested to use for processing this Authentication Request, with the values appearing in order of preference.<br>2 values are supported:<ul><li>Basic level - let the User to choose either fingerprint usage (if device is compatible) or PIN<br><i>"http://itsme.services/v2/claim/acr_basic"</i></br></li><li>Advanced level - force the User to use PIN<br><i>"http://itsme.services/v2/claim/acr_advanced"</i></br></li></ul>When multiple values are provided only the most constraining will be used (advanced > basic). If not provided basic level will be used.</br>
**max_age** | Not supported | Any supplied value will be ignored.<br>As itsme® does not maintain a session mechanism, an active authentication is always required.</br>
**response_mode** | Not supported | Any supplied value will be ignored.
**id\_token\_hint** | Not supported | Any supplied value will be ignored.
**claims_locales** | Not supported | Any supplied value will be ignored.
**registration** | Not supported | Any supplied value will be ignored.
**claims** | Optional | This parameter is used to request specific claims. The value is a JSON object listing the requested claims. <br>See the [list](#Data) below for more information.</br>
**request_uri** | Optional | This parameter enables OpenID Connect parameters to be passed by reference. The <i>"request_uri"</i> value is a URL using the https scheme referencing a resource containing a Request Object value, which is a JWT containing the request parameters. <br>When the <i>"request_uri"</i> parameter is used, the OpenID Connect request parameter values contained in the referenced JWT supersede those passed using the OAuth 2.0 request syntax.</br><br>The following validations should be done when using the <i>"request_uri"</i> parameter:</br><ul><li>The values for the <i>"response_type"</i> and <i>"client_id"</i> parameters MUST be filled in the Authentication Request, since they are REQUIRED in the OpenID Connect Core specifications. The values for these parameters MUST match those in the Request Object, if present.</li><li>Even if a <i>"scope"</i> parameter is present in the Request Object value, a <i>"scope"</i> parameter – containing the <i>"openid"</i> scope value to indicate to the underlying OpenID Connect Core logic that this is an OpenID Connect request – MUST always be passed in the Authentication Request.</li><li>The Request Object MUST be MUST be <b>signed</b> then <b>encrypted</b>, with the result being a Nested JWT, as defined in the <a href="https://belgianmobileid.github.io/slate/jose.html" target="blank">JSON Web Token</a> (JWT) section. As the Request Object is a nested JWT, it MUST contain the claims <i>"iss"</i> (issuer) and <i>"aud"</i> (audience) as members. The <i>"iss"</i> value MUST be your Client ID. The <i>"aud"</i> value MUST be the value corresponding to the key "authorization_endpoint" in the <a href="#OpenIDConfig" target="blank">itsme® Discovery document</a>.</li>><li>You need to store the Request Object resource remotely at a URL the the Authorization Server can access. This URL is the Request URI, <i>"request_uri"</i>. Usage of 'localhost' is not permitted.<li>The Request URI MUST contain the port 443 as in this example: https://test.istme.be:443/p/test.</li><li>The Request URI value is a URL using the <i>https</i> scheme.</li></ul><br>Don't forget to send share this URI by email to onboarding@itsme.be and we’ll make sure to complete the configuration for you in no time!</br><br>If the <i>"request"</i> parameters is used, this parameter MUST NOT be used in the same request.</br>
**request** | Optional | If the <i>"request_uri"</i> parameters is used, this parameter MUST NOT be used in the same request.</br>

### Response

### Example

**Request**

{% tabs code_authorization %}

{% tab code_authorization js %}

XXX

{% endtab %}

{% tab code_authorization ruby %}

YYY

{% endtab %}

{% endtabs %}

**Response**


<a name="Data"></a>
###  Requesting claims about the User and the Authentication event 

The OpenID Connect Core specification defines a sets of claims that MAY be requested via the <i>"scope"</i> and/or <i>"claims"</i> request parameter.

<aside class="notice">As itsme® manage multiple international ID Templates - each with his own set of User Data - it can be that you will not receive some information about a User even if you requested the claim it in the Authorisation Request.
</aside>

Below, you will find the list of claims that MAY be requested via the <i><b>"scope"</b></i> request parameter :

Value | Returned claim | Remarks | Example 
:-- | :-- | :-- | :-- 
**profile** | family_name |  | Smith 
 | given_name |  For BE citizen, we do share the two complete first names and the intimal of the third name if any.<br></br>For other ID templates this might differ. | John Matthew A 
 | name |  | John Matthew A Smith 
 | gender |  | male
 | birthdate |  | 1959-06-03 
**email** | email |  Rule for email validity are the following: [a-zA-Z0-9][-_\w\.+]{0,30}@([-\w+]{1,30}[.]){1,4}[a-zA-Z]{2,12}<br></br>Max length: 255 | john.smith@company.lu 
 | email_verified |  | false
**phone** | phone_number |  This attribute is stored as an object with 2 fields in our database: <ul><li>mobilePhone/phoneNumber = format should be the "international format" without the country code and leading 0</li><li>mobilePhone/countryCode = [0-9]{2-3}</li></ul> | +32 495162995 
 | phone_number_verified | Supported values are <i>"true"</i> or <i>"false"</i>.But, it is always <i>"true"</i> as we perform a SMS OTP verification during the enrollment.  | true
**address** | formatted |  | Place Victor Horta 79, 1348 Louvain-la-Neuve BE
 | street_address |   | Place Victor Horta 79
 | postal_code |   | 1348 
 | locality |  | Louvain-la-Neuve 
 | country |  | BE
 
Typically, the values returned via the "scope" parameter only contain claims about the identity of the User. Via the <i><b>"claims"</b></i> parameter you MAY request the same claims as in the ones available via the <i>"scope"</i> request parameter, as well as information about the specific ID documents, the device and the app version used by the user. These claims are specified below :

Value | Returned claim | Remarks | Example 
:-- | :-- | :-- | :-- 
**name** | name | | John Matthew A Smith 
**given_name** |  given_name | For BE citizen, we do share the two complete first names and the intimal of the third name if any.<br></br>For other ID templates this might differ. | John Matthew A
**family_name** | family_name | | Smith
**birthdate** | birthdate | | 1959-06-03
**http://itsme.services/v2/ claim/birthdate_as_string** | http://itsme.services/v2/ claim/birthdate_as_string | | 10 MAY 1988
**gender** | gender | | male
**email** | email | Rule for email validity are the following: [a-zA-Z0-9][-_\w\.+]{0,30}@([-\w+]{1,30}[.]){1,4}[a-zA-Z]{2,12}<br></br>Max length: 255 | john.smith@company.lu 
**email_verified** | email_verified | | false
**phone_number** | phone_number | This attribute is stored as an object with 2 fields in our database: <ul><li>mobilePhone/phoneNumber = format should be the "international format" without the country code and leading 0</li><li>mobilePhone/countryCode = [0-9]{2-3}</li></ul> | +32 428656565
**phone_number_verified** | phone_number_verifie | Supported values are <i>"true"</i> or <i>"false"</i>.But, it is always <i>"true"</i> as we perform a SMS OTP verification during the enrollment. | true  
**address** | formatted | | Place Victor Horta 79, 1348 Louvain-la-Neuve BE
 | street_address | | Place Victor Horta 79
 | postal_code | | 1348 
 | locality | | Louvain-la-Neuve 
 | country | | BE
**http://itsme.services/v2/ claim/claim_citizenship** | http://itsme.services/v2/ claim/claim_citizenship  | | Belg 
**http://itsme.services/v2/ claim/place_of_birth** | formatted |  | bruxelles Belgium 
 | city | | bruxelles
 | country | | BE
**http://itsme.services/v2/ claim/physical_person_photo** | http://itsme.services/v2/ claim/physical_person_photo | | /9j/4AA[...]n 
**http://itsme.services/v2/ claim/BEeidSn** | http://itsme.services/v2/ claim/BEeidSn | 12 digits in the form xxx-xxxxxxx-yy. The check-number yy is the remainder of the division of xxxxxxxxxx by 97 | xxx-xxxxxxx-yy 
**http://itsme.services/v2/ claim/BENationalNumber** | http://itsme.services/v2/ claim/BENationalNumber | The value has 11 digits. | 88041827591
**http://itsme.services/v2/ claim/claim_luxtrust_ssn** | http://itsme.services/v2/ claim/claim_luxtrust_ssn | | 12345678901234567890
**http://itsme.services/v2/ claim/claim_device** | os |  | 
 | appName |  | 
 | appRelease  |   | 
 | deviceLabel |  | 
 | debugEnabled | |  
 | deviceID | |  
 | osRelease  | |  
 | manufacturer |  | 
 | hasSimEnabled | |  
 | deviceLockLevel |  | 
 | smsEnabled |  | | 
 | rooted  | |  
 | imei | |  
 | deviceModel |  |  
 | sdkRelease | |  
**http://itsme.services/v2/ claim/transaction_info** | securityLevel | It tells you whether or not the SIM was successfully contacted during the transaction. The returned values could be <i>"SOFT_ONLY"</i>, <i>"SIM_ONLY"</i> or <i>"SIM_AND_SOFT"</i>.<br><b>No value is returned for the moment</b></br>. | 
 | bindLevel | It tells you if the User account is bound to a SIM card or not, at the time the transaction occurred. The returned values could be <i>"SOFT_ONLY"</i>, <i>"SIM_ONLY"</i> or <i>"SIM_AND_SOFT"</i>. <br><b>No value is returned for the moment</b></br>. | 
 | appRelease | The Mobile Country Code. The returned value is an Integer (three digits) representing the mobile network country. itsme(r) does not possess this information for every account. <br><b>No value is returned for the moment</b></br>. | 


<a name="AuthNResponse"></a>
## 3.5. Capturing an Authorization Code

### Capturing a successful Authorization Code

If the User is successfully authenticated and authorizes access to the data requested, itsme® will return an Authorization Code to your server component. This is achieved by returning an Authentication Response, which is a HTTP 302 redirect request to the <i>"redirect_uri"</i> specified previously in the Authentication Request. The following is a non-normative example of a successful Authentication Response:
 
<code style=display:block;white-space:pre-wrap>HTTP/1.1 302 Found
Location: https://client.example.org/cb?
code=SplxlOBeZQQYbYS6WxSbIA&
state=af0ifjsldkj</code>

The response will contain:

Values | Returned | Description
:----- |:-------- |:---
**code** | Always |The <i>"code"</i> parameter holds the Authorization Code which is a string value. The content of Authorization Code is opaque for you. This code has a lifetime of 3 minutes.
**state** | If requested |The <i>"state"</i> parameter will be returned if you provided a value in the Authentication Request. You should validate that the value returned matches the one supplied in the Authentication Request. The state value can additionally be used to mitigate against XSRF attacks by cryptographically binding the value of this parameter with a browser cookie.<br>If a wrong/unknown <i>"state"</i> is received, you should take it into account and refuse the related <i>"code"</i> or from a security detection/prevention point of view, monitor if it is a recurring pattern or not.</br>

 
### Handling Authentication Error Response

If the request fails due to a missing, invalid, or mismatching redirection URI, or if the client identifier is missing or invalid, the Authorization Server SHOULD inform the User of the error and MUST NOT automatically redirect him to the invalid redirection URI. 

If the User denies the Authentication Request or if the request fails for reasons other than a missing or invalid redirection URI, itsme® will return an error response to your application. As for a successful response this is achieved by returning a HTTPS 302 redirect request to the redirection_uri specified in the Authentication Request. The error response parameters are the following:

Values |	Returned | Description
:--|:--|:--
**error**	| Always |	Error type. 
**error_description** |	Optional	| Indicating the nature of the error.
**state** |	If requested	| Set to the value defined in the Authorisation Request, if any.

The following is a non-normative example of an error response:

<code style=display:block;white-space:pre-wrap>HTTP/1.1 302 Found
Location: https://client.example.org/cb?
error=invalid_request
&error_description=Unsupported%20response_type%20value
&state=af0ifjsldkj</code>

The following table describes the various error codes that can be returned in the <i>"error"</i> parameter of the error response:

Error | Description
:-- | :-- 
**interaction_required**  | The Authorization Server requires User interaction of some form to proceed.
**invalid_request_object** | The <i>"request"</i> parameter contains an invalid Request Object.
**registration_not_supported** | This error is returned because itsme® does not support use of the <i>"registration"</i> parameter.

All other HTTPS errors unrelated to OpenID Connect Core will be returned to the User using the appropriate HTTPS status code.


## 3.6. Exchanging the Authorization Code 
<a name="tokenEndpoint"></a> 

Once your server component has received an [Authorization Code](#AuthNResponse), your server can exchange it for an Access Token and an ID Token.

<aside class="notice">You might also read in the OpenID Connect Core specification about the Refresh Token, but we don't support them (we don't implement any session mechanism).
</aside>

Your server makes this exchange by sending an HTTPS POST request to the itsme® Token Endpoint URI. This URI can be retrieved from the [itsme® Discovery document](#OpenIDConfig), using the key <i>"token_endpoint"</i>.

<aside class="notice">An Authorization Code can only be exchanged once. Attempting to re-exchange a code will generate a bad request response, outlined below in the section <a href="https://belgianmobileid.github.io/slate/login.html#3-6-managing-id-token-response" target="blank">Handling token error response</a>.
</aside>

The request MUST include the following parameters in the POST body:

Parameter | Required | Description
:-- | :-- | :--
**grant_type** | Required | This MUST be set to <i>"authorization_code"</i>.
**code** | Required | The Authorization Code received in response to the Authentication Request.
**redirect_uri** | Required | The redirection URI supplied in the original Authentication Request. This is the URL to which you want the User to be redirected after the authorization is complete.
**client_assertion** | Required | To ensure that the request is genuine and that the tokens are not returned to a third party, you will be authenticated when making the Token Request.<br>The OpenID Connect Core specifications support multiple authentication methods, but itsme® only supports <i>"private_key_jwt"</i>. The JWT Payload in the <i>"client_assertion"</i> parameter MUST be <b>signed then encrypted</b>, with the result being a Nested JWT, as defined in the <a href="https://belgianmobileid.github.io/slate/jose.html" target="blank">JSON Web Token</a> (JWT) section.</br><br>See the <a href="https://belgianmobileid.github.io/slate/jose.html" target="blank">JOSE</a> specifications for more information.</br>
**client\_assertion\_type** | Required | This MUST be set to <i>"urn:ietf:params:oauth:client-assertion-type:jwt-bearer"</i>. 

The following is a non-normative example of a request to obtain an ID Token and Access Token:

<code style=display:block;white-space:pre-wrap>POST /token HTTP/1.1
Host: server.example.com
Content-Type: application/x-www-form-urlencoded
grant_type=authorization_code
&code=i1WsRn1uB1
&redirect_uri=https://test.istme.be
&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer
&client_assertion=PHNhbWxwOl ... ZT</code>

According to the <i>"private_key_jwt"</i> client authentication method, the <i>"client_assertion"</i> contains the following parameters in the JWT Payload:

Parameter | Required | Description
:-- | :-- | :-- 
**iss** | Required | The issuer of the <i>"private_key_jwt"</i>. This MUST contain the <i>"client_id"</i>. This is the client identifier you received after sharing your organisation details with us..
**sub** | Required | The subject of the <i>"private_key_jwt"</i>. This MUST contain the <i>"client_id"</i>. This is the client identifier you received after sharing your organisation details with us..
**aud** | Required | Value that identifies the Authorization Server as an intended audience. This MUST be the itsme® Token Endpoint URL: <i>"https://idp.prd.itsme.services/v2/token"</i>.
**jti** | Required | The <i>"jti"</i> (JWT ID) claim provides a unique identifier for the JWT. The identifier value MUST be assigned by the you in a manner that ensures that there is a negligible probability that the same value will be accidentally assigned to a different data object; if the application uses multiple issuers, collisions MUST be prevented among values produced by different issuers as well.  The <i>"jti"</i> claim can be used  to prevent the JWT from being replayed. The <i>"jti"</i> value is a case-sensitive string. 
**exp** | Required | The <i>"exp"</i> (expiration time) claim identifies the expiration time on or after which the JWT MUST NOT be accepted for processing.  The processing of the <i>"exp"</i> claim requires that the current date/time MUST be before the expiration date/time listed in the <i>"exp"</i> claim. Implementers MAY provide for some small leeway, usually no more than a few minutes, to account for clock skew.  Its value is a JSON number representing the number of seconds from 1970-01-01T0:0:0Z as measured in UTC until the date/time.


<a name="TokenResponse"></a>
## 3.7. Managing Token Response

### Extracting a successful Token Response

If the Token Request has been sucessfully validated we will return an HTTP 200 OK response including ID and Access Tokens as in the example below:

<code style=display:block;white-space:pre-wrap>HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache
{
  "access_token": "SlAV32hkKG",
  "token_type": "Bearer",
  "expires_in": 3600,
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
}</code>

The response body will include the following values:

Values | Returned | Description
:-- | :-- | :--
**access_token** | Always | The Access Token which may be used to access the userInfo Endpoint.
**token_type** | Always | Set to <i>"Bearer"</i>.
**id_token** | Always | The ID Token is a JSON Web Token (JWT) that contains User profile information (like the User's name, email, and so forth), represented in the form of claims. 
**at_hash** | Not supported | itsme® does not provide any value for this parameter.
**refresh_token** | Not supported | itsme® does not provide any value for this parameter as it only maintains short-lived session to enforce re-authentication.

With the following values returned in the <i>"id_token"</i>: 

Values |	Returned |	Description
:-- | :-- | :--
**iss**	| Always | Identifier of the issuer of the ID Token.
**sub** |	Always | An identifier for the User, unique among all itsme® accounts and never reused. Use <i>"sub"</i> in the application as the unique-identifier key for the User. It has 36 characters.
**aud**	| Always |	Audience of the ID Token. This will contain the <i>"client_id"</i>. This is the client identifier (e.g. : Project ID) you received when registering your project in the [itsme® B2B portal](#Onboarding).
**exp**	| Always |	Expiration time on or after which the ID Token MUST NOT be accepted for processing.
**iat** |	Always	| The time the ID Token was issued, represented in Unix time (integer seconds).
**auth_time** | Always | The time the User authentication occurred, represented in Unix time (integer seconds). 
**nonce** | If requested | String value used to associate a session with an ID Token, and to mitigate replay attacks. The value is passed through unmodified from the Authentication Request to the ID Token. Sufficient entropy MUST be present in the <i>"nonce"</i> values used to prevent attackers from guessing values. See <a href="http://openid.net/specs/openid-connect-core-1_0.html#NonceNotes" target="blank">the OpenID Connect Core specifications</a> for more information.
**acr** | If requested | Could be <i>"http://itsme.services/V2/claim/acr_basic"</i> or <i>"http://itsme.services/V2/claim/acr_advanced"</i> depending on the value entered in the <i>"acr_values"</i>  Authorisation Request parameter. If no value is provided in the <i>"acr_values"</i> parameter, the <i>"acr"</i> will contain <i>"http://itsme.services/V2/claim/acr_basic"</i>.
**amr** | Never |
**azp** | Never |

However, before being able to store and use the returned values from <i>"id_token"</i>, you will first need to validate it by following the the ID Token validation rules described in the section below.

### ID Token validation

You MUST validate the ID Token in the Token Response in the following manner:

<ol>
  <li>As the ID Token is a Nested JWT object, you will have to decrypt and verify it using the keys and algorithms that you specified when registering your project in the <a href="#Onboarding" target="blank">itsme® B2B portal</a>. The process of decryption and signature validation is described in on.<br>If the ID Token is not encrypted, you SHOULD reject it.</br></li>
  <li>The Issuer identifier for itsme® (which is obtained by using the key <i>"issuer"</i> in the <a href="#OpenIDConfig" target="blank">itsme® Discovery document</a>) MUST exactly match the value of the <i>"iss"</i> claim.</li>
  <li>You MUST validate that the <i>"aud"</i> claim contains your <i>"client_id"</i> value registered in the <a href="#Onboarding" target="blank">itsme® B2B portal</a>. The ID Token MUST be rejected if the ID Token does not list the <i>"client_id"</i> as a valid audience.</li>
  <li>The current time MUST be before the time represented by the <i>"exp"</i> claim.</li>
</ol>

If all the above verifications are successful, you can use the subject (<i>"sub"</i>) of the ID Token as the unique identifier of the corresponding User.

### Handling token error response 

If the Token Request is invalid or unauthorized an HTTP 400 response will be returned as in the example:

<code style=display:block;white-space:pre-wrap>HTTP/1.1 400 Bad Request
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache
{
  "error": "invalid_request"
}</code>

The response will contain an error parameter and optionally <i>"error_description"</i> parameter. 


## 3.8. Retrieving User attributes or device/transaction specific claims

### Creating the userInfo Request 

OpenID Connect Core specifications also allow your application to obtain basic profile information about a specific User in a interoperable way. This is achieved by sending a HTTPS GET request to the itsme® userInfo Endpoint, passing the Access Token value in the Authorization header using the Bearer authentication scheme. The itsme userInfo Endpoint URI can be retrieved from the [itsme® Discovery document](#OpenIDConfig), using the key <i>"userinfo_endpoint"</i>.

<code style=display:block;white-space:pre-wrap>GET https://idp.prd.itsme.services/v2/userinfo HTTP/1.1
Authorization: Bearer <access token></code>

### Managing the userInfo Response 

The itsme® userInfo Endpoint will return a HTTP 200 OK response and the User claims in a Nested JWT format. The following is a non-normative example of a UserInfo Response:

<code style=display:block;white-space:pre-wrap>HTTP/1.1 200 OK
  Content-Type: application/json
  {
   "sub": "248289761001",
   "name": "Jane Doe",
   "given_name": "Jane",
   "family_name": "Doe",
   "email": "janedoe@example.com",
   "picture": "[base64 encoded picture]"
  }</code>

<aside class="notice">For privacy reasons itsme® may elect to not return values for some requested claims. In that case the claim will be omitted from the JSON object rather than being present with a null or empty string value.
</aside>

However, before being able to consume the claims from the userInfo response, you will first need to validate it by following the userInfo response validation rules described in the section below.

### UserInfo response validation

You MUST validate the userInfo reponse in the following manner:

<ol>
  <li>As the userInfo response is a Nested JWT object, you will have to decrypt and verify it using the keys and algorithms that the you specified when registering your project in the [itsme® B2B portal](#Onboarding). The process of decryption and signature validation is described in <a href="https://belgianmobileid.github.io/slate/jose#4-3-decrypting" target="blank">section 4.3</a> of the JOSE specifications.<br>If the userInfo response is not encrypted, the you SHOULD reject it.</br></li>
  <li>The <i>"sub"</i> claim will always be included in the response and this should be verified by you to mitigate against token substitution attacks. The <i>"sub"</i> claim in the userInfo response MUST be verified to exactly match the <i>"sub"</i> claim in the <i>"id_token"</i>; if they do not match, the userInfo response values MUST NOT be used.</li>
</ol>

When an error condition occurs an error response as defined in the <a href="https://tools.ietf.org/html/rfc6750" target="blank">OAuth 2.0 Bearer Token Usage specification</a> will be returned.



