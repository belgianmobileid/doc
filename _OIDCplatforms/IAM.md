---

layout: OIDCviaPlatform
title: IAM
permalink: IAM/
nav_order: 4
toc_list: true

---


# What is an IAM platform?

An Identity and Access Management platform is a service that allows companies to manage identities in a centralized way. These identities can be collected from different parties (Identity Providers) and different ways can be offered to end-users to prove their identity (password, itsme...).

# Integrating itsme® on an IAM platform

Most IAM platforms allow for the usage of different Identity Providers (IdP), either as pre-configured partners or via standardized communication protocols to be configured with the right parameters.

OpenId Connect is the most common of those protocols and the one that itsme® strictly adheres to, which means that itsme® can be used as an IdP on pretty much any IAM platform.
However, depending on the way each platform implemented the protocol and on the configurability they offer, not all features of itsme® will always be available. In general, we outline 3 attention points:

**1) Type of service from itsme®:** In general, only Identification and Authentication are available through an IAM platform. The Confirmation service from itsme® implies not only data communication from itsme® to the platform, but also communication from the platform to itsme® of the content to be confirmed. IAM platforms in general are not equipped for bi-directional communication.

**2) Authentication Method:** itsme® allows partners to authenticate via 2 of the authentication specified by OpenId Connect: private_key_jwt is the most secure way, relying on asymmetric cryptography, while client_secret_post relies on symmetric cryptography. Most platforms will only support integration with itsme® through the Client Secret option either because they don't support private_key_jwt at all or because they have only basic support for it, not allowing signed and encrypted tokens at each step of the flow.

**3) Available attributes:** While itsme® offers a broad range of identity attributes for each user (called "claims" in OIDC), not all IAM platforms allow you to take advantage of all claims:
- OIDC makes use of the concept of "scopes", regrouping a predefined set of claims. Some platforms only allow to request scopes, not individual claims, making it impossible to retrieve claims that are not part of a scope.
- Most of our claims are returning a string value ("Name":"John Smith") but some are returning a structured JSON object, like address: {"street_adress":"Station Street 34", "postal_code":"12345"}. Some platforms are only able to handle simple strings, not objects.

Here is a table of all the itsme® claims with their respective scope (if any) and format. See <a href="https://belgianmobileid.github.io/doc/authentication/#authorization-request">https://belgianmobileid.github.io/doc/authentication/#authorization-request</a> for more details about each of these claims.

<table>
  <tbody>
    <tr>
      <th>Claim</th>
      <th>Scope</th>
      <th>Format</th>
    </tr>
    <tr>
      <td>name</td>
      <td>profile</td>
      <td>string</td>
    </tr>
    <tr>
      <td>given_name</td>
      <td>profile</td>
      <td>string</td>
    </tr>
    <tr>
      <td>family_name</td>
      <td>profile</td>
      <td>string</td>
    </tr>
    <tr>
      <td>birthdate</td>
      <td>profile</td>
      <td>string</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/birthdate_as_string</td>
      <td>/</td>
      <td>string</td>
    </tr>
    <tr>
      <td>gender</td>
      <td>profile</td>
      <td>string</td>
    </tr>
    <tr>
      <td>locale</td>
      <td>profile</td>
      <td>string</td>
    </tr>
    <tr>
      <td>picture</td>
      <td>profile</td>
      <td>string</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/physical_person_photo</td>
      <td>/</td>
      <td>string</td>
    </tr>
    <tr>
      <td>email</td>
      <td>email</td>
      <td>string</td>
    </tr>
    <tr>
      <td>email_verified</td>
      <td>email</td>
      <td>string</td>
    </tr>
    <tr>
      <td>phone_number</td>
      <td>phone</td>
      <td>string</td>
    </tr>
    <tr>
      <td>phone_number_verified</td>
      <td>phone</td>
      <td>string</td>
    </tr>
    <tr>
      <td>address</td>
      <td>address</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/claim_citizenship</td>
      <td>/</td>
      <td>string</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/claim_citizenship_as_iso</td>
      <td>/</td>
      <td>string</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/place_of_birth</td>
      <td>/</td>
      <td>string</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/BEeidSn</td>
      <td>eid</td>
      <td>string</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/BENationalNumber</td>
      <td>eid</td>
      <td>string</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/claim_device</td>
      <td>/</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/transaction_info</td>
      <td>/</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/validityFrom</td>
      <td>/</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/validityTo</td>
      <td>/</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/verificationDate</td>
      <td>address</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/IDDocumentSN</td>
      <td>/</td>
      <td>string</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/IDDocumentType</td>
      <td>/</td>
      <td>string</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/IDIssuingCountry</td>
      <td>/</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/issuance_locality</td>
      <td>/</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/app</td>
      <td>/</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/account</td>
      <td>/</td>
      <td>JSON object</td>
    </tr>
    <tr>
      <td>http://itsme.services/v2/claim/transaction_ip</td>
      <td>/</td>
      <td>string</td>
    </tr>
   </tbody>
</table>

# List of platforms

Based on past experiences, we put together a list of the main platforms we encountered with the characteristics we noticed for each of them. This table is given without any formal guarantee and some of this information might be outdated when you read it.

<table>
  <tbody>
    <tr>
      <th>Platform</th>
      <th>Supported claims</th>
      <th>Note</th>
    </tr>
    <tr>
      <td>MS Azure AD B2C</td>
      <td>String only</td>
      <td>The GUI "User Flow" method only gives access to sub, name and email. Other claims require to use the Identity Experience Framework with custom policies, configured via complex XML files. Client Secret only.</td>
    </tr>
    <tr>
      <td>ForgeRock Identity Platform</td>
      <td>All</td>
      <td>Complete support of jwt_private_key and Client Secret</td>
    </tr>
    <tr>
      <td>Amazon Cognito</td>
      <td>Scopes only</td>
      <td>Client Secret only</td>
    </tr>
    <tr>
      <td>Auth0</td>
      <td>Scopes only</td>
      <td>Client Secret only</td>
    </tr>
    <tr>
      <td>Okta</td>
      <td>Scopes only</td>
      <td>Client Secret only</td>
    </tr>
  </tbody>
</table>
