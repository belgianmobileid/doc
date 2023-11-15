---
layout: OIDCviaPlatform
title: Forgerock | Ping Identity
permalink: forgerock/
nav_order: 5
nav_exclude: true

---
# What is Forgerock | Ping Identity?

Forgerock & Ping Identity's software provides federated identity management and self-hosted identity access management to web identities via attribute based access controls. They offer the industry's only end-to-end, AI-driven platform purpose-built for all identities and for any environment — on-prem, multi-cloud, or hybrid.

## Prerequisites

This integration relies on the ForgeRock Social Provider Handler Node which is available in ForgeRock Platform 7 and assumes integration between AM and IDM has been configured. Please, refer to <button type="button"><a href="https://backstage.forgerock.com/docs/platform/7.2/platform-self-service/social-registration.html" target="blank">Forgerock Social Authentication chapter</a></button>.

* A Forgerock account/subscription. If you don't have a subscription, please contact Forgerock at https://www.forgerock.com/contact
* A Forgerock tenant that is linked to your forgerock subscription.
* Your Client ID, also known as Partner code, provided by itsme®.
* Your Service code provided by itsme®.
* Your public jwkset_uri (please, provide it to onboarding@itsme-id.com) or the secret provided by itsme® (in case of client secret)
* Your redirect_uri you will be redirecting the user to (please, provide it to onboarding@itsme-id.com), e.g. https://openam-itsme-demo.forgeblocks.com/am

## Scenario

![itsme-Forgerock schema](_OIDCplatforms/Forgerock/forgerock.md)

1. On your website or application, include the Log in with itsme® button by adapting in
the Forgerock user flow. The interaction flow starts when the user clicks on this
button.
2. Forgerock starts the OpenID connect flow by sending an Authorize request to the
itsme® API. <button type="button"><a href="https://belgianmobileid.github.io/doc/authentication/#itsme-discovery-document" target="blank">A well-known endpoint</a></button>  is pre-configured within Forgerock ecosystem & contains information about the endpoints.
3. itsme® environment redirects the user to the itsme® identify yourself page, allowing
the user to fill in their phone number.
4. itsme® receives the phone number from the user and validates it.
5. If the phone number belongs to an active itsme® user, an Action is created for the
itsme® app.
6. The user opens the itsme® app, checks the request, and confirms the action.
7. The app informs the itsme® environment the action has been confirmed.
8. The itsme® environment returns the authorization code to Forgerock.
9. Using the authorization code, Forgerock makes a token request.
10. The itsme® environment checks the token request, and if still valid, returns the OAuth
access token and the ID token containing the requested user information.
11. Finally, the user is redirected to the redirect_uri as an authenticated user.

## Configuration between Forgerock and itsme®
### Step 1: Setup itsme® to ForgeRock AM
1. Log in to the forgerock Identity cloud
2. Go to “native consoles” > “access management”
3. Go to “services” > “social identity provider service” > “secondary configuration”
4. Select itsme®
5. Populate the details with the parameters you got from itsme®:
(NOTE: Forgerock automatically populates these fields with production endpoints.
Initially, these need to be changed to E2E endpoints in order to function.)

| Parameter | Value |
| --- | --- |
| ClientID | Your **Client ID**, also known as **Partner code** |
| Client Secret | Your **client_secret** (leave empty in case of public-private key pair, i.e. jwkset_uri) |
| Authentication Endpoint URL | "https://idp.e2e.itsme.services/v2/authorization" |
| Token Endpoint | "https://idp.e2e.itsme.services/v2/token" |
| User Profile Service URL | "https://idp.e2e.itsme.services/v2/userinfo" |
| RedirectURI | your redirectURI <br>_**NOTE:** for itsme® to function in production, the Forgerock tenant needs to be installed with a custom domain (https://backstage.forgerock.com/docs/idcloud/latest/realms/custom-domains.html#set_up_a_custom_domain_in_identity_cloud) and an OV/EV certificate. Please contact Forgerock support to make sure this is installed on your tenant._ |
| OAuth Scopes | openid profile email service:YOURSERVICECODE |
| Client Authentication Method | _ENCRYPTED_PRIVATE_KEY_JWT_ |
| PKCE method | S256 |
| Request Parameter JWT Option | _NONE_ |
| ACR Values | N/A |
| Well Known Endpoint | _https://idp.e2e.itsme.services/v2/.well-known/openid-configuration_ |
| Request Object Audience | "https://idp.e2e.itsme.services/v2/authorization" |
| Issuer | https://idp.e2e.itsme.services/V2/jwkSet |

All other fields can be left on the default settings from Forgerock.

6. Select ‘itsme® profile normalization’ in the transform script drop-down menu.

### Step 2: Define your itsme® journey

Go to Journeys and select itsme® to build your workflow. There is already a custom flow ready
for you to use with itsme®. By default, it includes a username/password flow with itsme® added
as a secondary option, but this can be adapted as you wish.
![itsme tenant tree](_OIDCplatforms/Forgerock/tree.png)
