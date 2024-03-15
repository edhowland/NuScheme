# formatting and printing stuff with regard to World streams

# Formats the result of the world stream into a string
def __format [] {
  let world = $in
  let sexp = $world.result

  if (_atom? $sexp) {
  $"($sexp)"
  } else {
  mut o = "("
    $o += $"($sexp | _car $world.store) "
    $o += $"($sexp | _cadr $world.store) "
    $o += $"($sexp | _caddr $world.store)"
  $o += ")"
    $o
  }
}

