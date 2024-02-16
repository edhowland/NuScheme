#NuScheme

## Abstract

Attempt to get the basics of the Scheme programming language in Nu.

## Getting started

### Clone this repository

```sh
git clone https://github.com/edhowland/NuScheme.git
cd NuScheme
```





### Starting the Read-Eval-Print Loop or REPL

To start the simple REPL, run the Nu script: ./nuscheme

```sh
./nuscheme
Nuscheme. Enter atoms or S-Expressions. Enter (exit) to exit
',>> (define id (lambda (i) i))
>> (id 9)
9
>> (exit)
... Bye
$

```
```

You can also start the whole process within Nu REPL itself.

```sh
nu -e "source t-scheme.nu"
>>> # enter a S-Expression
>>> rep
>> 5
5
>>> (define baz (quote baz))
>>> rep
>> baz
baz
```



## Loading from Scheme source files

Either  do this via the Nu function : load fname.scm
which sets it in the global environment


Note: the entire source text of the file.scm is first wrapped in a begin special form.


or within the NuScheme  REPL:

```scheme
>> (load fact.scm)
>> (fact 5)
120
```



Note: This differs from regular scheme because in, say Racket, load is a procedure.
But in NuScheme it is a special form that does not evaluate its first arg
therefore it can use bare strings instead of double quoted strings for pathmames.

Support for double quoted strings is not yet implemented.

You can a single quoted string with the quote special form

```scheme
(define str (quote fubar))
```


Allowed data types for NuScheme and their Scheme literal examples

- bool: '#t' => true, '#f' => false
- int: ''12', '345' => 12, 345
- string: (bare strings) foo, bar => 'foo', 'bar'

Note on strings These bare strings are symbols in the Scheme universe.
Actual strings: "hello", "World!" will eventually be supported.


## Inner workings

Invoke nu with '-e "source t-scheme.nu"'

Within the Nu REPL, you can run simple Scheme S-Expressions against the $env.__



```nu
rep
(quote (1 2 3))
(1 2 3)
```


Alternatively, you can test out the full CLI REPL

```sh
./nuscheme

Nuscheme. Enter atoms or S-Expressions. Enter (exit) to exit
'>> ',
(+ 1 5)
6
>> (exit)
...Bye
```


### Testing

You can use the 'r' function to test out the input and parser
It takes input from the console and just parses it into the AST which are
either single atom S-Expressions or(possibly nested) lists (Nu variety).

Or you can invoke 're'.
This does the action of 'r' and then attempts to evaluate it returning
the output. as either an atom or a closure.

### Cons lists in NuScheme

(This design might be removed in the future)

Cons cells are used in Church encoded Nu closures.
Check out mind-map.md for details or cons.nu.

You can use Nu functions like cons, car and cdr to work with them.

Also, there are 2 Nu recursive functions to convert between Nu and NuScheme
lists (or atoms)

- sexp : Takes one  argument that is expectd to be either an atom or Nu list (possibly nested) and returns closure-based cons cells (or an atom)
- from sexp : Given a cons cell (closure) on input (or an atom), returns a Nu list or atom.

### The rep function

And finally 'rep' does a 're' and pipes it to scm-print.

Note: there is no 'print' or 'p' function as these are used by Nu itself.

So, this is a one shot  read-eval-print test.
and is useful for testing simple expressions.

### load1

This will try and read a file containing exactly 1 S-Expression (possibly nested)
and then parse and evaluate it and then print it.
Also useful for testing.

- plus-1-4.scm : Contains: (+ 1 4); and should return 5
- fact.scm : Defines the fact procedure. (fact 5) entered in to rep will return 120


Note: At this stage there is no application of lambdas


### Builtins

You can make a builtin procedure thusly:

```nu
$env.__ = (define add (builtin make add [x y] {|l| $l.0 + $l.1 }) $env.__)
```

Above we define a symbol called 'add' and bind it to the result of calling "builtin make"
with these   parameters

- name: string
- parameters: list
- closure: closure



The define call takes a global environment ($env.__) and returns a new environment:

```nu
$env.__ = (define foo 9 $env.__)
# Lookup it 
lookup bar $env.__
9
```

There are some builtin procedures


TODO: Complete these
Arithmetic operators

- '+'
- '-'
- '*'
- '/'


And some list/cons procedures

- cons : TODO: Fix this
- car, cdr
- cons?
- length

