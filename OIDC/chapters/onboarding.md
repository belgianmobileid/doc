# Onboarding

To make use of our services, you will need to contact our Customer Care team at <a href="mailto:onboarding@itsme-id.com">onboarding@itsme-id.com</a>. Based on your requirements, they will invite you to our self-service Portal where you will be able to configure an account.  A clientID will be generated, linked to your account, that you will need to include in your <a href="#AuthNReq" >Authorization Request</a>.

Each partner can contain multiple "services". Each service should correspond to one user flow at your side and can be of type Authentication, Identification or Confirmation. The service code will also be required in your Authorization Request.

For each service, you will have to provide one or a few "redirect_uri", which are the landing page(s) where the end user will be sent after authenticating with itsme. Only the URIs whitelisted in a service will be allowed in your Authorization Request, so they have to be fully determined before you can use the service. This whitelisting works on an "exact match" basis, including the full (case sensitive) path and query string so please communicate the exact string you are planning to use in your Authorization Request.


