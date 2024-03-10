# test out  the  eval-world.nu stuff
source errors.nu
source typeof.nu
source t-world.nu
source eval-world.nu

let World = (world make)


# Debug

# Redirect input to stderr
def to-stderr [] { print -e $in }

# Insert this in the middle of a dunder stream to get the result sent to stderr
alias __x-result = tee { __result | to-stderr }