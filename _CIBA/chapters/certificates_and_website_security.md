## Certificates and website security

itsme requires <code>https</code> connections to guarantee security. With the <code>https</code> protocol, a web site operator obtains a certificate by applying to a certificate authority with a certificate signing request. The certificate request is an electronic document that contains the web site name, company information and the public key. The certificate provider signs the request, thus producing a public certificate. During web browsing, this public certificate is served to any web browser that connects to the web site and proves to the web browser that the provider believes it has issued a certificate to the owner of the web site.

A certificate provider can opt to issue three types of certificates, each requiring its own degree of vetting rigor. In order of increasing rigor (and naturally, cost) they are: Domain Validation, Organization Validation and Extended Validation.

The Domain Validation certificate doesn't provide sufficient identity guarantees to itsme. So, <b>only the Organization Validation and Extended Validation certificates</b> are supported. For example, using the Let's Encrypt open certificate authority is not sufficient because it only provide standard Domain Validation certificates.

<aside class="notice">The chain of trust of these certificates need to be publicly accessible, meaning that our systems need to be able to access the root and the intermediate certificates.</aside>

<aside class="notice">All itsme API URL we publish use <code>https</code>.</aside>

<aside class="notice">All requests to our endpoints MUST also use the SNI extension (refer to the <a href="https://datatracker.ietf.org/doc/html/rfc6066#section-3">RFC 6066</a> for more information) of the TLS protocol, that allows our servers to provide you with the correct certificate based on which endpoint you are querying.</aside>

