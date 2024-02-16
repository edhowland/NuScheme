# The internal Scheme lib stuff
source typeof.nu
source errors.nu
source data.nu
source environment.nu
#source nu2scm.nu
#source len.nu
# source print.nu
#source lambda.nu

#source prelude.nu

def is-atom [] {
  let q = (typeof)
  ($q != 'list') and ($q != 'record') and ($q != 'table') and ($q != 'closure') and ($q != 'string')
}


# Returns true if the parameter is a string, aka a symbol
def symbol? [k: any] {
  ($k | typeof) == 'string'
}




# Returns true if argument is a lambda expression.
def lambda? [iexp: any] -> bool {
  ($iexp | has-key type) and (($iexp | get type) == 'lambda')
}

# Maps closure over cons list returning new cons list
def map1 [data: any, cl: closure, acc=null] {
  
  if (null? $data) {
    $acc
  } else {
    map1 (cdr $data) $cl (cons (do $cl (car $data)) $acc)
  }
}



# Attemp 2 : Maps a Nu closure over a cons list returning a new cons list
def map [data: any, cl: closure] {
  if (null? $data) {
    null
  } else {
    cons (do $cl (car $data)) (map (cdr $data) $cl)
  }
}
