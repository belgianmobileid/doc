---
layout: page
title: Test
permalink: /test/
nav_exclude: true
---

Voilà une page de test de Jekyll

### First tabs

{% tabs truc %}

{% tab truc js %}

tagada

{% endtab %}

{% tab truc ruby %}

tsoin tsoin

{% endtab %}

{% endtabs %}

### Second tabs

{% tabs data-struct %}

{% tab data-struct yaml %}

hello:
  - 'whatsup'
  - 'hi'

{% endtab %}

{% tab data-struct json %}

{
    "hello": ["whatsup", "hi"]
}

{% endtab %}

{% endtabs %}

## testing code snippet

```js
// Javascript code with syntax highlighting.
var fun = function lang(l) {
  dateformat.i18n = require('./lang/' + l)
  return true;
}
```

```
$ npm install -g yo generator-itsme
```

<code style=display:block;white-space:pre-wrap>$ npm install -g yo generator-itsme</code>

<table>
  <thead>
    <tr>
      <th>Parameter</th><th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>{% include parameter.html name="Param1" req="required" %}</td>
      <td>
        Global description of Param1<br />
        <table>
          <tr>
            <td>{% include parameter.html name="subparam1" req="optional" %}</td><td>description of subparam1</td>
          </tr>
          <tr>
            <td>{% include parameter.html name="subparam2" req="required" %}</td><td>description of subparam2</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td>{% include parameter.html name="Param2" req="optional" %}</td>
      <td>Global description of Param2 </td>
    </tr>
  </tbody>
</table>