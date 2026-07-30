## UserInfo Request

{% tabs UserInfoRequest %}

{% tab UserInfoRequest Public- and private-key %}

<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/userinfo</code></b>

The UserInfo Endpoint returns previously consented user profile information to your application. In other words, if the required claims are not returned in the ID Token, you can obtain the additional claims by presenting the access token to the itsme UserInfo Endpoint. This is achieved by sending a HTTP GET request to the Userinfo Endpoint, passing the access token value in the Authorization header using the Bearer authentication scheme.

This is illustrated in the example below.


### Response

<code>200</code> <code>application/json</code>

The UserInfo Response is represented as a signed and encrypted JWT. So, before being able to extract the claims you will have to decrypt and verify the signature (refer to <a href="https://belgianmobileid.github.io/doc/JOSE/" target="blank">this page</a> for more information).


{% endtab %}

{% tab UserInfoRequest Secret key %}

<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/userinfo</code></b>

If your onboarding happened before the 25th of June 2025, then URL was:<br>
<b><code>GET https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/clientsecret-oidc/csapi/v0.1/connect/userinfo</code></b>

The UserInfo Endpoint returns previously consented user profile information to your application. In other words, if the required claims are not returned in the ID Token, you can obtain the additional claims by presenting the access token to the itsme UserInfo Endpoint. This is achieved by sending a HTTP GET request to the Userinfo Endpoint, passing the access token value in the Authorization header using the Bearer authentication scheme.

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
	"iss": "https://oidc.[e2e/prd].itsme.services/v2",
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
		"appName": "be.bmid.itsme.[e2e/prd]",
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
	"picture": "https://oidc.[e2e/prd].itsme.services/v2/picture",
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



