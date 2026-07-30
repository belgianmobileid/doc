## Revoke Request

{% tabs RevokeRequest %}

{% tab RevokeRequest Public- and private-key %}

Not applicable.

{% endtab %}

{% tab RevokeRequest Secret key %}

<b><code>POST https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/v2/connect/revoke</code></b>

The Revocation Endpoint enables your application to notify itsme that a previously obtained access token is no longer needed and MUST be revoked.

### Parameters

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="token" req="REQUIRED" %}</td>
      <td>The <code>access_token</code> previously obtained that you want to revoke.</td>
    </tr>
    <tr>
      <td>{% include parameter.html name="token_type_hint" req="OPTIONAL" %}</td>
      <td>A hint about the type of the token submitted for revocation. You MAY pass this parameter in order to help itsme to optimize the token lookup. If the server is unable to locate the token using the given hint, it MUST extend its search across all of its supported token types. If used, this is set to <code>access_token</code> because itsme API don't support refresh tokens.</td>
    </tr>
  </tbody>
</table>

### Response

<code>200</code> 

itsme responds with HTTP status code 200 if the token has been revoked successfully or if the client submitted an invalid token.

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



