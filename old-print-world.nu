# formatting and printing stuff with regard to World streams

# for debugging this Nu panic only:
#alias __format = __result


# formats a list in the result of a world stream and returns a string
# is tail call optimized
def __format-list [acc='', prefix=''] -> string {
  let world = $in

    if ($world | __car | __null? | __result) {
    $acc
  } else {
    $world | __cdr | __format-list $"($acc)($prefix)($world | __car | __format)" ' '
  }
}



def __format [] -> string {
  let world = $in

  if ($world | __list?) {
    "(" + ($world | __format-list) + ")"
  } else {
    $"($world | __result)"
  }
}


# Formats the result of the world stream into a string
#def __format [] {
#  let world = $in
#  let sexp = $world.result # probably remove this
#
#  if ($world | __atom? | __result) {
#  $"($world | __result)"
#  } else if ($world | __list?) {
#    $"\(($world | __format-list)\)"
#  } else {
#    error make {msg:'bad'}
#}
#}

