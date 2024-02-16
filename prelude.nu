# The NuScheme prelude

# For debugging
# Use this in a call to 're', not 'rep' or in the full REPL
define-builtin 'inspect' {|l| $l | inspect }
define-builtin 'describe' {|l| $l | describe }


# Arithemitic
define-builtin '+' {|l| $l | reduce -f 0 {|it, acc| $acc + $it } }
define-builtin '-' {|l| $l | reduce  {|it, acc| $acc - $it } }
define-builtin '*' {|l| $l | reduce -f 1 {|it, acc| $acc * $it } }
define-builtin '/' {|l| $l | reduce {|it, acc| $acc / $it } }




# Some predicates
define-builtin 'null?' {|l| null? $l } # See description of Nu fn null? wrt [] and [null]
define-builtin 'zero?' {|l| $l.0 == 0 }
define-builtin 'eq?' {|l| $l.0 == $l.1 }
define-builtin 'symbol?' {|l| symbol? $l.0 }

# List procedures
define-builtin 'length' {|l| $l.0 | length }
define-builtin 'cons' {|l| cons $l.0 $l.1 }
define-builtin 'car' {|l| car $l.0 }
define-builtin 'cdr' {|l| cdr $l.0 }
define-builtin 'cons?' {|l| cons? $l.0 }


# Logical operators
define-builtin 'not' {|l| (not ($l.0)) }



# Input/Output



define-builtin 'displayln' {|l| print  $"($l)" }


## Now for some Scheme functions written in Scheme

# Standard lib stuff
load libnuscheme.scm
