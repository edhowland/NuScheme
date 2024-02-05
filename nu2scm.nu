# nuutils.nu: Nu to Scheme and vice-versa
source cons.nu




# Given a Nu S-expression on input, return either a value or cons list
# Handles nested list by calling itself recursively
def sexp-to-scm [val] {
  if not (list? $val) {
    $val
  } else {
    mut res = null
    for i in $val {
      $res = (cons (sexp-to-scm $i) $res)
    }
    $res
  }
}






def sexp-list [l: list] {
  $l | reverse | reduce -f null {|it, acc| cons (sexp $it) $acc }
}

# Given a S-expression in Nu notation, e.g. [define a ['+' 1 2]], convert
# it into a Scheme S-expression with posible cons cells.
def sexp [nuxp: any] {
  if ($nuxp | is-atom) or (symbol? $nuxp) {
    $nuxp
  } else {
    sexp-list $nuxp
  }
}


def sexp-to-list [acc=[]] -> list {
  let c = $in
  if (null? $c) {
    $acc
  } else {
    cdr $c | sexp-to-list ($acc | append [(car $c | from sexp)])
  }
}

# Given a sexp, either an atom or cons list (however deeply nested), return
# a properly (possibly nested) Nu list
def "from sexp" [] -> any {
  let data = $in

  if (not ($data | typeof) == 'closure') {
  $data
  } else {
    $data | sexp-to-list
  }
}


# Append 2 cons lists together
def cons-append [l1, l2] {
  if (null? $l1) {
    $l2
  } else {
  cons (car $l1) (cons-append (cdr $l1) $l2)
  }
}

