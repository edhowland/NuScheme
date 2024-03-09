# The global or top-level namespace

# Define the global world

$env.world = (world make)

# Runs a S-Expression thru the global world via the eval method
# Returns the result of  the evaluation
def --env global-eval [sexp: any] {
  $env.world = ($env.world | _eval $sexp)
  $env.world.result
}



 #Creates a list in the global world store
def --env global-list [...args] {
  $env.world = ($env.world | world store-updater {|st| $st | _rlist $args })
  $env.world.result
}


# Create a cons cell in the global world
# This function is the base of the more ergonomic 'global-cons' fn
# After the closure fires, the  result is stored in $env.world.result
def --env global-store [cl: closure] {
  $env.world.store = (do $cl $env.world.store)
  $env.world.result = $env.world.store.cons
}


