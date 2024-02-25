# World passing eval

# Is the atom a symbol?
def _symbol? [sexp] -> bool {
  ($sexp | typeof) == 'string'
}


# A world (in world.nu) consists of a store and an environment


#  Given a world on input and a S-Exp as a parameter, tries to reduce to its simplest
# expression which is returned in the result field of the new world on output
def _eval [sexp: any] {
  let world = $in
  mut new_world = $world

  match $new_world {
    {type: world, store: $store, nv: $nv, result: _} => { true 
  if (_atom? $sexp) {
    if (_symbol? $sexp) {
        $new_world.result = (_lookup $sexp $new_world.nv $new_world.store)
    } else {
      $new_world = ($new_world | upsert 'result' $sexp)
    }
  } else {
      let candproc = ($sexp | _car $store)

      match $candproc {
        'quote' => { $new_world.result = ($sexp | _cadr $new_world.store) },
        _ => { runtime-error $"Unknown type of ($candproc) the first element of the S-Expression" }
      }
    }
    },
    _ => {print -e $"new world: ($new_world | columns), ($new_world | inspect)";  type-error 'world' ($new_world | typeof) '_eval' }
  }

  $new_world
}
