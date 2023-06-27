## Mapping the user

### Mapping using <code>sub</code> claim

To sign in successfully in your web desktop, mobile web or mobile application, a given user must be mapped to a user account in your database. By default, your application Server will use the subject identifier, or <code>sub</code> claim, in the ID Token to identify and verify a user account. The <code>sub</code> claim is a string that uniquely identifies a given user account. The benefit of using a <code>sub</code> claim is that it will not change, even if other user attributes (email, phone number, etc) associated with that account are updated.

If no user record is storing the <code>sub</code> claim value, then you should allow the user to associate his new or existing account to the <code>sub</code>.

### Benefit of <code>sub</code> claim

The benefit of using a <code>sub</code> claim is that it will not change, not even if other user attributes (email, phone number, etc.) associated with that account are updated.

### Deleting and re-creating an itsme® account

In a limited number of cases (e.g. technical issue,…) a user could ask itsme® to ‘delete’ his account. As a result the specific account will be ‘archived’ (for compliancy reasons) and thus also the unique identifier(s) (e.g. "sub").

If the same user would opt to re-create an itsme® afterwards, he will need to re-bind his itsme® account with your application server, in the same way as for the initial binding. After successful re-binding you will need to overwrite the initial reference with the new <code>sub</code> claim value in your database.