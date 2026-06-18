## PING callback

This callback will only happen if your service is configured for Ping mode.

Once the end user has confirmed the action in their itsme® app, we will send a POST request on your preregistered callback endpoint. That request will contain your <code>client_notification_token</code> as a bearer token. It will use the <code>application/json</code> media type and will only contain the <code>auth_req_id</code> as body content.

You should respond to that callback by calling the endpoint <code>POST /token</code>.

### Example

```http
POST /cb HTTP/1.1
Host: idp.[e2e/prd].itsme.services
Authorization: Bearer 8d67dc78-7faa-4d41-aabd-67707b374255
Content-Type: application/json

{"auth_req_id": "1c266114-a1be-4252-8ad1-04986c5b9ac1"}
```

