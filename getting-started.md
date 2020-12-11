---

layout: page
title: Getting started
permalink: /getting-started
nav_order: 2

---

<a name="Onboarding"></a>
# Getting started

In order to start your integration we will first set-up your personal Sanbox environment. To do this you will be requested to provide the following information :  

<ul>
  <li>Contact details such as your email, name, phone number.</li>
  <li>Organisation details as shown on the company register for your jurisdiction.</li>
  <li>Information about the project you want to set-up (the services you want to use, the client authentication method you want to set-up, the user attributes you want to request, ...)</li>
</ul>

Our onboarding team will review your project and get in touch within 3 days with your credentials:
<ul>
  <li>a <i>"client_id"</i></li>
  <li>a <i>"service_code"</i></li>
  <li>information about your <a href="https://belgianmobileid.github.io/doc/getting-started.html#authentication" target="blank">client authentication method</a></li>
  <li>the list of user attributes you can request</li>
</ul>

<br><br><button type="button"><a href="https://docs.google.com/forms/d/e/1FAIpQLSdyfhKiiehNg4DhFzhQeHaj9EG2VeFoyPNVaI-TSwnG5WlFfw/viewform" target="blank">Request your Sandbox</a></button>


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
