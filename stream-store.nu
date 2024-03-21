# Streaming version of  table version of store, with columns cars and cdrs


# edits an entire row in table
def edit-row [row: int, val: record] {
  update $row $val
}

# Edits a single cell in a table
def edit-cell [row: int, col: string, val: any]: table -> table {
  update $row {|rec| $rec | update $col $val }
}

# Gets the value of a single cell with input parameters row and col.
def get-cell [row: int, col: string] {
  select $row | get $col | get 0
}




# Makes a new store from parts
def "store make" [store: table, free: int, max: int, cons?: record] -> record {
  if ($cons == null) {
      {type: store, store: $store, free: $free, max: $max}
  } else {
        {type: store, store: $store, free: $free, max: $max cons: $cons}
}
}

# the seed
def _mk-store-tbl [] { [[cars cdrs]; [_ _]] }
mut store = (store make (_mk-store-tbl) 1 0) # free must point past the largest item in the store

# _cons here is the streaming version of cons taking a store as input
# and returning a new store with the cons cell upserted into the record
# Note, the new store is increased by an appended row


# add a cons to the store
def add_cons [a: any, d: any] { append {cars: $a, cdrs: $d} }



# With a store as input, constructs a nell pair in the store and returns
# a newly modified store with a new field: the new cons cell.
  # If the  d register is null then theprevious cons cell in the existing store
# is used instead. This allows for piping many calls to _cons together to make
# a list terminating in null.
def _cons [a: any, d?: any] {
  let s = $in
  let store = $s.store
  let f = $s.free
  let dr = if ($d == null) { $s.cons } else { $d }
$s | update store ($store | add_cons $a $dr) | upsert cons {type: cons, ptr: $f} | update free ($f + 1)
}


#def _cons [a: any, d?: any]: record -> record {
#  let data = $in
#
#  match $data {
#    {type: store, store: $store, free: $free, max: $max, cons: $cons} => {
#      if ($d == null) {
#        store make ($store | add_cons $a $cons) ($free + 1) $max {type: cons, ptr: $free} 
#      } else {
#        # must want to override the d register because it is not missing
#        store make ($store | add_cons $a $d) ($free + 1) $max {type: cons, ptr: $free} 
#      }
#    },
#  {type: store, store: $store, free: $free, max: $max} => { store make ($store | add_cons $a $d) ($free + 1) $max {type: cons, ptr: $free} },
#    _ => { type-error store ($data | typeof) '_cons' }
#  }
#}



# checks that the supplied argument is indeed a cons cell record,  throws error if not.
def must-cons [c: any, src: string='must-cons'] {
  match $c {
    {type: cons, ptr: _} => true,
    _ => { type-error 'cons' ($c | typeof) $src }
  }
}


# These take a cons cell on input and a mandatory store as the first parm

# Given a cons cell on input, retrieve the a register from the store
def _car [st: record] -> any {
  let c = $in

  match $c {
    {type: cons, ptr: $row} => { $st.store | get-cell $row 'cars' },
    _ => { type-error cons ($c | typeof) '_car' }
  }
}



# Given a cons cell on input, retrieve the d register from the store
def _cdr [st: record] -> any {
  let c = $in

  match $c {
    {type: cons, ptr: $row} => { $st.store | get-cell $row 'cdrs' },
    _ => { type-error cons ($c | typeof) '_cdr' }
  }
}




# mostly for testing, Scheme will do this differently

# Given a bunch of args, return a new store with linked cons cells
def _list [...args] {
  let store = $in

  $args | reverse | reduce -f ($store | _cons null null) {|ag, acc| $acc | _cons $ag }
}


# Given a  store on input and a actual list for the parameter, return new store
# with cons field containing the pointer to head of the list
def _rlist [l: list] {
  let store = $in
  $l | reverse | reduce -f ($store | _cons null null) {|ag, acc| $acc | _cons $ag }
}

## Danger lurks below.

# Overwrite the a register in the cons cell pointed to by the first parm which must
# be of type cons with the value supplied.
# Takes a store as input and returns a modified store as output.
def _set-car! [c: record, v: any] {
  let store = $in
  must-cons $c # check we got a real cons cell

  match $store {
    {type: store, store: $st, free: $free, max: $max, cons: $cons} => {
    store make ($store.store | edit-cell $c.ptr 'cars' $v) $free $max $cons },
    _ => { type-error 'store' ($store | typeof) '_set-car!' }
  }
}


# This is the dangerous one. If the cons cell is part of a linked list,
# then overriding its cdr portion will break the linkage up to that point.
# However, it might be useful if needing to attach it to another list permanently.

# Overwrites the d register of the cons cell with the value supplied.
# Takes a store as input and returns a modified store as output.
def _set-cdr! [c: record, v: any] {
    let store = $in
  must-cons $c

  match $store {
    {type: store, store: $st, free: $free, max: $max, cons: $cons} => {
    store make ($store.store | edit-cell $c.ptr 'cdrs' $v) $free $max $cons },
    _ => { type-error 'store' ($store | typeof) '_set-cdr!' }
  }
}


# friends of _car and _cdr
# their should be 30 of these
# [incomplete at the moment. TODO: remove this line when number of 'grep def ' | wc -l' == 30


# Note some of these are in reverse order of the a.a.d.d s in the name

# get the second element of the list
def _cadr [st: record] {  _cdr $st | _car $st}


# Get the third element of this list
def _caddr [st: record] { _cdr $st |  _cdr $st | _car $st}

# Get the fourth element of this list
def _cadddr [st: record] { _cdr $st | _cdr $st |  _cdr $st | _car $st}




# The mostly friends of _car

# The _car of the _car
def _caar [$st] { _car $st | _car $st }
def _caaar [$st] { _car $st | _car $st | _car $st }
def _caaaar [$st] { _car $st | _car $st | _car $st | _car $st }


# the mostly _cdr friends

# Gets the cddr from the cons list given a store
def _cddr [st] { _cdr $st | _cdr $st }

# gets the cdddr   from the cons list given a store
def _cdddr [st] { _cdr $st | _cdr $st | _cdr $st }

# gets the cddddr   from the cons list given a store
def _cddddr [st] { _cdr $st | _cdr $st | _cdr $st | _cdr $st }





# Some weird chums of _cdr and _car

# This one used in environment probably

def _cdar [st: record] { _car $st | _cdr $st }


# Some predicates

# Is the object a valid pair. Boolean version of must-cons
def _pair? [c: any] -> bool {
    match $c {
    {type: cons, ptr: _} => true,
    _ => false
  }
}



# Returns true if object is atomic, E.g. not a _pair?
def _atom? [o: any] -> bool { not (_pair? $o) }




# Check if the item is a null
def _null? [sexp] -> bool {
  $sexp | is-empty
}
