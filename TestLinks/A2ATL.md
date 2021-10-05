---
layout: page
title: App to App test links
permalink: TestLinks/
nav_exclude: true

---

# Requested data

The login links request all data available.
The confirm links request a basic set of data (profile, eid, address, email and phone number).

Please note also the Confirm links are only valid for a limited amount of time. Under some occasions, the JWKSet of the test partner is re-generated, making the request object in the links below obsolete. To re-create new ones, please consult <a href="https://confluence.belgianmobileid.be/display/ITSME/How+to+create+A2A+Confirm+links" target="blank">How to create A2A confirm links</a> (hosted on BMID Confluence).

# Links

## UAT

### Login
<a href="https://uatmerchant.itsme.be/oidc/authorization?redirect_uri=https://core-emulators-ssl.default-clu01.mgmt.belgianmobileid.be/openidclient/uat_OIDC_TEST1/authz_cb&response_type=code&client_id=OIDC_TEST1&scope=openid+service:OIDC_TEST1_LOGIN+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login+consent&max_age=1&claims=%7B%22userinfo%22%3A%7B%22tag%3Asixdots.be%2C2020-03%3Aclaim_birthdate_as_string%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_nationality%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_eid%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_city_of_birth%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_country_of_birth%22%3Anull%2C%22tag%3Asixdots.be%2C2017-05%3Aclaim_device%22%3Anull%2C%22tag%3Asixdots.be%2C2017-05%3Aclaim_transaction_info%22%3Anull%2C%22tag%3Asixdots.be%2C2017-05%3Aclaim_photo%22%3Anull%7D%7D" target="blank">UAT - OIDC V1 login</a>
      
<a href="https://idp.uat.itsme.services/v2/authorization?response_type=code&client_id=OIDC_TEST1&redirect_uri=https://core-emulators-ssl.default-clu01.mgmt.belgianmobileid.be/openidclient/uat_OIDC_TEST1_I18N/authz_cb_withPicture&scope=openid+service:OIDC_TEST1_LOGIN_I18N+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login&max_age=1&claims=%7B%22userinfo%22%3A%7B%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fclaim_citizenship%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fplace_of_birth%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fphysical_person_photo%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fbirthdate_as_string%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fclaim_device%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Ftransaction_info%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FvalidityFrom%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FvalidityTo%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FIDDocumentSN%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FIDDocumentType%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fclaim_luxtrust_ssn%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FBENationalNumber%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fclaim_nl_bsn%22%3Anull%7D%7D" target="blank">UAT - OIDC V2 login</a>

### Confirm links
<a href="https://uatmerchant.itsme.be/oidc/authorization?response_type=code&client_id=OIDC_TEST1&redirect_uri=https%3A%2F%2Fcore-emulators-ssl.default-clu01.mgmt.belgianmobileid.be%2Fopenidclient%2Fuat_OIDC_TEST1%2Fauthz_cb&scope=openid+service%3AOIDC_TEST1_APPROVAL+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login+consent&max_age=1&claims=%7B%22userinfo%22%3A%7B%22name%22%3A%7B%22essential%22%3Atrue%7D%7D%7D&request_uri=https://belgianmobileid.github.io:443/slate/RequestObject_UAT_OIDCv1.json" target="blank">UAT - OIDC V1 confirm</a>

<a href="https://idp.uat.itsme.services/v2/authorization?response_type=code&client_id=OIDC_TEST1&redirect_uri=https%3A%2F%2Fcore-emulators-ssl.default-clu01.mgmt.belgianmobileid.be%2Fopenidclient%2Fuat_OIDC_TEST1_I18N%2Fauthz_cb_withPicture&scope=openid+service%3AOIDC_TEST1_APPROVAL_I18N+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login+consent&max_age=1&claims=%7B%22userinfo%22%3A%7B%22name%22%3A%7B%22essential%22%3Atrue%7D%7D%7D&request_uri=https://belgianmobileid.github.io:443/slate/RequestObject_UAT_OIDCv2.json" target="blank">UAT - OIDC V2 confirm</a>

### Azure B2C ClientSecret

<a href="https://itsmedigitalidb2cuat.b2clogin.com/itsmedigitalidb2cuat.onmicrosoft.com/oauth2/v2.0/authorize?p=B2C_1_itsme_test&client_id=97c86891-c64f-41e6-aeb5-fa73b6805959&nonce=defaultNonce&redirect_uri=https%3A%2F%2Fjwt.ms&scope=openid&response_type=id_token&prompt=login" target="blank">UAT - Azure B2C</a>

    
## E2E

### Login

<a href="https://e2emerchant.itsme.be/oidc/authorization?redirect_uri=https://core-emulators-ssl.default-clu01.mgmt.belgianmobileid.be/openidclient/e2e_OIDC_TEST1/authz_cb&response_type=code&client_id=OIDC_TEST1&scope=openid+service:OIDC_TEST1_LOGIN+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login+consent&max_age=1&claims=%7B%22userinfo%22%3A%7B%22tag%3Asixdots.be%2C2020-03%3Aclaim_birthdate_as_string%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_nationality%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_eid%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_city_of_birth%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_country_of_birth%22%3Anull%2C%22tag%3Asixdots.be%2C2017-05%3Aclaim_device%22%3Anull%2C%22tag%3Asixdots.be%2C2017-05%3Aclaim_transaction_info%22%3Anull%2C%22tag%3Asixdots.be%2C2017-05%3Aclaim_photo%22%3Anull%7D%7D" target="blank">E2E - OIDC V1 login</a>

<a href="https://idp.e2e.itsme.services/v2/authorization?response_type=code&client_id=OIDC_TEST1&redirect_uri=https://core-emulators-ssl.default-clu01.mgmt.belgianmobileid.be/openidclient/e2e_OIDC_TEST1_I18N/authz_cb_withPicture&scope=openid+service:OIDC_TEST1_LOGIN_I18N+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login+consent&max_age=1&claims=%7B%22userinfo%22%3A%7B%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fclaim_citizenship%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fplace_of_birth%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fphysical_person_photo%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fbirthdate_as_string%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fclaim_device%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Ftransaction_info%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FvalidityFrom%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FvalidityTo%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FIDDocumentSN%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FIDDocumentType%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fclaim_luxtrust_ssn%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2FBENationalNumber%22%3Anull%2C%22http%3A%5C%2F%5C%2Fitsme.services%5C%2Fv2%5C%2Fclaim%5C%2Fclaim_nl_bsn%22%3Anull%7D%7D" target="blank">E2E - OIDC V2 login</a>
      
### Confirm

<a href="https://e2emerchant.itsme.be/oidc/authorization?response_type=code&client_id=OIDC_TEST1&redirect_uri=https%3A%2F%2Fcore-emulators-ssl.default-clu01.mgmt.belgianmobileid.be%2Fopenidclient%2Fe2e_OIDC_TEST1%2Fauthz_cb&scope=openid+service%3AOIDC_TEST1_APPROVAL+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login+consent&max_age=1&claims=%7B%22userinfo%22%3A%7B%22name%22%3A%7B%22essential%22%3Atrue%7D%7D%7D&request_uri=https://belgianmobileid.github.io:443/slate/RequestObject_E2E_OIDCv1.json" target="blank">E2E - OIDC V1 confirm</a>

<a href="https://idp.e2e.itsme.services/v2/authorization?response_type=code&client_id=OIDC_TEST1&redirect_uri=https%3A%2F%2Fcore-emulators-ssl.default-clu01.mgmt.belgianmobileid.be%2Fopenidclient%2Fe2e_OIDC_TEST1_I18N%2Fauthz_cb_withPicture&scope=openid+service%3AOIDC_TEST1_APPROVAL_I18N+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login+consent&max_age=1&claims=%7B%22userinfo%22%3A%7B%22name%22%3A%7B%22essential%22%3Atrue%7D%7D%7D&request_uri=https://belgianmobileid.github.io:443/slate/RequestObject_E2E_OIDCv2.json" target="blank">E2E - OIDC V2 confirm</a>

### Azure B2C ClientSecret

<a href="https://itsmedigitalidb2ce2e.b2clogin.com/itsmedigitalidb2ce2e.onmicrosoft.com/oauth2/v2.0/authorize?p=B2C_1_itsme_userflow&client_id=e3ed773e-b123-46a3-86ba-721c37a7850d&nonce=defaultNonce&redirect_uri=https%3A%2F%2Fjwt.ms&scope=openid&response_type=id_token&prompt=login" target="blank">E2E - Azure B2C</a>

## PRD

### Login

<a href="https://merchant.itsme.be/oidc/authorization?redirect_uri=https://core-emulators-ssl.default-clu01.mgmt.belgianmobileid.be/openidclient/prod_OIDC_TEST1/authz_cb&response_type=code&client_id=OIDC_TEST1&scope=openid+service:OIDC_TEST1_LOGIN+profile+eid+phone+email+address&state=anystate&nonce=anonce&prompt=login&max_age=1&claims=%7B%22userinfo%22%3A%7B%22tag%3Asixdots.be%2C2020-03%3Aclaim_birthdate_as_string%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_nationality%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_eid%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_city_of_birth%22%3Anull%2C%22tag%3Asixdots.be%2C2016-06%3Aclaim_country_of_birth%22%3Anull%2C%22tag%3Asixdots.be%2C2017-05%3Aclaim_device%22%3Anull%2C%22tag%3Asixdots.be%2C2017-05%3Aclaim_transaction_info%22%3Anull%2C%22tag%3Asixdots.be%2C2017-05%3Aclaim_photo%22%3Anull%7D%7D" target="blank">PRD - OIDC V1 login</a>
      
<a href="https://idp.prd.itsme.services/v2/authorization?response_type=code&client_id=OIDC_TEST1&redirect_uri=https://core-emulators-ssl.default-clu01.mgmt.belgianmobileid.be/openidclient/prod_OIDC_TEST1_I18N/authz_cb_withPicture&scope=openid+service:OIDC_TEST1_LOGIN_I18N+profile+eid+phone+email+address&state=anystate&nonce=anonce&prompt=login&max_age=1&claims=%7B%22userinfo%22%3A%7B%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2FBENationalNumber%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2Fclaim_citizenship%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2Fplace_of_birth%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2Fphysical_person_photo%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2Fbirthdate_as_string%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2Fclaim_device%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2Ftransaction_info%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2FvalidityFrom%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2FvalidityTo%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2FIDDocumentSN%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2FIDDocumentType%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2Fclaim_luxtrust_ssn%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2FBENationalNumber%22%3Anull%2C%22http%3A%2F%2Fitsme.services%2Fv2%2Fclaim%2Fclaim_nl_bsn%22%3Anull%7D%7D" target="blank">PRD - OIDC V2 login</a>

### Confirm

<a href="https://merchant.itsme.be/oidc/authorization?response_type=code&client_id=OIDC_TEST1&redirect_uri=https%3A%2F%2Fcore-emulators-ssl.default-clu01.mgmt.belgianmobileid.be%2Fopenidclient%2Fprod_OIDC_TEST1%2Fauthz_cb&scope=openid+service%3AOIDC_TEST1_APPROVAL+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login+consent&max_age=1&claims=%7B%22userinfo%22%3A%7B%22name%22%3A%7B%22essential%22%3Atrue%7D%7D%7D&request_uri=https://belgianmobileid.github.io:443/slate/RequestObject_PRD_OIDCv1.json" target="blank">PRD - OIDC V1 Confirm</a>

<a href="https://idp.prd.itsme.services/v2/authorization?response_type=code&client_id=OIDC_TEST1&redirect_uri=https%3A%2F%2Fcore-emulators-ssl.default-clu01.mgmt.belgianmobileid.be%2Fopenidclient%2Fprod_OIDC_TEST1_I18N%2Fauthz_cb_withPicture&scope=openid+service%3AOIDC_TEST1_APPROVAL_I18N+profile+phone+email+address+eid&state=anystate&nonce=anonce&prompt=login+consent&max_age=1&claims=%7B%22userinfo%22%3A%7B%22name%22%3A%7B%22essential%22%3Atrue%7D%7D%7D&request_uri=https://belgianmobileid.github.io:443/slate/RequestObject_PRD_OIDCv2.json" target="blank">PRD - OIDC V2 Confirm</a>

### Azure B2C ClientSecret

<a href="https://itsmedigitalidb2cprd.b2clogin.com/itsmedigitalidb2cprd.onmicrosoft.com/oauth2/v2.0/authorize?p=B2C_1_itsme_prd&client_id=16addb8f-1d28-476c-b2f5-f65a8ff660fe&nonce=defaultNonce&redirect_uri=https%3A%2F%2Fjwt.ms%2F&scope=openid&response_type=id_token&prompt=login" target="blank">PRD - Azure B2C</a>
