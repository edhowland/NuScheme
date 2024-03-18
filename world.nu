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
  $tmp =  ($tmp | insert 'result' null)
  $tmp = ($tmp | insert 'stack' [])
  $tmp
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



# Given a world on input with a .result field that might or not be null
# returns new world with .result field set to boolean true or false depending on it
def __null? [] {
  let world = $in
  $world | upsert result ($world | get result | is-empty)
}


# Checks if the world stream .result field is an atom
# and if it is, places this boolean in the output .result of the new world stream
def __atom? [] {
  let world = $in
  $world | upsert result (_atom? $world.result)
}

# Insert a cons list into world stream
# Useful for making single level S-Expressions for input into __eval
def __world-list [...args] {
world store-updater {|st| $st | _rlist $args }
}

# Make a single nested level cons list from arguments
alias __mk-list = __world-list


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



# Get the second element of the cons in the previous result of the world stream
# and place that value in the result in the new world on output
def __cadr [] {
  collect {|w| $w | upsert result ($w.result | _cadr $w.store) }
}


# Returns a true .result if the incoming world stream .result is a list
def __list? [] {
  let world = $in

  if ($world | __atom? | __result) {
    $world | upsert result false
  } else if ($world | __car | __null? | __result) {
    $world | upsert result true
  } else {
    $world | __cdr | __list?
  }
}


# cons method to take .result field and construct new cons cell which is placed
# as new .result in world stream

# cons elements from .result and make new .result
# returning new world
def __cons [d: any] {
  let world = $in
  $world | world store-updater {|st| $st | _cons $world.result $d }
}


# like __cons except args are reversed. Now d register is in .result field of
# incoming world stream and a register is the argument
def __rcons [a: any] {
  let world = $in
  $world | world store-updater {|st| $st | _cons $a $world.result }

}
