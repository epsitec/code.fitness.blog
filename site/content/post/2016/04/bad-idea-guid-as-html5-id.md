+++
categories = ["html", "js"]
date = "2016-04-21T09:29:12+02:00"
title = "A bad idea: GUIDs as DOM elements IDs"
+++

I am using GUIDs as ids for HTML elements. Sometimes my code works,
sometimes it does not.

```html
<span id="b61efa7a-a7a4-4cc1-bc3c-9dffc724d541">Hello</span>
<span id="441c901f-3b33-4c8b-829f-c8ba297b0f14">world</span>
```

In this example, I can select `Hello`, but not `world` using the
JavaScript document API.

## Format of an HTML5 id

The MDN documentation for the [id global attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/id)
states that the ID should start with a letter for compatibility, but that
this restriction has been lifted in HTML 5.

Indeed, checking the W3C HTML5 specification for the
[id attribute](http://www.w3.org/TR/html5/dom.html#the-id-attribute),
I see this:

> Note: There are no other restrictions on what form an ID can take;
> in particular, IDs can consist of just digits, start with a digit,
> start with an underscore, consist of just punctuation, etc.

In my example, `world` is identified by an ID starting with a digit,
and that seems to be the problem. 

## Numeric IDs should work, but they don't

When working with IDs in Chrome, I systematically get an error when
the ID selector starts with a digit, as some manual testing proves:

```javascript
document.querySelector ('#foo'); // returns null
document.querySelector ('#123'); // throws a DOMException, not a valid selector
```

So I went on and double checked the [CSS3 ID selectors](http://www.w3.org/TR/css3-selectors/#id-selectors)
specification of the W3C. It does not define what a valid ID is, but
simply points to the CSS 2.1 documentation on
[CSS identifiers](http://www.w3.org/TR/CSS21/syndata.html#value-def-identifier).

> In CSS, idenfiers [...] cannot not start with a digit, two hyphens
> or a hyphen followed by a digit.

This is in contradiction with the HTML 5 DOM. And `querySelector`
still sticks to the old CSS 2.1 rules.

## Workaround

Thankfully, there is a workaround (see also this [StackOverflow](http://stackoverflow.com/questions/5672903/can-i-have-a-div-with-id-as-number) question),
which is to escape the first digit:

```javascript
document.querySelector ('#\31 23'); // selects id 123
```

The `\31` escape maps to digit `1`.

Note the **space** after the `\31`. Without the space,
the string would be parsed as `\3123` which would map to Unicode
`0C33 ళ TELUGU LETTER LLA`.

## Fix

I don't like workarounds. If I can live without them, I feel more
comfortable. So what are my other options?

* Do not use GUIDs &rArr; that would require quite some bit of work in
  my libraries; it is too much effort.
* Prefix the GUIDs when using them as HTML5 ids &rArr; that would be
  require changes in my parsing code to ensure that I strip the prefix
  when reading an `id` attribute.
* Filter the GUIDs to discard those which start with a digit &rArr;
  this is easy, but will require possibly multiple attempts before a
  suitable GUID is generated.
* Patch the GUIDs to ensure they start with a digit &rArr; since most
  of the bits in a GUID are random, I could set bit 7 and 6 of byte 3,
  which would guarantee that my GUIDs always start with `c`, `d`, `e`
  or `f`.
* Rewrite a GUID generator &rArr; it is probably not worth the effort
  which guarantees that the first character is a letter.

I could be even less subtle and simply replace the first letter
of the generated GUID with an `f`.

## Implemented solution

```csharp
public static System.Guid EnsureStartsWithLetter(System.Guid guid)
{
    var bytes = guid.ToByteArray ();

    if ((bytes[3] & 0xf0) < 0xa0)
    {
        bytes[3] |= 0xc0;
        return new System.Guid (bytes);
    }
    return guid;
}
```
