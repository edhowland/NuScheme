# cons, car and cdr



def cons [a, d] {
  {|f| 
    do $f $a $d
  }
}



def null? [x] {
  $x | is-empty
}


# Is this a cons cell
def cons? [x] {
  try {
  #print -e $"in cons? type of x is ($x | typeof)"
  if (($x | typeof) == 'closure') and (do $x {|_| true }) {
    true
  } else {
    false
  }
  } catch { false }
}
 


# Is this really a list
def list? [x] {
  if (null? $x) {
  true
  } else if (cons? $x) {
    list? (cdr $x)
  } else {
    false
  }
}

    
# List accessors
def car [c: closure] {
  if not (cons?  $c) { type-error 'cons' ($c | typeof) 'car' }

  do $c {|a, _| $a }
}


# Returns the 'd' register of the cons cell
# Input must be a closure and obey cons?
def cdr [c: closure] {
  if not (cons?  $c) { type-error 'cons' ($c | typeof) 'cdr' }

  do $c {|_, d| $d }
  }


def caar [l] {
  car (car $l)
}


def cadr [l] {
  car (cdr $l)
}

def cdar [l] {
  cdr (car $l)
}



def cddr [l] {
  cdr (cdr $l)
}


def caddr [l] {
  car (cdr (cdr $l))
}

def cdddr [l] {
  cdr (cdr (cdr $l))
}


def cadddr [l] {
  car (cdddr $l)
}


alias scm-first = car

alias scm-rest = cdr
alias scm-second = cadr
alias scm-third = caddr
alias scm-fourth = cadddr





# Return length of linked list created of cons cells
def len [l] {
  if not (list? $l) { type-error 'list' ($l | typeof) 'len' }
  if ($l | is-empty) {
    0
  } else {
  1 + (len (cdr $l))
  }
}
