+++
categories = ["dev"]
date = "2016-05-23T15:47:21+02:00"
title = "From zero to camt.li"
+++

Our software company [Epsitec SA](http://www.epsitec.ch) is the
editor of mulitple Swiss ERP components (accounting, salaries,
billing) known as Crésus.

While partnering with [PostFinance](http://www.postfinance.ch) on
the path to the new [ISO-20022 payment standards](http://www.paymentstandards.ch/)
in Switzerland, we implemented support for the `pain.001` payment
order and for the `camt.05x` cash management notifications.

Crésus understands the various `camt.05x` messages and extracts
information pertaining to invoice slips with reference number
(ISR, in German ESR and in French BVR), so that open invoices
can be marked as being paid.

PostFinance is the first financial institute on the Swiss marketplace
to provide the full ISO-20022 stack to Small and Medium Enterprises,
while Crésus is the first software providing a solution for the Swiss
French market.

A first batch of a few hundred customers have been switched from
the old V11 ISR-notifications to the new `camt-054` notifications.
The users previously only got V11 files whenever ISR data was available.
But now, they get camt files for multiple different reasons. And our
support team has to explain why nothing happens in Crésus when it is
fed with a camt which has no ISR information.

## Realization: parsing XML is a machine's mission

At first, I was tempted to train our staff to be able to read the
XML files and locate the various tags, and to explain what they mean
and how they are processed by our software. But that's really not a
job for the humans!

On Friday, I decided to give the idea some thought:

* I decided it would be best implemented as a simple and easy to
  use client-side only web form. No need to install any software.
  No need to upload the user's data to our servers.  **5 minutes**
* I hunted for a good domain name at [Infomaniak](http://www.infomaniak.ch)
  but those I was aiming at were already taken (iso.info, camt.info,
  camt.ch, etc.) so I finally settled on `camt.li` and purchased the
  domain name including free basic web hosting (10MB space and 1GB/month
  worth of bandwidth). **45 minutes**
* I googled for drag and drop handling in HTML5 and finally found
  [this HTML5Rocks article](http://www.html5rocks.com/en/tutorials/file/dndfiles/)
  which provides enough guidance to get me started.  **20 minutes**

## Now let's start coding...

On Sunday evening, I played a bit with a simple HTML page with
an embedded ES5 `<script>` element, just to test if I my understanding
of the drag and drop mechanisms were sound.  **30 minutes**

On Monday morning, I started by creating a `package.json` file with
`npm init`, created a git repository and pushed a first draft to a
public [GitHub repository](https://github.com/epsitec/camt.li). **20 minutes**

On my workstation, Skype decided to upgrade itself, blocking any work
for at least **40 minutes** until I killed it. And then I started to
be productive again: `npm install --save-dev` my preferred environment
packages (`generic-js-env` and `babel-env`), added a compilation step
so that I could write my JavaScript as ES6, added a `watch` script
based on `chokidar-cli`, etc. **35 minutes**

I then wondered why my `ES6` didn't get transpiled to `ES5` and why
IE was not displaying anything... until I realized that I was using
my default settings which are targetting a V8 engine which supports
most of `ES6` and that I'd have to change `.babelrc` to include
the proper _prerequisites_:

```json
{
  "presets": [
    "stage-0",
    "es2015"
  ],
  "plugins": [
    "transform-react-display-name",
    "transform-decorators",
    "transform-class-properties",
    "transform-es2015-classes"
  ]
}
```

After breakfast, I spent **90 minutes** chewing on the `*.xml` files
in order to grab the meaningful camt elements and display them in
a user friendly way.

And this afternoon I spend **15 additional minutes** to add support
for the `<Bal>` elements in order to display information about opening
booked and closing booked balues found in `camt-053`.

Total: **3.5 hours** spent working on this tiny side-project, and a
little less than 45 minutes on this blog post.

## And now?

The output of http://camt.li is currently really ugly and it would
require some CSS to make it more readable. And the JavaScript has
been hacked together as a single file, without all the required care
for a customer-facing product. But for now, it does the job well
enough, so I'll let it stay there for the next days. Until I get some
itch to improve it, that is.
