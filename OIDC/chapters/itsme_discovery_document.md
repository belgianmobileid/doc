## itsme Discovery Document

{% tabs Discovery %}

{% tab Discovery Public- and private-key %}

<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/.well-known/openid-configuration</code></b>

To simplify implementations and increase flexibility, <a href="https://openid.net/specs/openid-connect-discovery-1_0.html" target="blank">OpenID Connect allows the use of a Discovery Document</a>, a JSON document containing key-value pairs which provide details about itsme configuration, such as the 

<tabul>
  <tabli>Authorization, Token and userInfo Endpoints</tabli>
  <tabli>Supported claims</tabli>
  <tabli>...</tabli>
</tabul>

{% endtab %}

{% tab Discovery Secret key %}

<b><code>GET https://idp.<i><b>[e2e/prd]</b></i>.itsme.services/v2/.well-known/openid-configuration</code></b>

If your onboarding happened before the 25th of June 2025, then URL was:<br>
<b><code>GET https://oidc.<i><b>[e2e/prd]</b></i>.itsme.services/clientsecret-oidc/csapi/v0.1/.well-known/openid-configuration</code></b>

To simplify implementations and increase flexibility, <a href="https://openid.net/specs/openid-connect-discovery-1_0.html" target="blank">OpenID Connect allows the use of a Discovery Document</a>, a JSON document containing key-value pairs which provide details about itsme configuration, such as the

<tabul>
  <tabli>Authorization, Token and userInfo Endpoints</tabli>
  <tabli>Supported claims</tabli>
  <tabli>...</tabli>
</tabul>

{% endtab %}

{% endtabs %}



