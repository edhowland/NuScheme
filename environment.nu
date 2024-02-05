# Scheme environment
source cons.nu


def "environment make" [prev=null] {
  cons (cons 'new-frame' null) $prev
}

$env.__ = (environment make)

# Set a variable in the passed in Environment returning a new environment.
def define [k: any, v: any, $nv: any] {
  cons (cons $k $v) $nv
}

  

def lookup [k: any, nv: any] {
  if ($nv | is-empty) {
    symbol-not-found $k
  } else if ($k == (caar $nv)) {
    cdar $nv
  } else {
    lookup $k (cdr $nv)
  }
}
