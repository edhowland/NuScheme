# The global or top-level namespace

# Define the global world

$env.world = (world make)

# Runs a S-Expression thru the global world via the eval method
# Returns the result of  the evaluation
def --env global-eval [sexp: any] {
  $env.world = ($env.world | _eval $sexp)
  $env.world.result
}



# Creates a list in the global world store
def --env global-list [...args] {
  $env.world = ($env.world | world store-updater {|st| $st | _list $args.0 $args.1 $args.2 })
  $env.world.result
}
