---
layout: page
title: Test
permalink: /test/
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
