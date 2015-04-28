
So let's start with the absolute most basic thing that we can possibly try: a blank file.

```

```

Attempting to compile this object results in, well, nothing happening.

```

Propeller Spin/PASM Compiler 'OpenSpin' (c)2012-2014 Parallax Inc. DBA Parallax Semiconductor.

Version 1.00.71 Compiled on Jan 29 2015 19:28:26

Compiling...

HelloNothing.spin

HelloNothing.spin : error : Can not find/open file.

```

That seems pretty obvious. The spin compiler complains because what else is there for it to do? You haven't written any code yet. This leads us to the first lesson of Spin programming.

> **All Spin objects must contain a public function, or a PUB block.**

So let's give the compiler what it wants.

```

PUB Main

```

This is the absolute most basic program that can be downloaded to the Propeller. Unsurprisingly, it does absolutely nothing, but hey, at least it downloaded to your board. It's like you're halfway there.

# More With Nothing

While we have a program that does nothing, let's see how much more we can do with nothing.

## Comments

Comments are notes that you can leave to yourself or whomever will read your code, explaining how it works, describing what it's for, or maybe just telling jokes.

There are two kinds of comments in Spin:

* Single line

* Multi-line

### Single-Line Comments

Whenever an apostrophe character ( ' ) is used, the rest of the line after it becomes a comment.

```

this part is code ' this part is comment

```

When you run your program, the comments will be removed, and only the uncommented part will be downloaded to the LameStation.

```

this part is code

```

So let's comment up `HelloNothing.spin`.

    ' man, this is best code ever!
    ' more code, code and code.
    ' cool this code still does nothing!

When it's compiled, the code still ends up as.

    PUB Main

### Multi-Line Comments

Whenever you add an opening curly brace ( '{' ) to your code, all text that comes after it will be commented out until it reaches a closing curly brace ( '}' ).

    { look at all these comments!
      so commenty; mega comments!
    }

It doesn't matter where you put the curly braces either. As long as you don't add them in the middle of code that's supposed to do something, it should compile fine.

| Bad Code | `PUB Ma{jfd93j23rsdfijsd}in` |

| --- | --- |

| Good Code | `PUB Main {394j39j43433}` |