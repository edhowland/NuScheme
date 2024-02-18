# The Scheme store. A list of cars and another list of cdrs.
source typeof.nu
source errors.nu

# Both list are the actual same size.
# there is a 'free' index, starts out as 0.
# cons grabs a :a: from the cars list and a :d: from the cdrs list and returns a tuple



# Allocates a cars or cdrs list
def --env allocate [n: int=25] {
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
  {type: cons, ptr: ($env.cell_free - 1)}
}


# accessors

#  get the a register from the cons cell
def car [c: record] -> any {
  match $c {
  {type: cons,ptr: $ptr } => { $env.cars | get $ptr },
    _ => { type-error cons ($c | typeof) 'car' }
  }
}




#  get the d register from the cons cell
def cdr [c: record] -> any {
  match $c {
  {type: cons, ptr: $ptr} => { $env.cdrs | get $ptr },
    _ => { type-error cons ($c | typeof) 'car' }
  }
}




# This is the REAL cons predicate, not cons?

# Return true if parameter is an actual cons pair.
def pair? [c: any] -> bool {
  try {
  match $c {
    {type: cons,ptr: _ } => true,
    _ => false
  }
  } catch { false }
}


# Mainly for debugging

# Return a new cons list from parameters to this function
# Iterates over arg list and converts it to a cons list
def --env scm-list [...args] {
  mut l = null

  for i in ($args | reverse) {
  $l = (cons $i $l)
  }
  $l
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

# Returns the current free pointer
def _free [] { $env.cell_free }


# Returns the current highest used cell ptr
def _high-water [] {
  $env.cell_free - 1
}


# Returns the pointer register of the cons cell
def cons-ptr [c: any] -> int {
  match $c {
    {type: cons, ptr: $ptr} => $ptr,
    _ => { type-error cons ($c | typeof) 'cons-ptr' }
  }
}


# Set the value ofthe a register of a cons cell
def --env set-car! [c: any, v: any] -> nothing {
  if not (pair? $c) { type-error 'cons' ($c | typeof) 'set-car!' }
  $env.cars = ($env.cars  | update (cons-ptr $c) $v)
}




# Set the value ofthe d register of a cons cell
def --env set-cdr! [c: any, v: any] -> nothing {
  if not (pair? $c) { type-error 'cons' ($c | typeof) 'set-car!' }
  $env.cdrs = ($env.cdrs  | update (cons-ptr $c) $v)
}





## Debugging again. Print the list
def print-list [l] {
  if (null? $l) {
    null
  } else {
    print (car $l)
    print-list (cdr $l)
  }
}




def caar [l] {
  car (car $l)
}


def cadr [l] {
  car (cdr $l)
}

def cdar [l] {
  cdr (car $l)
}



def cddr [l] {
  cdr (cdr $l)
}


def caddr [l] {
  car (cdr (cdr $l))
}

def cdddr [l] {
  cdr (cdr (cdr $l))
}


def cadddr [l] {
  car (cdddr $l)
}


alias scm-first = car

alias scm-rest = cdr
alias scm-second = cadr
alias scm-third = caddr
alias scm-fourth = cadddr

# Gets the 5th element of the cons list
def scm-fifth [l] { car (cdr (cdddr $l)) }

# Gets the 6th element of a cons list
def scm-sixth [l] { car (cdr (cdr (cdddr $l))) }
