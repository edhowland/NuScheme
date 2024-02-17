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

def --env cons [a: any, d: any] {
  $env.cars = ($env.cars | update $env.cell_free $a)
  $env.cdrs = ($env.cdrs | update $env.cell_free $d)
  $env.cell_free += 1
  {type: cons, a: ($env.cars | get ($env.cell_free - 1)), d: ($env.cdrs | get ($env.cell_free - 1))}
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


