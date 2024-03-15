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



# dunder methods : Things meant to insert into a World Passing Style pipeline or stream

# You can inspect the __world-list with: 
# ```nu
# $env.world | __world-list define foo 9 | world run {|st, _, re| $re | _car $st }
# => define
# ```
# or _cadr or _caddr .etc



# The world streaming version of _null?
def __null? [] { get result | is-empty }
# Insert a cons list into world stream
# Useful for making single level S-Expressions for input into __eval
def __world-list [...args] {
world store-updater {|st| $st | _rlist $args }
}


# Insert atom value into stream
alias __mk-atom = upsert result

# Gets the result field of a world in the stream
alias __result = get result

# scratch storage functions. can be implemented within world streams to hold 
# result until needed later.
# Application:  when making nested cons S-exprs


# The scratch location
$env._scratch = {type: scratch}

# Store result in  $env._scratch with key and previous .result
def --env __store! [key] {
  let world = $in

  $env._scratch = ($env._scratch | upsert $key $world.result)
  $world
}


# Retrieve the previous key from scratch storage in $env._scratch
# This just  returns the value so use in sub-expression 
# like : '__list quote (__load sublist) | __eval'
def __load [key] {
  $env._scratch | get $key
}


# dunder car and cdr functions

# Gets the car of a world stream previous result and places it in result of
# following world stream
def __car [] {
  collect {|w| $w | upsert result ($w.result | _car $w.store) }
}



# Gets the cdr from the world stream's previous result
def __cdr [] {
  collect {|w| $w | upsert result ($w.result | _cdr $w.store) }
}
