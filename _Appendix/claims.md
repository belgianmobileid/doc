---
layout: bigtable
title: Claims availability
permalink: claims/
nav_exclude: false

---

# Introduction
  
  itsme® accounts are always created from an official ID document (eID card, passport...). However, each country can choose which attributes are presents on those documents so that, depending on the user's country, some itsme® accounts can contain more/different data than others.
  You will find below a list of all attributes ("claims") supported by itsme® and their availability per country.
  
  <aside class="notice">The availability of the claims does NOT depend on the nationality of the user but only on the issuing country of their ID document. Example: a Dutch citizen living in Belgium can create an itsme® account either with his Dutch eID or with his Belgian residents card. If he chooses to do so with his Belgian card, his address and gender will be available, while they won't if he uses his Dutch eID.
  </aside>

# Claims

How to understand the table below:

**SHALL**: A value shall always be returned.<br>
**MAY NOT**: Best-effort - will return a value in most cases but it may not be possible for some accounts.<br>
**SHALL NOT**: This values is never available.

<table>
  <tbody>
    <tr>
      <th>Claim</th>
      <th>Description</th>
      <th>Belgium</th>
      <th>Netherlands</th>
      <th>Luxembourg</th>
      <th>Ireland</th>
      <th>Portugal</th>
      <th>Italy</th>
      <th>France</th>
      <th>Spain</th>
      <th>United Kingdom</th>
      <th>Germany</th>
      <th>Finland</th>
      <th>Norway</th>
      <th>Sweden</th>
      <th>Denmark</th>
      <th>Iceland</th> -->
      <th>Estonia</th>
      <th>Romania</th>
    </tr>
    <tr>
      <td><b>name</b></td>
      <td>User's full name in displayable form including all name parts, possibly including titles and suffixes.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>given_name</b></td>
      <td>User's given name(s) or first name(s). Note that in some cultures, people can have multiple given names or none at all; all can be present, separated by space characters.</td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>MAY NOT</td> <!-- Netherlands -->
      <td>MAY NOT</td> <!-- Luxembourg -->
      <td>MAY NOT</td> <!-- Ireland -->
      <td>MAY NOT</td> <!-- Portugal -->
      <td>MAY NOT</td> <!-- Italy -->
      <td>MAY NOT</td> <!-- France -->
      <td>MAY NOT</td> <!-- Spain -->
      <td>MAY NOT</td> <!-- UK -->
      <td>MAY NOT</td> <!-- Germany -->
      <td>MAY NOT</td> <!-- Finland -->
      <td>MAY NOT</td> <!-- Norway -->
      <td>MAY NOT</td> <!-- Sweden -->
      <td>MAY NOT</td> <!-- Denmark -->
      <td>MAY NOT</td> <!-- Iceland -->
      <td>MAY NOT</td> <!-- Estonia -->
      <td>MAY NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>family_name</b></td>
      <td>User's surname(s) or last name(s). Note that in some cultures, people can have multiple family names or none; all can be present, separated by space characters.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>birthdate</b></td>
      <td>User's birthdate, represented as a string in YYYY-MM-DD date format. itsme® users are always 16 years old or more.</td>
      <td>MAY NOT<br>At least one of <i>birthdate</i> or <i>birthdate_as_string</i> will always be available.</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>birthdate_as_string</b></td>
      <td>User's birthdate in an unprocessed way, exactly as mentioned on the ID document. itsme® users are always 16 years old or more.</td>
      <td>MAY NOT<br>At least one of <i>birthdate</i> or <i>birthdate_as_string</i> will always be available.</td> <!-- Belgium -->
      <td>SHALL NOT</td> <!-- Netherlands -->
      <td>SHALL NOT</td> <!-- Luxembourg -->
      <td>SHALL NOT</td> <!-- Ireland -->
      <td>SHALL NOT</td> <!-- Portugal -->
      <td>SHALL NOT</td> <!-- Italy -->
      <td>SHALL NOT</td> <!-- France -->
      <td>SHALL NOT</td> <!-- Spain -->
      <td>SHALL NOT</td> <!-- UK -->
      <td>SHALL NOT</td> <!-- Germany -->
      <td>SHALL NOT</td> <!-- Finland -->
      <td>SHALL NOT</td> <!-- Norway -->
      <td>SHALL NOT</td> <!-- Sweden -->
      <td>SHALL NOT</td> <!-- Denmark -->
      <td>SHALL NOT</td> <!-- Iceland -->
      <td>SHALL NOT</td> <!-- Estonia -->
      <td>SHALL NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>gender</b></td>
      <td>User's gender. Possible values are: <code>female</code> <code>male</code> <code>unknown</code> <code>n/a</code>. If the value mentioned on the user's ID document is different from those (local language, letter code...), then we apply a best-effort mapping to one of those values.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>MAY NOT</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>official_gender</b></td>
      <td>User's gender unaltered, exactly as mentioned on their ID document.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>MAY NOT</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>locale</b></td>
      <td>User's itsme app language, represented as a string format. Possible values are : <code>NL</code> <code>FR</code> <code>DE</code> <code>EN</code></td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>MAY NOT</td> <!-- Netherlands -->
      <td>MAY NOT</td> <!-- Luxembourg -->
      <td>MAY NOT</td> <!-- Ireland -->
      <td>MAY NOT</td> <!-- Portugal -->
      <td>MAY NOT</td> <!-- Italy -->
      <td>MAY NOT</td> <!-- France -->
      <td>MAY NOT</td> <!-- Spain -->
      <td>MAY NOT</td> <!-- UK -->
      <td>MAY NOT</td> <!-- Germany -->
      <td>MAY NOT</td> <!-- Finland -->
      <td>MAY NOT</td> <!-- Norway -->
      <td>MAY NOT</td> <!-- Sweden -->
      <td>MAY NOT</td> <!-- Denmark -->
      <td>MAY NOT</td> <!-- Iceland -->
      <td>MAY NOT</td> <!-- Estonia -->
      <td>MAY NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>picture</b></td>
      <td>User's ID picture, represented as a URL string. This URL points to an image file (for example, a JPEG, JPEG2000, or PNG image file). This image is the raw (unprocessed) image contained on the ID document.<br />
      Accessing this URL has to be done with your bearer token. Example:<br />
            <code>
              GET /v2/picture HTTP/1.1<br />
              Host: idp.prd.itsme.services<br />
              Authorization: Bearer SlAV32hkKG
            </code></td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>physical_person_photo</b></td>
      <td>User's ID picture, represented as a JSON Object containing these members:<br><code>format</code>: the MIME type<br><code>value</code>: the base64 encoded image.<br><br>This picture is read from the ID document but converted to always return a 200x140px, 24 BPP JPEG image.</td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>email</b></td>
      <td>User's email address.</td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>MAY NOT</td> <!-- Netherlands -->
      <td>MAY NOT</td> <!-- Luxembourg -->
      <td>MAY NOT</td> <!-- Ireland -->
      <td>MAY NOT</td> <!-- Portugal -->
      <td>MAY NOT</td> <!-- Italy -->
      <td>MAY NOT</td> <!-- France -->
      <td>MAY NOT</td> <!-- Spain -->
      <td>MAY NOT</td> <!-- UK -->
      <td>MAY NOT</td> <!-- Germany -->
      <td>MAY NOT</td> <!-- Finland -->
      <td>MAY NOT</td> <!-- Norway -->
      <td>MAY NOT</td> <!-- Sweden -->
      <td>MAY NOT</td> <!-- Denmark -->
      <td>MAY NOT</td> <!-- Iceland -->
      <td>MAY NOT</td> <!-- Estonia -->
      <td>MAY NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>email_verified</b></td>
      <td>Returns <code>true</code> if the user's e-mail address is verified or <code>false</code> otherwise.<br><br><b>Note</b> : currently always returns <code>false</code> because no email verification is implemented in our systems at this stage.</td>
      <td>Only if "email" available</td> <!-- Belgium -->
      <td>Only if "email" available</td> <!-- Netherlands -->
      <td>Only if "email" available</td> <!-- Luxembourg -->
      <td>Only if "email" available</td> <!-- Ireland -->
      <td>Only if "email" available</td> <!-- Portugal -->
      <td>Only if "email" available</td> <!-- Italy -->
      <td>Only if "email" available</td> <!-- France -->
      <td>Only if "email" available</td> <!-- Spain -->
      <td>Only if "email" available</td> <!-- UK -->
      <td>Only if "email" available</td> <!-- Germany -->
      <td>Only if "email" available</td> <!-- Finland -->
      <td>Only if "email" available</td> <!-- Norway -->
      <td>Only if "email" available</td> <!-- Sweden -->
      <td>Only if "email" available</td> <!-- Denmark -->
      <td>Only if "email" available</td> <!-- Iceland -->
      <td>Only if "email" available</td> <!-- Estonia -->
      <td>Only if "email" available</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>phone_number</b></td>
      <td>User's phone number, represented as a string format. For example : <code>[+][country code] [subscriber number including area code]</code>.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>phone_number_verified</b></td>
      <td>Returns <code>true</code> if the user's phone number is verified or <code>false</code> otherwise.<br><b>Note</b>: currently, all phone numbers are verified so this claim always returns <code>true</code>.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td><b>address</b></td>
      <td>User's postal address, represented as JSON Object containing some or all of these members: <code>formatted</code> <code>street_address</code> <code>postal_code</code> <code>locality</code>.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL NOT</td> <!-- Netherlands -->
      <td>SHALL NOT</td> <!-- Luxembourg -->
      <td>SHALL NOT</td> <!-- Ireland -->
      <td>SHALL NOT</td> <!-- Portugal -->
      <td>SHALL NOT</td> <!-- Italy -->
      <td>SHALL NOT</td> <!-- France -->
      <td>SHALL NOT</td> <!-- Spain -->
      <td>SHALL NOT</td> <!-- UK -->
      <td>SHALL NOT</td> <!-- Germany -->
      <td>SHALL NOT</td> <!-- Finland -->
      <td>SHALL NOT</td> <!-- Norway -->
      <td>SHALL NOT</td> <!-- Sweden -->
      <td>SHALL NOT</td> <!-- Denmark -->
      <td>SHALL NOT</td> <!-- Iceland -->
      <td>SHALL NOT</td> <!-- Estonia -->
      <td>SHALL NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>claim_citizenship</b></td>
      <td>User's nationality unaltered, exactly as mentioned on the ID document.</td>
      <td>SHALL<br>String (e.g. <code>belge</code>)</td> <!-- Belgium -->
      <td>SHALL<br><a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a></td> <!-- Netherlands -->
      <td>SHALL<br><a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a></td> <!-- Luxembourg -->
      <td>SHALL<br><a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a></td> <!-- Ireland -->
      <td>SHALL<br><a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a></td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>claim_citizenship_as_iso</b></td>
      <td>User's nationality. The format is always <a href="https://en.wikipedia.org/wiki/ISO_3166" target="blank">ISO 3166-1 alpha-3</a>.</td>
      <td>MAY NOT<br>Mapped by itsme® on a best effort basis</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>place_of_birth</b></td>
      <td>User's place of birth, represented as a JSON Object containing some or all of these members <code>formatted</code> <code>city</code> <code>country</code>.</td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>SHALL NOT</td> <!-- Netherlands -->
      <td>SHALL NOT</td> <!-- Luxembourg -->
      <td>SHALL NOT</td> <!-- Ireland -->
      <td>SHALL NOT</td> <!-- Portugal -->
      <td>SHALL NOT</td> <!-- Italy -->
      <td>SHALL NOT</td> <!-- France -->
      <td>SHALL NOT</td> <!-- Spain -->
      <td>SHALL NOT</td> <!-- UK -->
      <td>SHALL NOT</td> <!-- Germany -->
      <td>SHALL NOT</td> <!-- Finland -->
      <td>SHALL NOT</td> <!-- Norway -->
      <td>SHALL NOT</td> <!-- Sweden -->
      <td>SHALL NOT</td> <!-- Denmark -->
      <td>SHALL NOT</td> <!-- Iceland -->
      <td>SHALL NOT</td> <!-- Estonia -->
      <td>SHALL NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>BEeidSn</b></td>
      <td>User's Belgian ID document number, represented as a string with 12 digits in the form <code>xxx-xxxxxxx-yy</code>. (the check-number yy is the remainder of the division of xxxxxxxxxx by 97) for Belgian citizens, or starting with a letter and nine digits in the form <code>B xxxxxxx xx</code> for EU/EEA/Swiss citizens.<br><b>Note</b>: This claim is made redundant by the <i>IDDocumentSN</i> claim below which we advise to use instead.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL NOT</td> <!-- Netherlands -->
      <td>SHALL NOT</td> <!-- Luxembourg -->
      <td>SHALL NOT</td> <!-- Ireland -->
      <td>SHALL NOT</td> <!-- Portugal -->
      <td>SHALL NOT</td> <!-- Italy -->
      <td>SHALL NOT</td> <!-- France -->
      <td>SHALL NOT</td> <!-- Spain -->
      <td>SHALL NOT</td> <!-- UK -->
      <td>SHALL NOT</td> <!-- Germany -->
      <td>SHALL NOT</td> <!-- Finland -->
      <td>SHALL NOT</td> <!-- Norway -->
      <td>SHALL NOT</td> <!-- Sweden -->
      <td>SHALL NOT</td> <!-- Denmark -->
      <td>SHALL NOT</td> <!-- Iceland -->
      <td>SHALL NOT</td> <!-- Estonia -->
      <td>SHALL NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>claim_device</b></td>
      <td>User's phone information, represented as a JSON Object containing some or all of these members <code>os</code> <code>appName</code> <code>appRelease</code> <code>deviceLabel</code> <code>debugEnabled</code> <code>deviceID</code>	<code>osRelease</code> <code>manufacturer</code> <code>deviceLockLevel</code> <code>rooted</code> <code>deviceModel</code>.</td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>MAY NOT</td> <!-- Netherlands -->
      <td>MAY NOT</td> <!-- Luxembourg -->
      <td>MAY NOT</td> <!-- Ireland -->
      <td>MAY NOT</td> <!-- Portugal -->
      <td>MAY NOT</td> <!-- Italy -->
      <td>MAY NOT</td> <!-- France -->
      <td>MAY NOT</td> <!-- Spain -->
      <td>MAY NOT</td> <!-- UK -->
      <td>MAY NOT</td> <!-- Germany -->
      <td>MAY NOT</td> <!-- Finland -->
      <td>MAY NOT</td> <!-- Norway -->
      <td>MAY NOT</td> <!-- Sweden -->
      <td>MAY NOT</td> <!-- Denmark -->
      <td>MAY NOT</td> <!-- Iceland -->
      <td>MAY NOT</td> <!-- Estonia -->
      <td>MAY NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>BENationalNumber</b></td>
      <td>User's Belgian unique identification number, represented as a string with 11 digits in the form YYMMDDxxxcd where YY.MM.DD is the birthdate of the person, xxx a sequential number (odd for males and even for females) and cd a check-digit (Some exceptions could apply).</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL NOT</td> <!-- Netherlands -->
      <td>SHALL NOT</td> <!-- Luxembourg -->
      <td>SHALL NOT</td> <!-- Ireland -->
      <td>SHALL NOT</td> <!-- Portugal -->
      <td>SHALL NOT</td> <!-- Italy -->
      <td>SHALL NOT</td> <!-- France -->
      <td>SHALL NOT</td> <!-- Spain -->
      <td>SHALL NOT</td> <!-- UK -->
      <td>SHALL NOT</td> <!-- Germany -->
      <td>SHALL NOT</td> <!-- Finland -->
      <td>SHALL NOT</td> <!-- Norway -->
      <td>SHALL NOT</td> <!-- Sweden -->
      <td>SHALL NOT</td> <!-- Denmark -->
      <td>SHALL NOT</td> <!-- Iceland -->
      <td>SHALL NOT</td> <!-- Estonia -->
      <td>SHALL NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>RONationalNumber</b></td>
      <td>User's Romanian unique identification number.</td>
      <td>SHALL NOT</td> <!-- Belgium -->
      <td>SHALL NOT</td> <!-- Netherlands -->
      <td>SHALL NOT</td> <!-- Luxembourg -->
      <td>SHALL NOT</td> <!-- Ireland -->
      <td>SHALL NOT</td> <!-- Portugal -->
      <td>SHALL NOT</td> <!-- Italy -->
      <td>SHALL NOT</td> <!-- France -->
      <td>SHALL NOT</td> <!-- Spain -->
      <td>SHALL NOT</td> <!-- UK -->
      <td>SHALL NOT</td> <!-- Germany -->
      <td>SHALL NOT</td> <!-- Finland -->
      <td>SHALL NOT</td> <!-- Norway -->
      <td>SHALL NOT</td> <!-- Sweden -->
      <td>SHALL NOT</td> <!-- Denmark -->
      <td>SHALL NOT</td> <!-- Iceland -->
      <td>SHALL NOT</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>validityFrom</b></td>
      <td>This is a <a href="https://belgianmobileid.github.io/doc/authentication/#metadata">metadata</a>.<br>User's Belgian ID document issuance date, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. Can only be returned in combination with claims <i>http://itsme.services/v2/claim/BEeidSn</i> or <i>http://itsme.services/v2/claim/IDDocumentSN</i>.</td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>SHALL NOT</td> <!-- Netherlands -->
      <td>SHALL NOT</td> <!-- Luxembourg -->
      <td>SHALL NOT</td> <!-- Ireland -->
      <td>SHALL NOT</td> <!-- Portugal -->
      <td>SHALL NOT</td> <!-- Italy -->
      <td>SHALL NOT</td> <!-- France -->
      <td>SHALL NOT</td> <!-- Spain -->
      <td>SHALL NOT</td> <!-- UK -->
      <td>SHALL NOT</td> <!-- Germany -->
      <td>SHALL NOT</td> <!-- Finland -->
      <td>SHALL NOT</td> <!-- Norway -->
      <td>SHALL NOT</td> <!-- Sweden -->
      <td>SHALL NOT</td> <!-- Denmark -->
      <td>SHALL NOT</td> <!-- Iceland -->
      <td>SHALL NOT</td> <!-- Estonia -->
      <td>SHALL NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>validityTo</b></td>
      <td>This is a <a href="https://belgianmobileid.github.io/doc/authentication/https://belgianmobileid.github.io/doc/authentication/#metadata">metadata</a>.<br>User's Belgian ID card expiry date, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. Can only be returned in combination with claims <i>http://itsme.services/v2/claim/BEeidSn</i> or <i>http://itsme.services/v2/claim/IDDocumentSN</i>.</td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>verificationDate</b></td>
      <td>This is a <a href="https://belgianmobileid.github.io/doc/authentication/#metadata">metadata</a>.<br>The date when the user's document was read for the last time, represented as a string in YYYY-MM-DDThh:mm:ss date format specified by ISO 8601.</td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>IDDocumentSN</b></td>
      <td>The ID document number, represented as a string.</td>
      <td>SHALL<br>A string with 12 digits formatted as <code>xxx-xxxxxxx-yy</code> (the check-number yy is the remainder of the division of xxxxxxxxxx by 97) for Belgian citizens, or starting with a letter and nine digits in the form B xxxxxxx xx for EU/EEA/Swiss citizens.</td> <!-- Belgium -->
      <td>SHALL<br>A 9-chars string with letters at positions 1 and 2, letters or digits in positions 3 to 8 and a digit at position 9. The letter ‘O’ is not used in the NL document numbers. The digit ‘0’ (zero) MAY be used.</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>IDDocumentType</b></td>
      <td>The ID document type. This is a 1 or 2 characters code defined by the ICAO. Identity cards have a code with first letter <code>I</code> while passports have a code starting with <code>P</code>.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>IDIssuingCountry</b></td>
      <td>This is a <a href="https://belgianmobileid.github.io/doc/authentication/#metadata">metadata</a>.<br>The 3-letters iso code of the country that issued the identity document used to create the itsme® account.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>issuance_locality</b></td>
      <td>This is a <a href="https://belgianmobileid.github.io/doc/authentication/#metadata">metadata</a>.<br>The locality that issued the ID document used to create the itsme® account.</td>
      <td>MAY NOT</td> <!-- Belgium -->
      <td>SHALL NOT</td> <!-- Netherlands -->
      <td>SHALL NOT</td> <!-- Luxembourg -->
      <td>SHALL NOT</td> <!-- Ireland -->
      <td>SHALL NOT</td> <!-- Portugal -->
      <td>SHALL NOT</td> <!-- Italy -->
      <td>SHALL NOT</td> <!-- France -->
      <td>SHALL NOT</td> <!-- Spain -->
      <td>SHALL NOT</td> <!-- UK -->
      <td>SHALL NOT</td> <!-- Germany -->
      <td>SHALL NOT</td> <!-- Finland -->
      <td>SHALL NOT</td> <!-- Norway -->
      <td>SHALL NOT</td> <!-- Sweden -->
      <td>SHALL NOT</td> <!-- Denmark -->
      <td>SHALL NOT</td> <!-- Iceland -->
      <td>SHALL NOT</td> <!-- Estonia -->
      <td>SHALL NOT</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>app</b></td>
      <td>A JSON object with 3 members: <code>appInstalledDate</code> contains the date when the app was installed on the user's device, represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. <code>appName</code> contains the name of the app and <code>appRelease</code> contains a string identifying the release (example: "4.9.1").<br>This claim is intended to help partners detect fraudulent use cases.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>account</b></td>
      <td>A JSON object with 3 members: <code>activationDate</code> contains the date when the account was last activated (enrolled or unblocked), represented as a string in YYYY-MM-DDThh:mm:ss.nnnZ date format specified by ISO 8601. <code>activationMechanism</code> contains a string identifying the way this account was created. Possible values are "CARD_READER" (enrollment via a physical reading of the ID document chip), "CONTACT_LESS" (enrollment via a NFC reading of the ID document) or "ID_PROVIDER" (enrollment via a trusted partner, i.e. a bank).<br>This claim is intended to help partners detect fraudulent use cases.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>
    <tr>
      <td>http://itsme.services/v2/<br>claim/<b>transaction_ip</b></td>
      <td>The IP address of the smartphone approving the transaction.<br>This claim is intended to help partners detect fraudulent use cases.</td>
      <td>SHALL</td> <!-- Belgium -->
      <td>SHALL</td> <!-- Netherlands -->
      <td>SHALL</td> <!-- Luxembourg -->
      <td>SHALL</td> <!-- Ireland -->
      <td>SHALL</td> <!-- Portugal -->
      <td>SHALL</td> <!-- Italy -->
      <td>SHALL</td> <!-- France -->
      <td>SHALL</td> <!-- Spain -->
      <td>SHALL</td> <!-- UK -->
      <td>SHALL</td> <!-- Germany -->
      <td>SHALL</td> <!-- Finland -->
      <td>SHALL</td> <!-- Norway -->
      <td>SHALL</td> <!-- Sweden -->
      <td>SHALL</td> <!-- Denmark -->
      <td>SHALL</td> <!-- Iceland -->
      <td>SHALL</td> <!-- Estonia -->
      <td>SHALL</td> <!-- Romania -->
    </tr>    
  </tbody>
</table>