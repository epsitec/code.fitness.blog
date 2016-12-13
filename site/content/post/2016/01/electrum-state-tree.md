+++
categories = ["electrum"]
date = "2016-01-26T06:35:32+01:00"
title = "The Electrum State tree"
+++

[`electrum-store`](https://github.com/epsitec-sa/electrum-store) is
getting more and more mature. It provides a simple model of a _writable_
**immutable tree**. This is an oxymoron, but is nevertheless true. Let
me explain it here...

The tree is managed by the `Store`. At the root of the tree is the `root`
node. 

```javascript
const store = Store.create ();
const root = store.root;
```

Every node in the tree is represented by an instance of the `State`
class. The node can store values, which are accessed with `get (id)`.
Just like the tree itself, every node is immutable, yet _writable_.

## Walking the tree

Any node in the tree can be reached directly with `select (path)`
or `find (path)`:

```javascript
const store = Store.create ();
const node = store.select ('staff.peter.age');
```

Selecting a node which **does not exist** in the tree will create it
and produce a new instance of the whole tree. This means that if
a user holds a reference onto the old tree, she won't see any
change. To see the updated tree, she has to query the store again:

```javascript
const store = Store.create ();
const root1 = store.root;
const node1 = store.select ('a.b.c');
const root2 = store.root; // this is the root of the new tree

expect (root1.find ('a.b.c')).to.not.exist ();
expect (root2.find ('a.b.c')).to.exist ();
```

What's happening under the covers is that any modification of a
node (such as adding a new child node or setting a value) will
create a copy of the node, recursively up to the root of the tree.

The original data structure is **immutable** but the API exposes
mutation methods which produce new snapshots of the immutable tree,
hence making the tree writable.

## Beware of the writable immutability

When mutating the immutable tree or its nodes, it is important to
keep in mind what's happening behind the scenes. This code will not
produce what would be expected of a _mutable_ data structure:

```javascript
const store = Store.create ();
const node = store.select ('a.b');
node.set ('x', 10); // node remains unchanged
node.set ('y', 20); // node remains unchanged
```

In this example, the resulting tree would have a node `a.b` with
a single value `y` set to 20:

* `node.set ('x', 10)` &rarr; produces a new node for `a.b`, which
  in turn updates node `a` and the root of the tree. At this point
  in time, `store.find ('a.b').get ('x') === 10`.
* `node.set ('y', 20)` &rarr; starts with the node of the original
  tree (where node `a.b` is empy), since the `node` instance was not
  updated, but copied; so this call produces another node for `a.b`,
  which in turn updates node `a` and the root of the tree. At this
  point in time, `store.find ('a.b').get ('y') === 20`.

The tree where the value `x` was set to `10` was lost.

To set both `x` and `y` values on the node `a.b`, the code has to
refresh the node being used:

```javascript
const store = Store.create ();
let node = store.select ('a.b');
node = node.set ('x', 10);
node = node.set ('y', 20);
```

As you can see, `set ('x', 10)` returns a new node instance, which
belongs to the new tree. Applying `set ('y', 20)` on the new node
will update the new tree, thus resulting in the expected outcome:

```javascript
expect (store.find ('a.b').get ('x')).to.equal (10);
expect (store.find ('a.b').get ('y')).to.equal (20);
```


