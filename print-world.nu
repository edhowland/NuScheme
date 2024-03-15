# formatting and printing stuff with regard to World streams

# Formats the result of the world stream into a string
def __format [] {
  let world = $in
  let sexp = $world.result # probably remove this

  if ($world | __atom? | __result) {
  $"($world | __result)"
  } else {
  mut o = "("
    if not ($world | __car | __null? | __result) {
      $o += $"($world | __car | __format)"
      $o += ($world | __cdr | __format)
    }
  $o += ")"
    $o
  }
}

