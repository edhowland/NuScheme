# World passing eval

# A world (in world.nu) consists of a store and an environment


def _eval [sexp: any] {
  let world = $in
  mut new_world = $world

  if (_atom? $sexp) {
    $new_world = ($new_world | upsert 'result' $sexp)
  }

  $new_world
}
