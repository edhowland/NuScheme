# Streaming version of  table version of store, with columns cars and cdrs


# edits an entire row in table
def edit-row [row: int, val: record] {
  update $row $val
}

# Edits a single cell in a table
def edit-cell [r: int, c: string, v: any]: table -> table {
  update $r {|row| $row | update $c $v }
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
let empty_store = [[cars cdrs]; [_ _]]
mut store = (store make $empty_store 1 0) # free must point past the largest item in the store

# _cons here is the streaming version of cons taking a store as input
# and returning a new store with the cons cell upserted into the record
# Note, the new store is increased by an appended row


# add a cons to the store
def add_cons [a: any, d: any] { append {cars: $a, cdrs: $d} }



# With a store as input, constructs a nell pair in the store and returns
# a newly modified store with a new field: the new cons cell.
def _cons [a: any, d?: any]: record -> record {
  let data = $in

  match $data {
    {type: store, store: $store, free: $free, max: $max, cons: $cons} => {store make ($store | add_cons $a $cons) ($free + 1) $max {type: cons, ptr: $free} },
  {type: store, store: $store, free: $free, max: $max} => { store make ($store | add_cons $a $d) ($free + 1) $max {type: cons, ptr: $free} },
    _ => { type-error store ($data | typeof) '_cons' }
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


