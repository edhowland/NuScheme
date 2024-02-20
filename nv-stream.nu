# temp name for streaming conformant environment

# Using a lookup  style of stacked cons frames

# Creates a new root of the environment and attaches it to the present store
# takes store on input and returns new store
# after return, the .cons field is the environment
def "nv make" [] {
  let store = $in
  let res = ($store | _cons 'undefined' 'root')
  let r = $res.cons
  let res = ($res | _cons $r null) 
  $res
}




# Given a symbol and a value and the environment, returns new store with the
# new binding added. The .cons of the new store is the new environment
# The nv parm must be a cons cell pointing to the location of the environment in the store
def _define [key: string, val: any, nv: record] {
  let store = $in

  mut res = ($store | _cons $key $val) # make the hanging binding
  let binding = $res.cons

  $res = ($res | _cons $binding $nv)

  $res
}


# Should this throw Nu type errors?
# Lookups a binding in the environment takes the symbol the environment and the store and returns the value if fount
def _lookup [key: string, nv: record, st: record] -> any {
  if ($nv | _cdr  $st) == null {
    runtime-error 'reached past the environment or not an environment was passed'
  } else if ($nv | _caar $st) == 'undefined' {
symbol-not-found $key
  } else if ($nv | _caar $st) == $key {
    $nv | _cdar $st
  } else {
    _lookup $key ($nv | _cdr $st) $st
  }
}