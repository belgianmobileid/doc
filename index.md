---

layout: page
title: Home
permalink: /index
nav_order: 1

---

# Welcome

itsme® API allows partners to use verified identities for authentication and authorization on web desktop, mobile web or mobile applications.

Learn how to integrate our services that you and your business will benefit from. For a more detailed, in-depth explanation of each, please read through the appropriate developer docs.


## itsme® use cases

For more information on how itsme® can best work for your business, please <a href = "mailto: onboarding@itsme.be">contact us</a>. We’re happy to help!.


## Services

Head over to our developer documentation for each our services. Here you will find:

<ul>
  <li>A techical overview</li>
  <li>Step by step instructions on how to integrate</li>
  <li>Code snipplets</li>
</ul>







<a name="Onboarding"></a>
# Prerequisite

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
  <li>information about your <a href="https://belgianmobileid.github.io/slate/v2/test2#selecting-your-client-authentication-method" target="blank">client authentication method</a></li>
  <li>the list of user attributes you can request</li>
</ul>

<br><button type="button"><a href="https://docs.google.com/forms/d/e/1FAIpQLSdyfhKiiehNg4DhFzhQeHaj9EG2VeFoyPNVaI-TSwnG5WlFfw/viewform" target="blank">Request your Sandbox</a></button></br>



# Integration sequence

itsme® integration is based on the Authorization Code Flow of OpenID Connect 1.0. The Authorization Code Flow goes through the steps as defined in OpenID Connect Core Authorization Code Flow Steps, depicted in the following diagram:
  
 ![Sequence diagram describing the OpenID flow](OpenID_Login_SeqDiag.png)

The integration steps, with linked code-level documentation are :

<ol>
  <li>Add itsme® button to your front-end page so the User can indicate he wishes to authenticate with itsme® : <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/buttons-1518207548" target="blank">itsme® button specifications</a></li>.
  <li><a href="https://belgianmobileid.github.io/slate/v2/test2#building-your-authorization-request" target="blank">Create the Authorization Request to authenticate the User.</a>. This request will redirect the User to the itsme® Front-End. itsme® then authenticates the User by asking him
    <ul type>
      <li>to enter his phone number on the <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/ux-flows" target="blank">itsme® OpenID web page</a></li>
      <li>authorize the <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/ux-flows" target="blank">release of some information</a> to your application</li>
      <li>to provide his <a href="https://brand.belgianmobileid.be/d/CX5YsAKEmVI7/documentation#/ux/ux-flows" target="blank">credentials</a> (itsme® code or fingerprint or FaceID)</li>
    </ul>
  <br>It is also in this Authorization Request that you will be able to <a href="https://belgianmobileid.github.io/slate/v2/test2#requesting-claims-about-the-user-and-the-authentication-event" target="blank">request claims about the User and the Authentication event</a></br></li>
  <li>Collect the Authorization Code and redirect the user to your mobile or web application once the User has authorized the request and has been authenticated, </li>
  <li>Exchange the Authorization Code for an ID Token (e.g. identifying the User) and an Access Token.</li>
  <li>Request the additional User information from the itsme® userInfo Endpoint by presenting the Access Token obtained in the previous step.</li>
  <li>Confirm the success of the operation and display a success message.</li>
</ol>
blabla
If a user doesn't have the itsme® app, they'll be redirected to a mobile website with more information and download links.
