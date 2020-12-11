---
layout: page
title: Guide
permalink: /Guide
nav_order: 2
---

# OIDC protocol

The API is based on the Authorization Code Flow of OpenID Connect 1.0. It allows computing clients to verify the identity of an end-user based on the authentication performed by an authorization server, as well as to obtain basic profile information about the end-user in an interoperable and REST-like manner. Sounds technical, but it’s really quite easy. The REST architecture mainly breaks down to HTTP-methods GET and POST.

REST also implies a nice and clean structure for URLs or endpoints. This means you can reach any part of the itsme® API on https://idp.prd.itsme.services/v2/ adding the name of the resource you want to interact with. 


# Authentication

A client authentication method is requied to protect the exhange of entitlement information between us, ensure the requested information get issued to a legitimate service provider and not some other party.

The itsme API offers two authentication methods :

<ul>
  <li>asymmetric RSA key pair</li>
  <li>symmetric shared secret</li>
</ul>

We recommend using the private_key_jwt method as it is more secure.  

### Asymmetric RSA 

This method requires that each party exposes its public keys as a simple JWK Set document on a URI accessible to all, and keep its private set for itself. For itsme®, this URI can be retrieved from the [itsme® Discovery document](#OpenIDConfig), using the <i>"jwks_uri"</i> key.

Your private and public keys can be generated using your own tool or via Yeoman. If using Yeoman, you need to install generator-itsme with NPM:

```
$ npm install -g yo generator-itsme
```

After installation, run the generator:

```
$ yo itsme
```

The Yeoman tool will generate two files, the jwks_private.json which MUST be stored securely somewhere in your systems, and the jwks_public.json which need to be exposed as a JWK Set on a URI accessible to all parties.

<aside class="notice">Whatever the tool you are choosing to create your key pairs, don't forget to send your JWK Set URI by email to <a href = "mailto: onboarding@itsme.be">onboarding@itsme.be</a> and we’ll make sure to complete the configuration for you in no time!
</aside>

### Symmetric secret 

This method requires the exchange of a static secret that will be used to authenticate with our Back-End. 

The client_secret value will be provided by itsme® when <a href="https://belgianmobileid.github.io/doc/getting-started.html#getting-started" target="blank">registering your project</a>.
