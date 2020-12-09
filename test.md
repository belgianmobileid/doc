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