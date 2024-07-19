<aside class="notice">Depending on the identity document used to create an itsme® account and the country issuing it, not all claims are always available or formated the same way. Please refer to <a href="https://belgianmobileid.github.io/doc/claims/" target="blank">this page</a> to check which claims are available in which cases.</aside>

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
            <td>{% include parameter.html name="eid" req="OPTIONAL" %}</td><td>Returns the <code>http://itsme.services/v2/claim/BENationalNumber</code> claim, which contains the unique identification number of natural persons who are registered in Belgium, and <code>http://itsme.services/v2/claim/BEeidSn</code>, which is a string indicating the Belgian ID card number.<br><br>If requested, a value SHALL always be returned for the above claims.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="redirect_uri" req="REQUIRED" %}</td>
      <td>It is the URL to which users are redirected once the authentication is complete. <br><br>The following restrictions apply to redirect URIs:
        <tabul>
          <tabli>The redirect URI MUST match the value preregistered during the registration.</tabli>
          <tabli>The redirect URI MUST begin with the scheme <code>https</code> (refer to <a href="https://belgianmobileid.github.io/doc/authentication/#certificates-and-website-security" target="blank">this section</a> for more information).</tabli>
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
      <td>Specify how the itsme® sign-in page should be displayed to the user. Currently, only the <code>page</code> value is supported but in the future we might support additional display modes like <code>touch</code>.</td>
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
      <td>Allows to request specific user's details ("claims"). You can choose to receive those claims either in the ID Token (from /token endpoint) or in the UserInfo object (from /userinfo endpoint).<br />It MUST be a JSON object containing an <code>{"id_token":{...}}</code> member or a <code>{"userinfo":{...}}</code> member respectively. This member will then contain all the desired claims - see example below.<br><b>Note</b>: to avoid the need of a /userinfo request, itsme® recommends to retrieve the claims directly from the ID Token.<br><br>Supported claims are listed below. Please check <a href="https://belgianmobileid.github.io/doc/claims/" target="blank">this page</a> for availability and format per country.<br />
        <table>
          <tr>
            <td>{% include parameter.html name="name" req="OPTIONAL" %}</td><td>Returns user's full name in displayable form including all name parts, possibly including titles and suffixes.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="given_name" req="OPTIONAL" %}</td><td>Returns user's given name(s) or first name(s). Note that in some cultures, people can have multiple given names; all can be present, with the names being separated by space characters.<br><br>If requested, a value MAY NOT be returned if the user doesn't have any first name(s).</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="family_name" req="OPTIONAL" %}</td><td>Returns user's surname(s) or last name(s). Note that in some cultures, people can have multiple family names or no family name; all can be present, with the names being separated by space characters.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="birthdate" req="OPTIONAL" %}</td><td>Return user's birthdate, represented as a string in YYYY-MM-DD date format. itsme® users are always 16 years old or more.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/birthdate_as_string" req="OPTIONAL" %}</td><td>Returns user's birthdate in an unprocessed way, as mentioned on the ID document. itsme® users are always 16 years old or more.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="gender" req="OPTIONAL" %}</td><td>Returns user's gender. Possible values are: <code>female</code> <code>male</code> <code>unknown</code> <code>n/a</code>. If the value mentioned on the user's ID document is different from those (local language, letter code...), then we apply a best-effort mapping to one of those values.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/official_gender" req="OPTIONAL" %}</td><td>Returns user's gender unaltered, exactly as mentioned on their ID document.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="locale" req="OPTIONAL" %}</td><td>Returns user's itsme app language, represented as a string format. Possible values are : <code>NL</code> <code>FR</code> <code>DE</code> <code>EN</code></td>
          </tr>
          <tr>
            <td>{% include parameter.html name="picture" req="OPTIONAL" %}</td><td>Returns user's ID picture, represented as a URL string. This URL refers to an image file (for example, a JPEG, JPEG2000, or PNG image file). This image is the raw (unprocessed) image contained on the ID document.<br /><br />
            Accessing this URL has to be done with your bearer token. Example:<br />
            <code>
              GET /v2/picture HTTP/1.1<br />
              Host: idp.prd.itsme.services<br />
              Authorization: Bearer SlAV32hkKG
            </code></td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/physical_person_photo" req="OPTIONAL" %}</td><td>Returns user's ID picture, represented as a JSON Object containing these members:<br><code>format</code>: the MIME type<br><code>value</code>: the base64 encoded image.<br><br>This picture is read from the ID document but converted to always return a 200x140 px, 24 BPP JPEG image.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="email" req="OPTIONAL" %}</td><td>Returns user's email address.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="email_verified" req="OPTIONAL" %}</td><td>Returns <code>true</code> if the user's e-mail address is verified; otherwise <code>false</code>.<br><br><b>Note</b> : currently, itsme® always returns <code>false</code> for this claim because the email verification feature is not yet implemented in our systems (or does not return a value if no email address is available).</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="phone_number" req="OPTIONAL" %}</td><td>Returns user's phone number, represented as a string format. For example : <code>[+][country code] [subscriber number including area code]</code>.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="phone_number_verified" req="OPTIONAL" %}</td><td>Returns <code>true</code> if the user's phone number is verified; otherwise <code>false</code>.<br>Note: currently, all phone numbers are verified so this claims always returns <code>true</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="address" req="OPTIONAL" %}</td><td>Returns user's postal address, represented as JSON Object containing some or all of these members: <code>formatted</code> <code>street_address</code> <code>postal_code</code> <code>locality</code>.<br></td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/claim_citizenship" req="OPTIONAL" %}</td><td>Returns user's nationality. The format is directly depending on the underlying ID document: for Belgian ID documents this is represented as a string, and for Dutch or Lux ID documents this is represented in the <a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a> format.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/claim_citizenship_as_iso" req="OPTIONAL" %}</td><td>Returns user's nationality. The format is always <a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a>.</td>
          </tr>
           <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/place_of_birth" req="OPTIONAL" %}</td><td>Returns user's place of birth, represented as a JSON Object containing some or all of these members <code>formatted</code> <code>city</code> <code>country</code>.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/BEeidSn" req="OPTIONAL" %}</td><td>Returns user's Belgian ID document number, represented as a string with 12 digits in the form xxx-xxxxxxx-yy. (the check-number yy is the remainder of the division of xxxxxxxxxx by 97) for Belgian citizens, or starting with a letter and nine digits in the form B xxxxxxx xx for EU/EEA/Swiss citizens. This claim is made redundant by the <code>IDDocumentSN</code> claim below which we advise to use instead.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/claim_device" req="OPTIONAL" %}</td><td>Returns user's phone information, represented as a JSON Object containing some or all of these members <code>os</code> <code>appName</code> <code>appRelease</code> <code>deviceLabel</code> <code>debugEnabled</code> <code>deviceID</code>	<code>osRelease</code> <code>manufacturer</code> <code>deviceLockLevel</code> <code>smsEnabled</code> <code>rooted</code> <code>msisdn</code> <code>deviceModel</code>	<code>sdkRelease</code>.</td>       
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/transaction_info" req="OPTIONAL" %}</td><td>Returns information about the itsme® transaction, represented as a JSON Object containing some or all of these members <code>securityLevel</code> <code>bindLevel</code> <code>appRelease</code>.</td>
           </tr> 
           <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/BENationalNumber" req="OPTIONAL" %}</td><td>Returns user's Belgian unique identification number, represented as a string with 11 digits in the form YY.MM.DD-xxx.cd where YY.MM.DD is the birthdate of the person, xxx a sequential number (odd for males and even for females) and cd a check-digit. Some exceptions could apply.<br></td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/validityFrom" req="OPTIONAL" %}</td><td>This is a <a href="#metadata">metadata</a>.<br>Returns user's Belgian ID document issuance date, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. Can only be returned in combination with claim http://itsme.services/v2/claim/BEeidSn.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/validityTo" req="OPTIONAL" %}</td><td>This is a <a href="#metadata">metadata</a>.<br>Returns user's Belgian ID card expiry date, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. Can only be returned in combination with claims http://itsme.services/v2/claim/BEeidSn or http://itsme.services/v2/claim/IDDocumentSN.<br><br>If requested, a value MAY NOT be returned.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/verificationDate" req="OPTIONAL" %}</td><td>This is a <a href="#metadata">metadata</a>.<br>Returns the date when the user's document was read for the last time, represented as a string in YYYY-MM-DDThh:mm:ss date format specified by ISO 8601.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/IDDocumentSN" req="OPTIONAL" %}</td><td>Returns the ID document number, represented as a string.</td>
          </tr> 
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/IDDocumentType" req="OPTIONAL" %}</td><td>Returns the ID document type. This is a 1 or 2 characters code defined by the ICAO. Identity cards have a code with first letter I while passports have a code starting with P.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/IDIssuingCountry" req="OPTIONAL" %}</td><td>This is a <a href="#metadata">metadata</a>.<br>Returns the 3-letters iso code of the country that issued the identity document.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/issuance_locality" req="OPTIONAL" %}</td><td>This is a <a href="#metadata">metadata</a>.<br>Returns the locality that issued the ID document used to create the itsme® account.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/app" req="OPTIONAL" %}</td><td>Returns a JSON object with 3 members: <code>appInstalledDate</code> contains the date when the app was installed on the user's device, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. <code>appName</code> contains the name of the app and <code>appRelease</code> contains a string identifying the release (example: "4.9.1").<br>This claim is intended to help partners detect fraudulent use cases.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/account" req="OPTIONAL" %}</td><td>Returns a JSON object with 3 members: <code>activationDate</code> contains the date when the account was last activated (enrolled or unblocked), represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. <code>activationMechanism</code> contains a string identifying the way this account was created. Possible values are "CARD_READER" (enrollment via a physical reading of the ID document chip), "CONTACT_LESS" (enrollment via a NFC reading of the ID document) or "ID_PROVIDER" (enrollment via a trusted partner, i.e. a bank).<br>This claim is intended to help partners detect fraudulent use cases.</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="http://itsme.services/v2/<br>claim/transaction_ip" req="OPTIONAL" %}</td><td>Returns the IP address of the smartphone approving the transaction.<br>This claim is intended to help partners detect fraudulent use cases.</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="request_uri" req="OPTIONAL" %}</td>
      <td>A URL using the https scheme referencing a resource containing a JWT whose claims are the request parameters. The <code>request_uri</code> parameter is used to secure parameters in the Authorization Request from tainting or inspection when sending the request to the itsme® Authorization Endpoint.<br><br>If the <code>request_uri</code> parameter is used, the JWT MUST be signed and MUST contain the claims <code>iss</code> (issuer) and <code>aud</code> (audience) as members. The <code>iss</code> value SHOULD be your <code>client_id</code>. The <code>aud</code> value SHOULD be set to <code>https://idp.[e2e/prd].itsme.services/v2</code>. The JWT MUST also be encrypted and more precisely: it MUST be signed then encrypted, with the result being a Nested JWT (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).<br><br>The following restrictions apply to request URIs:
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
      <td>It represents the request as a JWT whose Claims are the request parameters. The <code>request</code> parameter is used to secure parameters in the Authorization Request from tainting or inspection when sending the request to the itsme® Authorization Endpoint.<br><br>If the <code>request</code> parameter is used, the JWT MUST be signed and MUST contain the claims <code>iss</code> (issuer) and <code>aud</code> (audience) as members. The <code>iss</code> value SHOULD be your <code>client_id</code>. The <code>aud</code> value SHOULD be set to <code>https://idp.[e2e/prd].itsme.services/v2</code>. The JWT MUST also be encrypted and more precisely: it MUST be signed then encrypted, with the result being a Nested JWT (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).</td>
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