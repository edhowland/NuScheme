# NuScheme - Store passing Style

## Abstract


This is the Store Passing Style (SPS) version of a MCE Scheme interpreter.

Actually, it is the World passing style  MCE, as the store is embedded
inside a world container along with the environment.
The environment is a cons cell based lookup mechanism which is
very inefficient. because of need to test ideas regarding garbage collection.


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

We:

1. Given our starting world: $env.world
2. set the list "(define truth #t)" with __world-list define truth true
3. Eval that .result in __eval
4. (Ignoring the previous result which is null
  * Insert a new atom the symbol: truth into the stream
5.__eval the previous .result   * which will be 'truth' symbol
6. Get the final result
  * Which will be lookup truth and return true




Our previous example rewritten with streaming world

```nu
$env.world | __world-list define truth true | __eval | __world-list 'if' truth 11 22 | __eval | __result
# => 11
```

That is not very close to a REPL, but you can
script your way to adding many functions into the environment say in a prelude.scm
or whatever.



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
$env.world | __world-list 1 2 3 | __store! sub | __world-list quote (__load sub) | __eval | __result
# => <cons cell>
```
