# The Whole Wide World

# A world consist (at present) of:

# - The Store
# - The Environment
#    * with pointers back into the store
# - [opt] the current S-Expr to be evaluated


# There is a world_updater function that takes a closure of one argument, the world
# The user provides this closure which is expected to thread the world through
# a series of pipes and then returns the new modified world.
# ```nu
# world_updater {|w| $w | keybd-input | read | eval | scm-print }


# make a new world from a store and a environment pointing to that store
def "world make" [] {
  mut tmp = {type: world, store: (store make (_mk-store-tbl) 1 0)}
  $tmp.store = ($tmp.store | nv make)
$tmp.nv = $tmp.store.cons
  $tmp |  | insert 'result' null
}


# some predicates

# Returns true if item is a actual world object
def _world? [o: any] -> bool {
  match $o {
    {type: world, store: _, nv: _, result: _} => true,
    _ => false
  }
}

# Given a world on input, update the store and the environment in one fell swoop with the closure returning
# a new store. This returns a new world
def "world nv-updater" [cl: closure] -> record {
  mut world = $in

  $world.store = (do $cl $world.store $world.nv)
  $world.nv = $world.store.cons
  $world
}

# Given a world on input, passes the store field to a closure which must return a new store
# The new store in the wrold being returned will have its .cons field in the  result field of world
def "world store-updater" [cl: closure] -> record {
  mut world = $in
  $world.store = (do $cl $world.store)
  $world.result = $world.store.cons

  $world
}


# Given a world on input, runs the query within the passed in closure.
# The arguments to the closure are the store and the environment.  and the previous result, if any
# The result of the closure. is returned.
#  This function is meant for query operations only.
def "world run" [cl: closure] -> any {
  let world = $in

  do $cl $world.store $world.nv $world.result
}

