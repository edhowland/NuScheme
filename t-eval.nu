# test out  the  eval-world.nu stuff
source errors.nu
source typeof.nu
source t-world.nu
source eval-world.nu
#source print-world.nu
source print-world.nu
source stackworld.nu
let World = (world make)


# Debug

# Redirect input to stderr
def to-stderr [] { print -e $in }

# Insert this in the middle of a dunder stream to get the result sent to stderr
alias __x-result = tee { __result | to-stderr }


# push some items on top of the stack

def __x-push [...args] {
  let world = $in

  $args | reduce -f $world {|it, acc| $acc | __mk-atom $it | __push }
}


# Alias for the collect  function that always can set things in environment
alias kollect = collect --keep-env


# Get the car and print the result from world stream
def __x-car [] { __car | __result }



# Get the cdr from world stream and print it
def __x-cdr [] { __cdr | __result }

# Get the second or cadr from the cons list
def __x-cadr [] { __cadr | __result }

# Get the third element from the cons list and return it
def __x-caddr [] { __caddr | __result }


# Get the forth elemen from the cons list and return it
def __x-cadddr [] { __cadddr | __result }

# Collects the final piped output and makes the new env.world.
alias kworld = kollect {|w| $env.world = $w }
