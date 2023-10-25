---
layout: page
title: JS Object Signing & Encryption
permalink: JOSE/
nav_exclude: false

---

# Introduction

The concepts of JWT, JWS, JWE and JWK are part of the JSON Object Signing and Encryption (JOSE) framework that intends to provide a method to securely transfer claims between parties.

All these technologies can be used collectively to encrypt and/or sign content using a variety of algorithms. While the full set of permutations is extremely large, and might be daunting to some, it is expected that most applications will only use a small set of algorithms to meet their needs.

# Definitions

The JSON Object Signing and Encryption (JOSE) framework consists of several technologies:

<ul>
    <li>JSON Web Token (<a href="https://tools.ietf.org/html/rfc7519" target="blank">JWT</a>) is a compact, URL-safe means of representing claims to be transferred between two parties. The claims in a JWT are encoded as a JSON object that is used as the payload of a JSON Web Signature (JWS) structure, as the plaintext of a JSON Web Encryption (JWE) structure or enclosed in another JWE or JWS structure to create a Nested JWT, enabling nested signing and encryption to be performed. In fact a JWT does not exist itself — either it has to be a JWS and/or a JWE. It’s like an abstract class — the JWS and JWE are the concrete implementations.</li>
    <li>JSON Web Signature (<a href="https://tools.ietf.org/html/rfc7515" target="blank">JWS</a>) represents signed content using JSON data structures and base64url encoding as defined in the specifications.</li>
    <li>JSON Web Encryption (<a href="https://tools.ietf.org/html/rfc7516" target="blank">JWE</a>) specification standardizes the way to represent an encrypted content in a JSON-based data structure.</li>
    <li>JSON Web Key (<a href="https://tools.ietf.org/html/rfc7517" target="blank">JWK</a>) defines a consistent way to represent a cryptographic key in a JSON structure which is used to sign (JWS) and/or encrypt (JWE) a specific content. The JSON Web Key Set (JWKS) extension defines a consistent way to represent a set of cryptographic keys in a JSON structure.
    As itsme® only support the RSA cryptosystem, it requires that each party exposes its public keys as a simple JWK Set document on a URI accessible to all.
        <ul>
            <li>For itsme®, this URI can be retrieved from the <a href="../authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a>, using the "jwks_uri" key.</li>
            <li>Your JWK Set document MUST be accessible via the URI communicated when setting up your project in the <a href="https://portal.itsme-id.com/login" target="blank">itsme® B2B portal</a> or via email to onboarding@itsme-id.com.</li>
        </ul></li>
</ul>

# Creating your JWK Set URI

The JWK is nothing more than another representation of the (public) key of a certificate keypair and the JWK Set is simply a list of one or more JWK.

So, you need to have/create your certificate key pairs (a key pair consists of a public key and a private key): you will need one pair for encryption and one pair for signing actions.

You can use your certificates or (preferably) get them through a certificate authority. 

Next, you will need to ‘convert’ the PUBLIC keys (NOT the private key. You MUST keep the private key always private) to JWK and group them in a JWK Set. There are various tools that can be used and all major programming languages support have libraries available to do this for you. 

The resulting JWK Set MUST contain (at least) 2 JWK: one whereby the “use” parameter is ”enc” (for encryption) and another with “sig” (for signature).

This JWK Set is nothing more than a plain text file (“JSON” format) and you should place that on a publicly available website under https schema (with <a href="https://belgianmobileid.github.io/doc/authentication/#certificates-and-website-security" target="blank"> EV/OV certificate</a>)  and share that link with us if you have no access to itsme® B2B portal yet. As these are the PUBLIC keys, there is no problem to share this information publicly: in other words, it should not be placed behind a password or login screen. We expect that your server where jwkset is hosted responds fast, e.g. faster than 1000ms.

Some more (technical) documentation on <a href="https://tools.ietf.org/html/rfc7517" target="blank">https://tools.ietf.org/html/rfc7517</a>.

# Signing, encrypting and decrypting

## 1. Signing

A signed content can be serialized in two ways: the JWS compact serialization and the JWS JSON serialization. Because the OpenID Connect specification mandates to use JWS compact serialization whenever necessary, we will not explain the JWS JSON serialization signing process in this document.

Following steps will show you how to generate a JWS Compact Serialization object:

<ol>
  <li>Build a JSON object including the below header elements, which express the cryptographic properties of the JWS object — this is known as the JWS Header.</li>

<table>
  <tbody>
    <tr>
      <td>{% include parameter.html name="alg" req="Required" %}</td>
      <td>Identifies the cryptographic algorithm used to secure the JWS. This MUST be set to <i>"RS256"</i></td>
    </tr>
    <tr>
      <td>{% include parameter.html name="kid" req="Optionnal" %}</td>
      <td>Hint indicating which key was used to secure the JWS. The structure of the <code>kid</code> value is a case-sensitive string. In case there are multiple signing keys referenced in your JWK Set document then a <code>kid</code> MUST be present.</td>
    </tr>
  </tbody>
</table>

  <li>The JWS Header will then be encoded using UTF-8 and base64url to produce the string below.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>eyJhbGciOiJSUzI1NiIsImtpZCI6ImJpbGJvLmJhZ2dpbnNAaG9iYml0b24uZXhhbXBsZSJ9
</code></pre></div>

  <li>Construct the payload or the content to be signed as UTF-8 — this is known as the JWS Payload.</li>
  <li>The JWS Payload will then be encoded using base64url to produce the string below.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>SXTigJlzIGEgZGFuZ2Vyb3VzIGJ1c2luZXNzLCBGcm9kbywgZ29pbmcgb3V0IHlvdXIgZG9vci4gWW91IHN0ZXAgb250byB0aGUgcm9hZCwgYW5kIGlmIHlvdSBkb24ndCBrZWVwIHlvdXIgZmVldCwgdGhlcmXigJlzIG5vIGtub3dpbmcgd2hlcmUgeW91IG1pZ2h0IGJlIHN3ZXB0IG9mZiB0b
</code></pre></div>

  <li>Combine the JWS Header and JWS Payload, and separate them with period ('.') characters, to produce the JWS Signing Input.</li>
  <li>Complete the signing operation over the JWS Signing Input with the algorithm defined in the <i>"alg"</i> parameter, to produce the JWS Signature. The JWS Signing Input is signed using your private key corresponding to the public key referenced in your JWK Set document. This information SHOULD be made available via the URI you communicated when setting up your project in the <a href="https://portal.itsme-id.com/login" target="blank">itsme® B2B portal</a> or via email to onboarding@itsme-id.com.</li>
  <li>The JWS Signature will then be encoded using base64url to produce the string below.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>MRjdkly7_-oTPTS3AXP41iQIGKa80A0ZmTuV5MEaHoxnW2e5CZ5NlKtainoFmKZopdHM1O2U4mwzJdQx996ivp83xuglII7PNDi84wnB-BDkoBwA78185hX-Es4JIwmDLJK3lfWRa-XtL0RnltuYv746iYTh_qHRD68BNt1uSNCrUCTJDt5aAE6x8wW1Kt9eRo4QPocSadnHXFxnt8Is9UzpERV0ePPQdLuW3IS_de3xyIrDaLGdjluPxUAhb6L2aXic1U12podGU0KLUQSE_oI-ZnmKJ3F4uOZDnd6QZWJushZ41Axf_fcIe8u9ipH84ogoree7vjbU5y18kDquDg
</code></pre></div>

<li>Finally, you are now be able to build the JWS object by concatenating the three strings, and separate them with period ('.') characters. An example of a JWS object is given below.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>eyJhbGciOiJSUzI1NiIsImtpZCI6ImJpbGJvLmJhZ2dpbnNAaG9iYml0b24uZXhhbXBsZSJ9
.
SXTigJlzIGEgZGFuZ2Vyb3VzIGJ1c2luZXNzLCBGcm9kbywgZ29pbmcgb3V0IHlvdXIgZG9vci4gWW91IHN0ZXAgb250byB0aGUgcm9hZCwgYW5kIGlmIHlvdSBkb24ndCBrZWVwIHlvdXIgZmVldCwgdGhlcmXigJlzIG5vIGtub3dpbmcgd2hlcmUgeW91IG1pZ2h0IGJlIHN3ZXB0IG9mZiB0by4
.
MRjdkly7_-oTPTS3AXP41iQIGKa80A0ZmTuV5MEaHoxnW2e5CZ5NlKtainoFmKZopdHM1O2U4mwzJdQx996ivp83xuglII7PNDi84wnB-BDkoBwA78185hX-Es4JIwmDLJK3lfWRa-XtL0RnltuYv746iYTh_qHRD68BNt1uSNCrUCTJDt5aAE6x8wW1Kt9eRo4QPocSadnHXFxnt8Is9UzpERV0ePPQdLuW3IS_de3xyIrDaLGdjluPxUAhb6L2aXic1U12podGU0KLUQSE_oI-ZnmKJ3F4uOZDnd6QZWJushZ41Axf_fcIe8u9ipH84ogoree7vjbU5y18kDquDg
</code></pre></div>
</ol>

## 2. Encryption

Now that our content is signed, we will encapsulate this JWS object into a JWE object so that it becomes encrypted as well.

An encrypted content can be serialized in two ways: the JWE compact serialization and the JWE JSON serialization. Because the OpenID Connect specification mandates to use JWE compact serialization whenever necessary, we will not explain the JWE JSON serialization signing process in this document.

With the JWE compact serialization, a JWE is the concatenation of 5 elements:

1. The **JWE Header** contains information about the encryption algorithms used.
2. The encrypted **Content Encryption Key (CEK)** contains the key needed to decrypt the payload.
3. The **Initialization Vector** is used to introduce randomness in the encryption process.
4. The **Cipher text** is the encrypted payload itself. In this case, the payload is our JWS object.
5. The **Authentication Tag** is used for integrity checks.

Here are the steps to generate those elements:

<ol>
    <li>Create the JWS object, as described in the section above.</li>
    <li>Create the JWE Header: it is a JSON object containing 4 parameters.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>## JWE Header Example

{
    "alg": "RSA-OAEP",
    "enc": "A128CBC-HS256",
    "cty": "JWT",
    "kid": "samwise.gamgee@hobbiton.example"
}
</code></pre></div>

    <table>
    <tbody>
        <tr>
        <td>{% include parameter.html name="alg" req="Required" %}</td>
        <td>Defines the algorithm used to encrypt the Content Encryption Key (CEK). This SHOULD be set to *"RSA-OAEP-256".</td>
        </tr>
        <tr>
        <td>{% include parameter.html name="enc" req="Required" %}</td>
        <td>Defines the algorithm used to perform authenticated encryption on the payload to produce the Ciphertext and the Authentication Tag. This MUST be set to one of the values advertised in the <a href="../authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a>.</td>
        </tr>
        <tr>
        <td>{% include parameter.html name="cty" req="Required" %}</td>
        <td>Defines the “content type” of the payload. In this case, the value MUST be *"JWT"*, to indicate that a nested JWT (= our JWS) is carried inside this JWT.</td>
        </tr>
        <tr>
        <td>{% include parameter.html name="kid" req="Optionnal" %}</td>
        <td>This parameter has the same meaning, syntax, and processing rules as the "kid" parameter defined in the JWS section, except that the key hint references the public key with which the JWE was encrypted; this can be used to determine the private key needed to decrypt the JWE.</td>
        </tr>
    </tbody>
    </table>

    <li>Base64url encode the (UTF-8 encoded) JWE Header, to obtain a string like:</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>eyJhbGciOiJSU0ExXzUiLCJraWQiOiJmcm9kby5iYWdnaW5zQGhvYmJpdG9uLmV4YW1wbGUiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0</code></pre></div>

    <li>Generate a random 32 bytes string to be used as CEK</li>
    <li>Encrypt the CEK using RSA-OAEP algorithm (<a href="https://tools.ietf.org/html/rfc7518#section-4.3">RFC7518</a>).
        The key to be used for this encryption is itsme® public key. This key is published in itsme® JWKset with parameter "use" set on "enc". Our JWKset can be found at the jwks_uri URL given in <a href="../authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a></li>
    <li>Base64url encode the (UTF-8 encoded) encrypted CEK, to obtain a string like:</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>laLxI0j-nLH-_BgLOXMozKxmy9gffy2gTdvqzfTihJBuuzxg0V7yk1WClnQePFvG2K-pvSlWc9BRIazDrn50RcRai__3TDON395H3c62tIouJJ4XaRvYHFjZTZ2GXfz8YAImcc91Tfk0WXC2F5Xbb71ClQ1DDH151tlpH77f2ff7xiSxh9oSewYrcGTSLUeeCt36r1Kt3OSj7EyBQXoZlN7IxbyhMAfgIe7Mv1rOTOI5I8NQqeXXW8VlzNmoxaGMny3YnGir5Wf6Qt2nBq4qDaPdnaAuuGUGEecelIO1wx1BpyIfgvfjOhMBs9M8XL223Fg47xlGsMXdfuY-4jaqVw
</code></pre></div>

    <li>Generate a random 128 bits string to be used as Initialization Vector.</li>
    <li>Base64url encode the Initialization Vector to obtain a string like:</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>bbd5sTkYwhAIqfHsx8DayA</code></pre></div>

    <li>Compute the ASCII values of the characters of the encoded JWE Header to get the Additional Authenticated Data (AAD). In our example, that would give:</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>101 121 74 104 98 71 99 105 79 105 74 83 85 48 69 120 88 122 85 105 76 67 74 114 97 87 81 105 79 105 74 109 99 109 57 107 98 121 53 105 89 87 100 110 97 87 53 122 81 71 104 118 89 109 74 112 100 71 57 117 76 109 86 52 89 87 49 119 98 71 85 105 76 67 74 108 98 109 77 105 79 105 74 66 77 84 73 52 81 48 74 68 76 85 104 84 77 106 85 50 73 110 48
</code></pre></div>

    <li>Encrypt the JWS using A128CBC-HS256 algorithm. The algorithm takes as input four strings: the CEK, the AAD, the JWE Initialization Vector and the payload (= the JWS) which were computed in the previous steps. The algorithm returns two string outputs: the JWE Ciphertext and the Authentication Tag.</li>
    <li>Base64url-encode the JWE Ciphertext.</li>
    <li>Base64url-encode the JWE Authentication Tag.</li>
    <li>Assemble the final representation by concatenating the five base64url encoded strings, and separate them with period ('.') characters. An example of a JWE object is given below.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>eyJhbGciOiJSU0ExXzUiLCJraWQiOiJmcm9kby5iYWdnaW5zQGhvYmJpdG9uLmV4YW1wbGUiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0
.
laLxI0j-nLH-_BgLOXMozKxmy9gffy2gTdvqzfTihJBuuzxg0V7yk1WClnQePFvG2K-pvSlWc9BRIazDrn50RcRai__3TDON395H3c62tIouJJ4XaRvYHFjZTZ2GXfz8YAImcc91Tfk0WXC2F5Xbb71ClQ1DDH151tlpH77f2ff7xiSxh9oSewYrcGTSLUeeCt36r1Kt3OSj7EyBQXoZlN7IxbyhMAfgIe7Mv1rOTOI5I8NQqeXXW8VlzNmoxaGMny3YnGir5Wf6Qt2nBq4qDaPdnaAuuGUGEecelIO1wx1BpyIfgvfjOhMBs9M8XL223Fg47xlGsMXdfuY-4jaqVw
.
bbd5sTkYwhAIqfHsx8DayA
.
0fys_TY_na7f8dwSfXLiYdHaA2DxUjD67ieF7fcVbIR62JhJvGZ4_FNVSiGc_raa0HnLQ6s1P2sv3Xzl1p1l_o5wR_RsSzrS8Z-wnI3Jvo0mkpEEnlDmZvDu_k8OWzJv7eZVEqiWKdyVzFhPpiyQU28GLOpRc2VbVbK4dQKPdNTjPPEmRqcaGeTWZVyeSUvf5k59yJZxRuSvWFf6KrNtmRdZ8R4mDOjHSrM_s8uwIFcqt4r5GX8TKaI0zT5CbL5Qlw3sRc7u_hg0yKVOiRytEAEs3vZkcfLkP6nbXdC_PkMdNS-ohP78T2O6_7uInMGhFeX4ctHG7VelHGiT93JfWDEQi5_V9UN1rhXNrYu-0fVMkZAKX3VWi7lzA6BP430m
.
kvKuFBXHe5mQr4lqgobAUg</code></pre></div>
</ol>

## 3. Decrypting

To validate a Nested JWT object, you will first need to decrypt the JWE object, then extract the signed JWS Payload and verify the JWS Signature. 

### Decrypting the JWE object

The decryption process is the reverse of the encryption process:

<ol>
  <li>Parse the JWE object to extract the serialized values of the base64url-encoded JWE Header, the base64url-encoded JWE Encrypted Key, the base64url-encoded JWE  Initialization Vector, the base64url-encoded JWE Ciphertext, and the base64url-encoded JWE Authentication Tag.</li>
  <li>Base64url decode the encoded representations of the JWE Header, the JWE Encrypted Key, the JWE Initialization  Vector, the JWE Ciphertext, the JWE Authentication Tag, and the JWE Additional Authenticated Data (AAD).</li>
  <li>Verify that the octet sequence resulting from decoding the encoded JWE Header is a UTF-8-encoded representation of a completely valid JSON object.</li>
  <li>Determine the algorithm specified by the <i>"alg"</i> parameter in the JWE Header.</li>
  <li>Decrypt the JWE Encrypted Key with the algorithm defined in the <i>"alg"</i> parameter, to produce the Content Encryption Key (CEK). The JWE Encrypted Key is decoded using your private key corresponding to the public key referenced in your jwkset. The jwkset uri SHOULD be made available when setting up your project in the <a href="https://portal.itsme-id.com/login" target="blank">itsme® B2B portal</a> or via email to onboarding@itsme-id.com. In case you expose several keys on your jwkset uri, our backend will randomly choose the encryption key, please, see the JWE header information to identify via kid, what key our backend picked up.</li>
  <li>Let the Additional Authenticated Data (AAD) encryption parameter be the octets of the ASCII representation of the encoded JWE Header value.</li>
  <li>Decrypt the JWE Ciphertext with the encryption algorithm defined by the <i>"enc"</i> parameter in the JWE Header. It will return the decrypted JWS object.</li>
</ol>

### Extracting the payload

<ol>
    <li>Parse the JWS object to extract the JWS components serialized values, such as in the example below.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>jws_header = 
"eyJhbGciOiJSUzI1NiIsImtpZCI6ImJpbGJvLmJhZ2dpbnNAaG9iYml0b24uZXhhbXBsZSJ9"
payload = 
"SXTigJlzIGEgZGFuZ2Vyb3VzIGJ1c2luZXNzLCBGcm9kbywgZ29pbmcgb3V0IHlvdXIgZG9vci4gWW91IHN0ZXAgb250byB0aGUgcm9hZCwgYW5kIGlmIHlvdSBkb24ndCBrZWVwIHlvdXIgZmVldCwgdGhlcmXigJlzIG5vIGtub3dpbmcgd2hlcmUgeW91IG1pZ2h0IGJlIHN3ZXB0IG9mZiB0by4"
signature = 
"MRjdkly7_-oTPTS3AXP41iQIGKa80A0ZmTuV5MEaHoxnW2e5CZ5NlKtainoFmKZopdHM1O2U4mwzJdQx996ivp83xuglII7PNDi84wnB-BDkoBwA78185hX-Es4JIwmDLJK3lfWRa-XtL0RnltuYv746iYTh_qHRD68BNt1uSNCrUCTJDt5aAE6x8wW1Kt9eRo4QPocSadnHXFxnt8Is9UzpERV0ePPQdLuW3IS_de3xyIrDaLGdjluPxUAhb6L2aXic1U12podGU0KLUQSE_oI-ZnmKJ3F4uOZDnd6QZWJushZ41Axf_fcIe8u9ipH84ogoree7vjbU5y18kDquDg"</code></pre></div>

    <li>Base64url-decode the encoded representation of the JWS Header.</li>
    <li>Verify that the resulting octet sequence is a UTF-8-encoded representation of a completely valid JSON object.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>{
"alg":"RS256",
"kid":"3466d51f7dd0c780565688c183921816c45889ad"
}</code></pre></div>

    <li value="4">Base64url-decode the encoded representation of the JWS Payload.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>{
   "sub":"joe",
   "aud":"im_oic_client",
   "jti":"uf90SK4wscFhctUT6Dtvb2",
   "iss":"https:\/\/localhost:9031",
   "iat":1394060853,
   "exp":1394061153,
   "nonce":"e957ffba-9a78-4ea9-8eca-ae8c4ef9c856",
   "at_hash":"wfgvmE9VxjAudsl9lc6TqA"
}</code></pre></div>

    <li value="5">Base64url-decode the encoded representation of the JWS Signature.</li>

<div class="language-http highlighter-rouge"><pre class="highlight">
<code>XiyNdHHHoYqarDZGkhln5sF_SQNNVvV67SZsFAk7yo8NreJjzVw7LmtkwpiUQe87-Km39PeIwf1W_PqEH9RqjA</code></pre></div>
</ol>

You have decoded the JWS object. The next step is to validate the JWS Signature.

### Validating the JWS Signature

<ol>
  <li>Determine the signing algorithm <code>alg</code> and the key identifier <code>kid</code> from the JWS Header.</li>
  <li>Validate the JWS Signature in the manner defined for the algorithm being used, which MUST be accurately represented by the value of the <code>alg</code> parameter. The signature is verified using the public key of itsme®, which can be retrieved from the <a href="../authentication/#itsme-discovery-document" target="blank">itsme® Discovery document</a>, using the <code>jwks_uri</code> key. If the returned itsme® JSON Web Key (JWK) contains an array of keys, you MUST use the one corresponding to the value given by the <code>kid</code> parameter from the JWS Header.</li>
</ol>