# The NuScheme prelude



# First test
define-builtin 'inc' {|l| $l.0 + 1 }


# Arithemitic
define-builtin '+' {|l| $l | reduce -f 0 {|it, acc| $acc + $it } }
define-builtin '-' {|l| $l | reduce  {|it, acc| $acc - $it } }
define-builtin '*' {|l| $l | reduce -f 1 {|it, acc| $acc * $it } }
define-builtin '/' {|l| $l | reduce {|it, acc| $acc / $it } }




# Some predicates
define-builtin 'null?' {|l| null? $l } # See description of Nu fn null? wrt [] and [null]
define-builtin 'zero?' {|l| $l.0 == 0 }
define-builtin 'eq?' {|l| $l.0 == $l.1 }


# List procedures
define-builtin 'length' {|l| $l.0 | length }




# Input/Output



define-builtin 'displayln' {|l| print  $"($l)" }
