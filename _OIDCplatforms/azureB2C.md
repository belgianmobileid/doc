---

layout: OIDCviaPlatform
title: Azure B2C
permalink: azureB2C/
nav_exclude: false

---


# What is Azure Active Directory B2C ?

Azure Active Directory B2C (Azure AD B2C) is an identity management service that enables custom control of how your customers sign up, sign in, and manage their profiles when using your iOS, Android, .NET, single-page (SPA), and other applications. 

Azure AD B2C uses standards-based authentication protocols including OpenID Connect, OAuth 2.0, and SAML. It integrates with most modern applications and commercial off-the-shelf software. 

You can configure Azure AD B2C to allow users to sign in to your application with credentials from itsme®, as we are supporting the OpenID Connect protocol. By integrating with us, you can offer your consumers the ability to sign in with their existing itsme® accounts, without having to create a new account just for your application.

On the sign-up or sign-in page, Azure AD B2C presents a list of external identity providers the user can choose for sign-in. Once they select one of the external identity providers, itsme® for example, they're redirected to the itsme® to complete the sign in process. After the user successfully signs in, they're returned to Azure AD B2C for authentication of the account in your application.

# API reference

To see how to add itsme® in Azure AD B2C, always refer to <button type="button"><a href="https://docs.microsoft.com/en-us/azure/active-directory-b2c/partner-itsme" target="blank">Configure itsme® OpenID Connect (OIDC) with Azure Active Directory B2C</a></button>

Whether your set-up is via user flow (normally, via graphical user-interface (GUI) on Azure portal) or Identity Experience Framework (IEF), custom policies, configured via .xml files, will depend what ID data you wish (and entitled by commercial & legal agreements) to receive.

As of 2023, Azure B2C technical limitation is no possibility to process JSON objects, only strings. The following claims returned by itsme® are strings or boolean data type:

```
claims returned as string or boolean (expected to be processed by Azure B2C)
  "sub": "er8xm42w3u4ue6xvez8s3xr3jijnb4fugmmc",
  "birthdate": "1985-01-02",
	"http://itsme.services/v2/claim/claim_citizenship_as_iso": "BEL",
	"gender": "female",
	"http://itsme.services/v2/claim/IDDocumentType": "I",
	"http://itsme.services/v2/claim/claim_citizenship": "Belg",
	"locale": "EN",
	"email": "test@itsme.be",
	"name": "Joke Cookie",
	"http://itsme.services/v2/claim/IDDocumentSN": "581721097415",
	"phone_number": "+32 493310088",
	"http://itsme.services/v2/claim/BEeidSn": "581721097415",
	"family_name": "Cookie",
	"email_verified": false,
	"http://itsme.services/v2/claim/BENationalNumber": "85010244229",
	"phone_number_verified": true,
	"given_name": "Joke",
	"picture": "https://oidc.e2e.itsme.services/clientsecret-oidc/csapi/v0.1/picture"
```

User flow is limited to sub, names & email. While IEF will allow you to process the rest of ID Data listed above in data type string or boolean.

## User Flows
User flows is a portal (GUI) configurable flow, which is based on built-in user attributes (values collected on sign up) and application claims, which are values about the user, returned to the application in the token. One can create custom attributes, but unfortunately Azure B2C does not process any claims from itsme®, except the ones mapped during general idp setup (idp claims mapping), i.e. sub, given_name, family_name, email. Only those were returned consistently during testing of 2023.

End-user will see in the app request to approve all data which is mentioned on the scope, e.g. if full scope defined => all data will be displayed to approve, but Azure B2C will process and return only mapped claims, i.e. sub, given_name, family_name, emails (returned as string collection).

## Identity Experience Framework (IEF) or custom policy
IEF is advanced method to configure Azure B2C via .xml files.
Due to Azure B2C limitations, JSON Objects returned by itsme® can not be processed or transformed by Azure B2C, thus one could ask & receive data which is returned as strings or booleans only:

```
IEF decoded token example
{
  "alg": "RS256",
  "kid": "YHLNSahdjm68w79195aoKEPkwzv3R1MNHyy_xm52ioQ",
  "typ": "JWT"
}.{
  "sub": "902f7e34-f038-49ad-99a5-b3c92f12123a",
  "name": "Yauheniya Askolkava",
  "email": "test@itsme.be",
  "idp": "itsme-id.com",
  "extension_BENationalNumber": "85010244229",
  "extension_birthdate": "1985-01-02",
  "extension_citizenshipIso": "BEL",
  "extension_name": "Yauheniya Askolkava",
  "extension_givenName": "Yauheniya",
  "extension_familyName": "Askolkava",
  "extension_birthdateString": "string",
  "extension_gender": "female",
  "extension_locale": "EN",
  "extension_picture": "https://oidc.e2e.itsme.services/clientsecret-oidc/csapi/v0.1/picture",
  "extension_idDocumentType": "string",
  "extension_citizenship": "Belg",
  "extension_email": "test@itsme.be",
  "extension_idDocumentSn": "85010244229",
  "extension_emailVerified": false,
  "extension_phoneNumber": "+32 493310088",
  "extension_phoneNumberVerified": true,
  "extension_beEidSn": "581721097415",
  "tid": "c1d38481-9611-417e-9b02-f502776cf5eb",
  "nbf": 1689861444
}.[Signature]
```

### IEF configuration to retrieve custom OIDC claims (string or boolean data type)
Microsoft has elaborate documentation custom policy definition and how to work with <button type="button"><a href="https://learn.microsoft.com/en-us/azure/active-directory-b2c/custom-policy-overview#custom-policy-starter-pack" target="blank">starter pack</a></button>. Below we attempt to provide guidance from partner perspective to smooth the configuration flow. We advise however always fall back to Azure B2C official documentation.

#### Prerequisites
- An Azure B2C Tenant
- Your itsme® provided ClientID aka PartnerCode
- Your itsme® provided ServiceCode
- Your client secret for your itsme® account

#### Getting started with Custom Policies

##### Add Signing and Encryption keys
Open the B2C tenant and, under Policies, select Identity Experience Framework.
###### Create the signing key
1. Select Policy Keys and then select Add.
2. For Options, choose Generate.
3. In Name, enter TokenSigningKeyContainer. The prefix B2C_1A_ is added automatically.
4. For Key type, select RSA.
5. For Key usage, select Signature.
6. Select Create.

###### Create the encryption key
1. Select Policy Keys and then select Add.
2. For Options, choose Generate.
3. In Name, enter TokenEncryptionKeyContainer. The prefix B2C_1A_ is added automatically.
4. For Key type, select RSA.
5. For Key usage, select Encryption.
6. Select Create.


###### Register Identity Experience Framework applications
1. Open the B2C tenant and select under Manage App registrations.
2. Select App registrations, and then select New registration.
3. For Name, enter IdentityExperienceFramework.
4. Under Supported account types, select Accounts in this organizational directory only.
5. Under Redirect URI, select Web, and then enter https://your-tenant-name.b2clogin.com/your-tenant-name.onmicrosoft.com, where your-tenant-name is your Azure AD B2C tenant domain name.
6. Under Permissions, select the Grant admin consent to openid and offline_access permissions check box.
7. Select Register.
8. Record the Application (client) ID for use in a later step.

Next, expose the API by adding a scope:
1. Under Manage, select Expose an API.
2. Select Add a scope, then select Save and continue to accept the default application ID URI.
3. Enter the following values to create a scope that allows custom policy execution in your Azure AD B2C tenant:
- Scope name: user_impersonation
- Admin consent display name: Access IdentityExperienceFramework
- Admin consent description: Allow the application to access IdentityExperienceFramework on behalf of the signed-in user.
4. Select Add scope


###### Register the ProxyIdentityExperienceFramework application
(cf. <button type="button"><a href="https://docs.microsoft.com/en-us/azure/active-directory-b2c/custom-policy-get-started?tabs=app-reg-preview#register-the-proxyidentityexperienceframework-application" target="blank">register proxy IEF app</a></button>)

1. Open the B2C tenant and select under Manage App registrations.
2. Select App registrations (Preview), and then select New registration.
3. For Name, enter ProxyIdentityExperienceFramework.
4. Under Supported account types, select Accounts in this organizational directory only.
5. Under Redirect URI, use the drop-down to select Public client/native (mobile & desktop).
6. For Redirect URI, enter myapp://auth.
7. Under Permissions, select the Grant admin consent to openid and offline_access permissions check box.
8. Select Register.
9. Record the Application (client) ID for use in a later step.

Next, specify that the application should be treated as a public client:
1. Under Manage, select Authentication.
2. Select Try out the new experience (if shown).
3. Under Advanced settings, enable Treat application as a public client (select Yes). Ensure that "allowPublicClient": true is set in the application manifest.
4. Select Save.

Now, grant permissions to the API scope you exposed earlier in the IdentityExperienceFramework registration:
1. Under Manage, select API permissions.
2. Under Configured permissions, select Add a permission.
3. Select the My APIs tab, then select the IdentityExperienceFramework application.
4. Under Permission, select the user_impersonation scope that you defined earlier.
5. Select Add permissions. As directed, wait a few minutes before proceeding to the next step.
6. Select Grant admin consent for (your tenant name).
7. Select your currently signed-in administrator account, or sign in with an account in your Azure AD B2C tenant that's been assigned at least the Cloud application administrator role.
8. Select Accept.
9. Select Refresh, and then verify that "Granted for ..." appears under Status for the scopes - offline_access, openid and user_impersonation. It might take a few minutes for the permissions to propagate.

###### App Registration
1. Open the B2C tenant and select under Manage select App Registrations
2. New registration
3. Support account type: Account in this organizational directory only
4. Redirect URL: the redirect URL to your app. 
- For testing purposes, you can use https://jwt.ms
5. click on Register
- For testing purposes, go to Authentication and select in the section implicit grant “Access Tokens” and “ID Tokens”.

###### Client Secret Registration
1. Open the B2C tenant and select under Policies Identity Experience Framework.
2. Select Policy keys and then select Add.
3. For Options, choose Manual.
4. Enter the name “itsmeClientSecret”
5. For Key usage, select Signature.
6. Select Create.

#####  Edit the Custom Policy Starter Pack
1. Download the starter pack:
```git clone https://github.com/Azure-Samples/active-directory-b2c-custom-policy-starterpack```

2. Edit the files from the “SocialAndLocalAccounts” folder in the downloaded starter pack
3. In all XML files in the starter pack, replace “yourtenant” with the name of your tenant
4. In TrustFrameworkExtensions.xml, fill in the AppID of the two Identity Experience Framework applications
- replace “ProxyIdentityExperienceFrameworkAppId”
- replace “IdentityExperienceFrameworkAppId”
- remove the “<ClaimsProvider>” with the DisplayName ‘Facebook’

```
<Metadata>
 <Item Key="client_id">ProxyIdentityExperienceFrameworkAppID</Item>
 <Item Key="IdTokenAudience">IdentityExperienceFrameworkAppID</Item>
</Metadata>
<InputClaims>
```
```
<InputClaim ClaimTypeReferenceId="client_id" DefaultValue="ProxyIdentityExperienceFrameworkID" />
 <InputClaim ClaimTypeReferenceId="resource_id" PartnerClaimType="resource" DefaultValue="IdentityExperienceFrameworkAppID" />
</InputClaims>
```

###### Edit the Trustframeworkbase.xml to add the itsme provider
1. In the <ContentDefinitions> element, adjust the URIs for the layout if needed
2. In the <ClaimsProviders> element, remove the ClaimsProvider with the displayName facebook.com
3. Add in the <ClaimsProviders> element the following <ClaimsProvider> element. 
- the METADATA is different depending the environment:
    - E2E: https://oidc.e2e.itsme.services/clientsecret-oidc/csapi/v0.1/.well-known/openid-configuration
    - Production: https://oidc.prd.itsme.services/clientsecret-oidc/csapi/v0.1/.well-known/openid-configuration
- Replace YOURitsmePARTNERCODE with your itsme partner code
- Replace YOURitsmeSERVICECODE with your itsme service code
In this example, the BENationalNumber claim is added as string and phone_number_verified as boolean. More claims can be added if needed:

```
<ClaimsProvider>
      <DisplayName>tsme®</DisplayName>
      <TechnicalProfiles>
        <TechnicalProfile Id="ItsmeProfile">
          <DisplayName>itsme®</DisplayName>
          <Protocol Name="OpenIdConnect" />
          <Metadata>
            <Item Key="METADATA">https://oidc.e2e.itsme.services/clientsecret-oidc/csapi/v0.1/.well-known/openid-configuration</Item>
            <Item Key="client_id">YOURitsmePARTNERCODE</Item>
            <Item Key="response_types">code</Item>
            <Item Key="response_mode">query</Item>
            <Item Key="scope">openid service:YOURitsmeSERVICECODE</Item>
            <!-- Policy Engine Clients -->
            <Item Key="UsePolicyInRedirectUri">false</Item>
            <Item Key="HttpBinding">POST</Item>
          </Metadata>
          <CryptographicKeys>
            <Key Id="client_secret" StorageReferenceId="B2C_1A_ItsmeClientSecret"/>
          </CryptographicKeys>
          <InputClaims>
            <InputClaim ClaimTypeReferenceId="claims" DefaultValue="{&quot;userinfo&quot;:{&quot;http://itsme.services/v2/claim/BENationalNumber&quot;:null,&quot;phone_number_verified&quot;:null}}" AlwaysUseDefaultValue="true" />
          </InputClaims>
          <OutputClaims>
            <OutputClaim ClaimTypeReferenceId="identityProvider" DefaultValue="itsme-id.com" AlwaysUseDefaultValue="true" />
            <OutputClaim ClaimTypeReferenceId="issuerUserId" PartnerClaimType="sub" />
            <OutputClaim ClaimTypeReferenceId="givenName" PartnerClaimType="given_name" />
            <OutputClaim ClaimTypeReferenceId="surname" PartnerClaimType="family_name" />
            <OutputClaim ClaimTypeReferenceId="displayName" PartnerClaimType="name" />
            <OutputClaim ClaimTypeReferenceId="email" PartnerClaimType="email" />
            <OutputClaim ClaimTypeReferenceId="extension_BENationalNumber" PartnerClaimType="http://itsme.services/v2/claim/BENationalNumber" />
            <OutputClaim ClaimTypeReferenceId="extension_phoneNumberVerified" PartnerClaimType="phone_number_verified" DefaultValue="false" />
          </OutputClaims>
          <UseTechnicalProfileForSessionManagement ReferenceId="SM-SocialLogin" />
        </TechnicalProfile>
      </TechnicalProfiles>
    </ClaimsProvider>
```

4. Add in the section <ClaimsSchema> element the follow <ClaimType> element

```
<ClaimType Id="claims">
  <DisplayName>Custom Claims</DisplayName>
  <DataType>string</DataType>
</ClaimType>
```

5. Adjust the <UserJourneys> elements to suit your needs
For example, replace the `<ClaimsProviderSelection TargetClaimsExchangeId="FacebookExchange"/>`
with `<ClaimsProviderSelection TargetClaimsExchangeId="ItsmeExchange"/>`
and `<ClaimsExchange Id="FacebookExchange" TechnicalProfileReferenceId="Facebook-OAUTH" />` with `<ClaimsExchange Id="ItsmeExchange" TechnicalProfileReferenceId="ItsmeProfile" />`


###### Persist Custom Claims in AAD
1. Edit the TrustFrameworkBase.xml document.
2. Add in the section <ClaimsSchema> element the follow <ClaimType> element

```
<ClaimType Id="extension_BENationalNumber">
 <DisplayName>Belgian National Number of the user provided by itsme</DisplayName>
 <DataType>string</DataType>
 <UserInputType>TextBox</UserInputType>
</ClaimType>

<ClaimType Id="extension_phoneNumberVerified">
  <DisplayName>phone_number_verified</DisplayName>
  <DataType>boolean</DataType>
  <UserInputType>TextBox</UserInputType>
</ClaimType>  
```
3. Add in the <TechnicalProfile Id=”AAD-Common”> the Metadata information. The values can be found as follows:
- In Azure AD B2C, select App registrations, and then select All Applications.
- Select the b2c-extensions-app. Do not modify. Used by AADB2C for storing user data. application.

```
<!-- CUSTOM -->
<Metadata>
  <Item Key="ApplicationObjectId">ObjectID of b2c-extensions-app</Item>
  <Item Key="ClientId">Application/ClientID of b2c-extensions-app</Item>
</Metadata>
```

4. Next, in the section <PersistedClaims> add the custom claim link.
5. Depending on your needs, you might need to add the custom claims in other <TechnicalProfiles> as well. For example, to Write the value in the AAD, as well as to read it back from the AAD.

```
<TechnicalProfile Id="AAD-Common">
 <DisplayName>Azure Active Directory</DisplayName>
[…]
 <TechnicalProfile Id="AAD-UserWriteUsingAlternativeSecurityId">
[…]
   <PersistedClaims>
[…]
     <!-- Optional claims -->
     <PersistedClaim ClaimTypeReferenceId="otherMails" />
     <PersistedClaim ClaimTypeReferenceId="givenName" />
     <PersistedClaim ClaimTypeReferenceId="surname" />
     <PersistedClaim ClaimTypeReferenceId="extension_BENationalNumber" DefaultValue="Unknown" />
     <PersistedClaim ClaimTypeReferenceId="extension_phoneNumberVerified" DefaultValue="false" />
   </PersistedClaims>
[…]
<TechnicalProfile Id="AAD-UserReadUsingAlternativeSecurityId">
[…]
    <!-- Optional claims -->
    <OutputClaim ClaimTypeReferenceId="userPrincipalName" />
    <OutputClaim ClaimTypeReferenceId="surname" />
    <OutputClaim ClaimTypeReferenceId="extension_BENationalNumber" />
```

###### Edit the SignUpOrSignin.xml
In the <OutputClaims>, add the custom claim(s) to have been requested.
```
<OutputClaim ClaimTypeReferenceId="extension_BENationalNumber"/>
<OutputClaim ClaimTypeReferenceId="extension_phoneNumberVerified" />
```

###### Upload the policies
1. Select the Identity Experience Framework
2. Select Upload custom policy.
3. In this order, upload the policy files:
- TrustFrameworkBase.xml
- TrustFrameworkExtensions.xml
- SignUpOrSignin.xml
- ProfileEdit.xml
- PasswordReset.xml

###### Test the flow
1. In the Identity Experience Framework, click on the B2C_1A_signup_sigin custom policy file.
2. Select Application and the reply url
3. Click on Run now
4. Based on your <UserJourneys>, the itsme® “Identify yourself” page will appear. 
5. Enter your mobile phone number and click on send.
6. Confirm the action in the itsme® app.
7. If all succeeds, you will be redirected to the redirect URL.