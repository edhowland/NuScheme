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


# Pops one item off the top of the stack and cons it onto the front of the existing cons list
def __pop-cons [] {
  let world = $in

  let saved = $world.result
  let wtmp = ($world | __pop)
  let rtmp = $wtmp.result
  # print -e $"rtmp: ($rtmp)"
  $wtmp | update 'result' $saved | __rcons $rtmp
}
