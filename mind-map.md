# Mind Map about the NuScheme project

## Choice to use Church encodings for cons cells

Maybe not the best choice

- Hard to debug while in Nu
- Native list primitives would make eval/apply/lambda easier to work with.


## NYI: the cond special form

```scheme
(cond x
  ((zero? n) 1)
  ((one? 1) 1)
  (#t (fib ...)
)
```

Short-circuits  the first clause whose car is true and then evaluates the cadr of that clause
## Lambda stuff
### How to extend the environment when running an evaluated lambda as a closure over some previous environment

From: [CMU: Lambda Expressions](https://www.cs.cmu.edu/Groups/AI/html/r4rs/r4rs_6.html#SEC30)

"Semantics: A lambda expression evaluates to a procedure. The environment in
effect when the lambda expression was evaluated is remembered as part of the
procedure. When the procedure is later called with some actual arguments,
the environment in which the lambda expression was evaluated will be extended
by binding the variables in the formal argument list to fresh locations,
the corresponding actual argument values will be stored in those locations, and
the expressions in the body of the lambda expression will be evaluated
sequentially in the extended environment. The result of the last expression in
the body will be returned as the result of the procedure call."



#### create both '(begin ...) special form


This is implemented both for lambda bodies and the load-eval procedure
as well as the Nu fn: load (for testing)
The body of the lambda must be an implied begin form.



##### The following has been replaced by from sexp and its helper: sexp-to-list


### Nested lambda bodies

relying on cons-to-list, IOW: 

```nu
# say $la is a closure (cons) list like this
# (lambda (x) (+ x 1))
cddr $la | cons-to-list
# does not create deeply nested thing like this:
# ['+' 'x' 1]
```

need cons-to-list to deeply copy cons structure into Nu nested list
Like 'sexp [..list]' does, but in reverse.


