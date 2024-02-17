# The Scheme store. A list of cars and another list of cdrs.
source typeof.nu
source errors.nu

# Both list are the actual same size.
# there is a 'free' index, starts out as 0.
# cons grabs a :a: from the cars list and a :d: from the cdrs list and returns a tuple



# Allocates a cars or cdrs list
def --env allocate [n: int=10] {
  $env.cell_max = $n
  1..($n) | each {|it| '_' }
}

# These can be immutable for now
$env.cars = (allocate)
$env.cdrs = (allocate)

$env.cell_free = 0



# Is this how?
# Not liking the cell path stuff

# Constructs a new cons pair.
# Will throw error if $env.cell_max is reached or exceeded
def --env cons [a: any, d: any] {
  if ($env.cell_free >= $env.cell_max) { error make {msg: 'out of memory in cons'} }
  $env.cars = ($env.cars | update $env.cell_free $a)
  $env.cdrs = ($env.cdrs | update $env.cell_free $d)
  $env.cell_free += 1
  {type: cons, a: ($env.cars | get ($env.cell_free - 1)), d: ($env.cdrs | get ($env.cell_free - 1)), ptr: ($env.cell_free - 1)}
}


# accessors

#  get the a register from the cons cell
def car [c: record] -> any {
  match $c {
  {type: cons, a: $a, d: _} => $a,
    _ => { type-error cons ($c | typeof) 'car' }
  }
}




#  get the d register from the cons cell
def cdr [c: record] -> any {
  match $c {
  {type: cons, a: _, d: $d} => $d,
    _ => { type-error cons ($c | typeof) 'car' }
  }
}




# This is the REAL cons predicate, not cons?

# Return true if parameter is an actual cons pair.
def pair? [c: any] -> bool {
  try {
  match $c {
    {type: cons, a: _, d: _} => true,
    _ => false
  }
  } catch { false }
}


# Mainly for debugging

# Return a new cons list from parameters to this function
def scm-list [...args] -> record {
  $args | reverse |  reduce -f null {|it, acc| cons $it $acc }
}




# how to check for the end of the list
# One way is to see if it is null
# another way is to check if it is empty

# Returns true if the object passed as the arg is truly null
def null? [o: any] -> bool {
  $o | is-empty
}


## Mutation. In the tradition of SICP, these are at the end!

# For debugging

# Returns the pointer register of the cons cell
def cons-ptr [c: any] -> int {
  match $c {
    {type: cons, a: _, d: _, ptr: $ptr} => $ptr,
    _ => { type-error cons ($c | typeof) 'cons-ptr' }
  }
}


# Set the value ofthe a register of a cons cell
def --env set-car! [c: any, v: any] -> record {
  if not (pair? $c) { type-error 'cons' ($c | typeof) 'set-car!' }
  $env.cars = ($env.cars  | update (cons-ptr $c) $v)

  {type: cons, a: ($env.cars | get (cons-ptr $c)), d: ($env.cdrs | get (cons-ptr $c)), ptr: (cons-ptr $c)}
}





# Set the value ofthe d register of a cons cell
def --env set-cdr! [c: any, v: any] -> record {
  if not (pair? $c) { type-error 'cons' ($c | typeof) 'set-car!' }
  $env.cdrs = ($env.cdrs  | update (cons-ptr $c) $v)

  {type: cons, a: ($env.cars | get (cons-ptr $c)), d: ($env.cdrs | get (cons-ptr $c)), ptr: (cons-ptr $c)}
}



