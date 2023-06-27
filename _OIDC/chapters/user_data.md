## User Data

itsme® is making a range of user data available for its partners. Those can be requested through the <a href="#authorization-request">Authorization Request</a>, individually as "claims" or as part of a broader "scope".
These claims can be split in 2 categories:

### User Attributes

User attributes are saying something about the end user. They are part of the identity of a person and we retrieve them from an identity document (ID card, passport...). Examples: name, address, birthdate, etc.

### Metadata

Metadata are saying something about the data we have for an end user. They are not directly related to a person, but rather to an information about this person. Examples are the validityTo, the verificationDate etc.
Those metadata, if requested, will only return values relating to the user attributes that are also requested. The metadata will then return an object containing one value for each relevant user attribute.

Examples:

* The ```verificationDate``` is a metadata that has a value for most user attributes. So requesting the ```verificationDate``` AND the ```birthdate``` AND the ```given_name``` will return the following pattern for ```verificationDate```:

```json
"http://itsme.services/v2/claim/verificationDate": {
		"birthdate": "2023-06-01T13:04:26Z",
		"given_name": "2023-06-01T13:04:26Z"
	}
```

* Requesting only the ```verificationDate``` will return nothing, as it only returns values for other requested attributes.

* The ```validityTo``` metadata only has a value for ```BEeidSn``` and ```IDDocumentSN``` (because other attributes don't have an expiry date). So ```validityTo``` will only return a value if ```BEeidSn``` and/or ```IDDocumentSN``` is also requested. Even if other attributes are requested, ```validityTo``` will not return a value for those other attributes.