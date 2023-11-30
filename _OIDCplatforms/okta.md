---

layout: OIDCviaPlatform
title: Okta
permalink: okta/
nav_order: 5
toc_list: true

---

<a href="https://okta.com" class="noLine"><img src="/doc/assets/logo_Okta.svg" alt="Okta logo" width=150></a>

[Customer Identity Cloud](https://www.okta.com/customer-identity/) is the Customer IAM product from Okta.
It can be configured to use itsme® as an Identity Provider via the OpenID Connect standardized protocol.

# Prerequisite

Contact <a href="mailto:onboarding@itsme-id.com">onboarding@itsme-id.com</a> to request the creation of your account, specifying that your authentication method will be "Client Secret". You will then receive a Client ID and a Client Secret (= password, handle with care) that will be needed in the Okta configuration. You will also receive a Service Name to be included in your config.

# Add an ID provider

The first step is to add a new Identity Provider in your Okta portal. This can be done by selecting the "Security" tab, then "Identity Providers" and clicking "Add identity provider".

![Add ID Provider](/doc/public/images/Okta_AddIDP.png)

On the next screen, choose "OpenID Connect IdP".
After that, you need to fill in your IdP configuration:

![General Settings](/doc/public/images/Okta_ConfigIDP_1.png)

* Name can be anything, "itsme" is a good example.
* IdP Usage depends on your use case.
* Scopes will depend on which attributes you need to receive, but must contain at least <code>openid</code> and <code>service:servicename</code>
* Authentication type should be Client Secret
* Client ID and Client Secret are the one you received from Customer Care
* Enable signed request and PKCE should be supported as well, but are not mandatory

![General Settings](/doc/public/images/Okta_ConfigIDP_2.png)

The endpoints to be configured have to be the ones described in our <a href="https://oidc.prd.itsme.services/clientsecret-oidc/csapi/v0.1/.well-known/openid-configuration">Discovery Document</a>:

* Issuer: https://oidc.[e2e/prd].itsme.services/clientsecret-oidc/csapi/v0.1
* Authorization endpoint: https://oidc.[e2e/prd].itsme.services/clientsecret-oidc/csapi/v0.1/connect/authorize
* Token endpoint: https://oidc.[e2e/prd].itsme.services/clientsecret-oidc/csapi/v0.1/connect/token
* JWKS endpoint: https://oidc.[e2e/prd].itsme.services/clientsecret-oidc/csapi/v0.1/.well-known/jwks
* Userinfo endpoint should be left empty!

![General Settings](/doc/public/images/Okta_ConfigIDP_3.png)

The Authentication Settings will depend on your use case. In the example above, the reconciliation of a connecting user with a known user in Okta DB is done via their Belgian National Register Number, but the ID key could be an email or any other attribute you see fit.






