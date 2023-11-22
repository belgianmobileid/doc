---

layout: OIDCviaPlatform
title: Auth0
permalink: auth0/
nav_order: 5
toc_list: true

---

## What is Auth0?

Auth0 is known for its simplicity and ease of integration. It provides a variety of SDKs and pre-built integrations, making it easy for developers to incorporate authentication and identification into their applications.

## Prerequisites

* Auth0 account and/or relevant subscription
* Your Client ID, also known as Partner code, provided by itsme®.
* Your Service code provided by itsme®.
* Client secret provided by itsme®
* redirect_uri you will be redirecting the user to. In Auth0, it is a generated callback url (please, provide it to onboarding@itsme-id.com)

## Configuration between Auth0 and itsme®
1. Log in Auth0, go to Authentication => Enterprise => OpenID Connect => Create Connection
2. Populate the details with the parameters you got from itsme®:

| Parameter | Value |
| --- | --- |
| issuer url | <button type="button"><a href="https://belgianmobileid.github.io/doc/authentication/#itsme-discovery-document" target="blank">see our technical documentation</a></button>   |
| back channel | response_type=code |
| ClientID | Your **Client ID**, also known as **Partner code** |
| Client Secret | Your **client_secret** |
| scopes | openid profile email address eid service:YOURSERVICECODE |
| callback url | pass generated callback url to onboarding@itsme-id.com |

All other fields can be left on the default settings.

3. Save and return to Authentication => Enterprise => OpenID Connect, click "Try" under newly created connection to test the flow.
4. Under User Management, find test user and see raw json with requested data.

## Reference
<button type="button"><a href="https://auth0.com/docs/authenticate/identity-providers/enterprise-identity-providers/oidc" target="blank">Auth0 guide to OpenID Connect Identity Provider</a></button>