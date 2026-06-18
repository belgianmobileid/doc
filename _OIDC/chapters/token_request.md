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

<b><code>POST https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/token</code></b>

If your onboarding happened before the 25th of June 2025, then URL was:<br>
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

Example of a decrypted id_token:

```
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

Example of a decrypted id_token:

```
{
	"sub": "6g2k9rgglem2dttw5d51ulkxpv24phwatiu6",
	"aud": "WXw9DMqkEv",
	"birthdate": "1974-10-23",
	"gender": "male",
	"name": "John Ronald R Tolkien",
	"iss": "https://oidc.prd.itsme.services/v2",
	"nonce": "5468798645321",
	"nbf": 1699538107,
	"exp": 1699538407,
	"iat": 1699538107
}
```

{% endtab %}

{% endtabs %}

<a id="UserInfoReq"></a>

