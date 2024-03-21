# Homage to Flatland by Edwin Abbot and RingWorld by Larry Niven


# Push the .result field oin world stream onto the .stack.
def __push [] {
  let world = $in

  $world | upsert stack ($world.stack | append $world.result)
}


# Pops the top of the stack and places it into the .result field.
# Will throw stack-underflow error if stack is empty
def __pop [] {
  let world = $in

  if ($world.stack | is-empty) { runtime-error 'stack-underflow' }
  $world | update 'result' ($world.stack | last 1| get 0) | update 'stack' ($world.stack | drop 1)
}

# aggregate functions


# Creates a new cons cell with the A register being the top of the stack popped
# off and the D register being the current result.  If previous result was a
# __null?, then builds a list.
def __pop-cons [] {
  mut world = $in
  if ($world.stack | is-empty) { runtime-error 'stack-underflow' }
  mut stk = $world.stack
  let saved = $world.result
  let top = ($stk | last 1 | get 0)
  $stk = ($stk | drop 1)
  $world.stack = $stk
  $world = ($world | world store-updater {|st| $st | _cons $top $saved })

  $world
}




# Peeks at the top of the stack. This must terminate world pipeline.
alias __peek = get $.stack.0