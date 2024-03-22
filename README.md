# NuScheme - Store passing Style

## Abstract

This is the Store Passing Style (SPS) version of a MCE Scheme interpreter.

Actually, it is the World passing style  MCE, as the store is embedded
inside a world container along with the environment.
The environment is a cons cell based lookup mechanism which is
very inefficient. because of need to test ideas regarding garbage collection.

## Getting started

First clone this repo, then switch to the 'sps' branch.


Upon first arriving in this directory,

```bash
. .rc

# Now load Nu REPL:
eval_test
```

All the store/environment and world streaming  functions will now be available.

The created world is held in '$env.world' See below for examples of usage.


##### Function naming strategy

Note: TODO:  These function naming strategies are not yet universally applied.
Use the strategy when creating a new function.
Refactor and use rename function when it is safe to do so

There are a variety of function naming cases:

### Inner store and environment functions:


- Query functions, like _null?, _atom?
  * have a single leading underscore '_' and a trailing question mark '?'
  * and return boolean true/false
- deconstructors : like _car, _cdr, _cadr etc
  * have a single leading  underscore '_'
  * takes some item on input like a cons cell, and either just a store or a store and environment as params and returns the internal part
  * Environment  deconstructors must also take a store param as well as the 'nv' param because 'nv' points into the store
- Mutators : like _cons!
  * have a single leading underscore and a trailing bang '!'
  * generally take a store on input and return a new store on output
  * If working with the environment, probably takes a store and returns a new store


### Streaming world functions:

- Streamers : Like __car, __eval and __world-list
  * Start with 2 leading underscores (hereafter called 'dunder'
  * Take a world on input and return a new world on output
  * May update the .result field on output
  * May or may not only work on the previous .result field on input
- Query functions
  * Start with a dunder
  * End with trailing '?'
  * And return boolean true/false
  * Cannot participate in the middle of a stream pipeline, thus must occur at the end of any pipeline or just $env.world
- Mutators
  * Start with a dunder
  * end with a trailing '!' exclamation mark
  * May use .result field as input
  * Returns the (changed) world and may also change the .result field
- Value inspectors
  * Start with a dunder
  * Ends with trailing '=' equal sign
  * Cannot participate in the middle of a stream, and must therefore occur at the end of a pipeline

Note: If a query streamer like '__atom?' or '__null?' will return a new
world on output with the result field set to boolean true or false. These also
probably work on previous .result field on input.


Note 2: You can use '__result' at the end of  the stream to inspect the result
field. It does not return a new store, so it can not participate in further
functions in the pipeline.

Note: There are various alias to make life more ergonomic:

- __mk-list : aliased to __world-list


## The Archetecture

At this point, we are building a set of primitive functions that will eventually lead
to a Meta Circular Evaluator of NuScheme. To this end we need to create:

- A Store for cons cells and primitives
- An Environment which stores values in the store that are looked up with symbols

Because we  are writing this using a Functional Paradigm, we must avoid mutation.
But, we cannot entirely eliminate all mutation. We need 'set!', 'set-car!' and 'set-cdr!'
We can, however, move mutable state to the outer level and not pollute
our pure inner functions.

Thus, we use a World data structure which gets streamed through modifier
functions that return new Worlds. Which are in turned streamed through more modifiers
and return yet more new worlds.

Here is an example, first in Scheme, then in low level NuScheme streaming primatives:

```scheme
; pretty print a constructed cons list of '(11 22 33)
(display (cons 11 (cons 22 (cons 33 '())))
; => "(11 22 33)
```


Now here is the same thing in low level NuScheme World streaming primitives:

```nu
# pretty print the cons list: '(11 22 33
$env.world | __mk-null! | __rcons 33 | __rcons 22 | __rcons 11 | pp
# => "(11 22 33)
```


Note that everything is reversed in contrast to the Scheme example.
But it is not really because of the difference in function composition rules between
Scheme and Nu itself.

In Scheme and other functional languages, we must use this form of function
composition:

Let's say we want to compose 'f' with 'g' with 'h' applied to an argument: 'x'.

```scheme
(f (g (h x)))
; => value of f composed with g composed with h
```

But in Nu, the paradigm is the pipeline like in most Shell languages.
The first argument of any function is (normally) passed in to the function
coming from some other expression on the left of a pipe symbol: '|'.

Here is the same thing in Nu:

```nu
$x | h | g | f
# => f composed with g composed with h
```


For a more complete take on this See: [Function composition in Computer Science: en.wikipedia.org](https://en.wikipedia.org/wiki/Function_composition_(computer_science))


It might not seem natural to express list building in this style
but Nu is mostly a concatenative programming language. and these are only low level
primitive functions..

Note the function '__rcons' above takes a thing that will be the 'D' register
from the last thing on the left and another parameter that will become the 'A'
register in the new cons cell. (There is a corresponding '__cons primitive where
the registers are reversed in the parameters.)


The $env.world is the initial World container upon which we will act upon.
The '__mk-null!' drops a null value (the list terminator) onto the World.
Then, we add a new cons cell with the  value 33 onto that null and return a new World.
This world is passed to another '__rcons' with 22, then '__rcons' 11 for the final
list. To see it, we pipe it into the terminator 'pp' alias (__format-list --pretty)

It might not seeme like it, but that is __EXACTLY__ what the Scheme code is doing
as time progresses. It is merely more explicit in Nu.

## The World

The world data structure is just a record with these fields and values:

- type: 'world' To type cast it (maybe used in match expressions)
- store: '(Atable of cars and cdrs'
- nv: The HEAD of the Environment cons cell chain
- result: The most recent value modified and added to the world
  * Maybe the input to the next streamer function in the pipeline
- stack: A temporary storage place.

As time goes on, we might also include : 'continuation'


There is an initial World stored in $env.world.
It can be mutated by any of our actions. You can use the'kworld' alias of 'collect --keep-env {|w| $env.world = $w }
to modified it for inspection or whatever. The functions in 'global.nu' do just that.



```nu
# Add a 14 onto the world and save it
$env.world | __mk-atom 14 | kworld
$env.world.result
# => 14
```


Of course, there are more aggregate functions to make life easier:

```nu
$env.world | __mk-list 11 22 33 | pp
# => '(11 22 33)
```




## The Store

The store is implemented as a Nu table with columns: cars and cdrs. When you call
cons you pass the existing store to its input and the parameters for the a and d
registers. You get a new store on the output along with a cons field which is the
new cons cell.

### The cons cell

The cons cell has two fields:

```nu
{type: cons, ptr: 3}
```

The ptr field is the row index of the store table.


#### Creating a cons cell

```nu
let new_store = ($old_store | _cons 3 4)
let c = $new_store.cons
```





### Using car and cdr to access the values in the cons cell

Keeping in mind that for query operations, we use the store as a parameter and
not as the input to either car or cdr, but we use the cons cell itself
as the input. This will become apparent when we start to combine cars and cdrs
together. 



```nu
# Given the existing $c from above:
$c | _car
# => 3
$c | _cdr
# =>  4
```

### Making a list of cons cells

Let's start out making a cons list the hard way.
In Scheme itself, the cons list: '(1 2 3)' would look like this

```scheme
(define li (cons 1 (cons 2 (cons 3 '()))))
```



In NuScheme, if working under the hood, as it were in Nu itself,
the above would look like this:

```nu
# Assume the store is $old_store
let new_store = ($old_store | _cons 3 | _cons 2 | _cons 1)
let li = $ns.cons
```




Then, to access individual elements of the list li: 

```nu
$li | _car $ns
# => 1

# 2nd element
$li | _cdr $ns | _car $ns
# => 2

# 3rd element
$li | _ _cdr $ns | _cdr $ns | _car $ns
# => 3
```


##### The easier way to create a list using the _list function


The above is better done ergonomically via using the _list function.
The _list function takes an old store as input, any number of arguments
and returns a new store as the output. The new store.cons cell is the 
cons cell at the start of the cons list.


```nu
let new_store = ($old_store | _list 1 2 3)
let li = $new_store.cons
# Get the 2nd element
$li | _cadr $ns
# => 2
```



Note that most of the c[ad]+r functions have already been made for you:

- cadr Second
- caddr Third
- cadddr Fourth
- cadar 
- cddr
- cdar
- caar

and a few more


#### The world in regards to the Store

The world is just a container for holding onto the store and the environment.
There is one global world store currently in $env.world.
So, you do not need to  make a new world at the start but you could if you
prefer.

This section is purposefully out of order to help the following sections.


The above list examples above  could be modified like this and get the same results.

```nu
# Using the existing world to make a cons list
$env.world.store = ($env.world.store | _list 1 2 3)
let li = $env.world.store.cons
# get the third element of $li
$li | _caddr $env.world.store
# => 3

```

## The Environment

The environment is the place where all symbols are stored and subsequently looked up.

The environment is a record data structure like the store and currently also
embedded inside the world. But the environment is actually just a funny kind of
list structure made of cons cells.



This list grows as more symbols are 'defined' in it. The list contains a cons
cell for every car. all the way back to the root of the environment.

```nu
# The name 'nv' always is used to refer to NuScheme environments because $env is
# already taken

$env.world.nv
{type: cons, ptr: 2}

# Lets see the value at the root of the environment
$env.world.nv | _caar $env.world.store
# => 'undefined'
#
# Get the value of undefined
$env.world.nv | _cdar $env.world.store
# => 'root'
```

So, when the recursive function _lookup is asked a symbol and it reaches
the 'undefined' symbol, it emits a symbol not found error.

#### Defining a symbol in the environment

Since the environment's head is just a cons cell, we need to pass the existing
environment and the store itself to grow the environment by one
environment cons within a cons data structure:

```nu
$env.world.store = ($env.world.store | _define foo 9 $env.world.nv)
# But this is not complete yet
# We need to reconnect the  environment back into the world
$env.world.nv = $env.world.store.cons
```

### Looking up the value of a symbol in the environment:

The _lookup function, being a query only mode fn, only needs the synbol, the
head of the environment and the store to which it is connected to.

```nu
# Assuming the above _define was performed and the nv was reconnected
_lookup foo $env.world.nv $env.world.store
# => 9
```


#### Ergonomic usage of definitions

This is a little easier using the helpful  function: world nv-updater which takes
a closure of 2 arguments, the store and the environment. You pipe a world into it
and get a new world out the other end.

```nu
$env.world = ($env.world | world nv-updater {|st, nv| $st | _define foo 9 $nv })
```

Then to access the symbol foo again

```nu
global-eval 'foo'
# => 9
```

The fn global-eval does the work of piping the world and recovering it again
after doing the eval. This eval actually runs the World Passing MCE  for you.

So, a simple  Scheme program is '5'

```scheme
5
; => 5
```

```nu
global-eval 5
# => 5
```


#### Doing it the slightly harder way with world run

You can also use the fn 'world run' to accomplish the same thing for
lookup purposes (or other things)

```nu
# Assume the same  symbol 'foo' is set to 9 as above:
$env.world | world run {|st, nv| _lookup  foo $nv }
# => 9
```


## The Global World!

As stated previously, the mutable Nu environment variable: $env.world is the 
initial world witha store and environment. The various 'global-*' functions
are there for you  you to ergonomically bypass the need to manually set this variable.


### Working with more complex S-Expressions in this world stuff

In this example we can  create a cons cell in the world and then pipe it into
world run to query it. 

```nu
$env.world | world store-updater {|st| $st | _cons 5 6 } | world run {|st, _, re| $re | _car $st }
# =>  5
```

Note that we can pipe these commands together to  get more complex functionality.
In this way NuScheme, at the level of the plumbing of the underlying Nushell
language is very composible.



But, we can get closer to doing stuff in the real MCE. The fn global-eval
which implementes a World Passing MCE takes a single argument: The S-Expr to be
evaluated within the world. This S-Expr needs to either be an atom or a cons list
to be able to run. To this end we have the 'global-list creater:

```scheme
(quote foo)
; => foo
```


```nu
# Try to emulate the Scheme above:
let quote = global-list quote foo
# Now run it:
global-eval $quote
# => foo
```



This also works with definitions:

```nu
let d = global-list define fubar 88
global-eval $d
# => <cons record>

# Now look it up
global-eval fubar
88
```


#### Conditional expressions

We can use the 'if' expression and combine the above learnings like this:

```scheme
(define truth #t)
(if truth 99 88)
; => 99
```

```nu
let d = global-list define truth true
# Implement it
global-eval $d

# Now check it
let c_expr = global-list 'if' truth 99 88

global-eval $c_expr | get result
# => 99
```




## Fully World streaming dunder functions

We blazingly misappropriate the term "dunder functions" from Python but we skip
the trailing double underscores.

### Not yet a REPL


Let's try the above example in Scheme with a streaming world and our dunder functions:

```nu
$env.world | __world-list define truth true | __eval | __mk-atom truth | __eval | __result
# => true
```


1. Given our starting world: $env.world
2. set the list "(define truth #t)" with __world-list define truth true
3. Eval that .result in __eval
4. (Ignoring the previous result which is null
  * Insert a new atom the symbol: truth into the stream
5.__eval the previous .result   * which will be 'truth' symbol
6. Get the final result
  * Which will be lookup truth and return true




Our previous example rewritten with streaming world and using __mk-list alias:

```nu
$env.world | __mk-list define truth true | __eval | __mk-list 'if' truth 11 22 | __eval | __result
# => 11
```

That is not very close to a REPL, but you can
script your way to adding many functions into the environment say in a prelude.scm
or whatever.



####  Printing our result

Note: Due to current issue in Nu, Nushell hard panics on some recursive calls.
For this reason, there is no real  printer in the classic Scheme sense.
Instead there is a pretty printer that can do a single level nested list:

```nu
$env.world | __mk-list defne foo 9 | pp
# => "(define foo 9)"
```

Thispp is an alias to '__format-list --pretty'
which passes the '--pretty' flag to '__format-list' which wraps the string
in balanced parenthesis.

In turn '__format-list' is a wrapper fn for: '__perf-format-list' which does the
required recursion walk of the cons cell list. This makes it a good example
of who to walk such cells in the streaming world abstraction.

## Creating nested list structures

```scheme
(quote (1 2 3))
; => (1 2 3)
```

To make this possible in a store passing style, we need to invert the order of
the nesting. Innermost must first be created and then saved in a scratch buffer
which is later retrieved by a load key function when creating the outermost
list expression.  There are 2 functions for this:

- __store! key : takes world, saves .result in $env._scratch with key
- __load key  : Retrieves key from $env._scratch

```nu
$env.world | __mk-list 1 2 3 | __store! sub | __mk-list quote (__load sub) | __eval | pp
# =>'(1 2 3)'
```




#### Checking for atomicity of S-Expression

We can use the Nu collect item to check for things when debuging.
This lets us use the '_atom?' function to check for atomicity in the world stream.

```nu
$env.world | __mk-atom 14 | __eval | collect {|w| _atom? $w.result }
# => true
```

#### Checking if a list is empty

In the .result field of the world might be a cons cell. the car of that cell will be null
if it is the last (or only) cons cell in a list. We can use __null? along with __car
to get this:

```nu
$env.world | __world-list | __car | __null?
# => world.result == true
#
# To check this:
$env.world | __world-list | __car | __null? | __result
# => true
```




## The stack

The world record contains a stack data type called a stack which is just a list
There are X functions that manipulate this

- __push : Pushes the .result onto the stack
- __pop | replaces the .result with the popped value joff the stack
  * Will throw 'stack-underflow' error if stack is empty
- __pop-cons : convenience to first pop and then rcons the top of that stack
  * Expects .result to be some existing cons list

```nu
$env.world | __x-push 11 22 33 | __mk-list | __pop-cons | __pop-cons | __pop-cons | __rcons 'quote
# => (quote (11 22 33))
```



The '__x-push is debug hellper to  repeatedly push its args onto the stack
using a reduction of `$args | reduce -f $world {|it, acc| $acc | __mk-atom $it | __push }`



Then we make a new  empty list, then __pop-cons the  top of the stack

3 times and finally __rcons the symbol 'quote'


##### TODO fill me out

Consider the following:

```scheme
(define foo '(bar (1 2 3)))
```

Its car is 'bar' and its cdr is `((1 2 3))`.
IOW: the car is yet another list: which you can get out of foo with cadr:

```scheme
(cadr foo)
; => (1 2 3)
```


Implications: Must doubly wrap the list we get from the stack pop in another list, to which
we can prepend either 'quote' or 'begin' onto.
