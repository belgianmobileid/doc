## Userinfo Request

<b><code>GET https://idp.[e2e/prd].itsme.services/v2/userinfo</code></b>

The UserInfo Endpoint returns previously consented user profile information to your application. In other words, if the required claims are not returned in the ID Token, you can obtain the additional claims by presenting the access token to the itsme® UserInfo Endpoint. This is achieved by sending a HTTP GET request to the Userinfo Endpoint, passing the access token value in the Authorization header using the Bearer authentication scheme.

### Response

<code>200</code> <code>application/json</code>

The UserInfo Response is represented as a signed and encrypted JWT. So, before being able to extract the claims you will have to decrypt and verify the signature.

### Example

***Request***

```http
GET /userinfo HTTP/1.1
Host: server.example.com
Authorization: Bearer SlAV32hkKG
```

***Response***

This is a response example containing all possible claims for a Belgian account:

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "http://itsme.services/v2/claim/validityFrom": {

