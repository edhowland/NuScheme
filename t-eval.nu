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
