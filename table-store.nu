# table version of store, with columns cars and cdrs


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



# the seed
let seed = [[cars cdrs]; [_ _]]
$env.cell_max = 10
$env.cell_free = 0 # the pointer to the next free cell

mut store = (0..$env.cell_max | reduce -f $seed {|it, acc| $acc | append {cars: _, cdrs: _} })


# This cons takes an additional parm: the store
# and returns a tuple of store and cons cel and new free pointer
def cons [a: any, d: any, st: table] {
  let new_free = $env.cell_free + 1
  [($st | edit-row $env.cell_free {cars: $a, cdrs: $d}), {type: cons, ptr: $env.cell_free}, $new_free]
}



# car takes an additional parm: the store
def car [c: record, st: table] {
  $st | get-cell $c.ptr 'cars'
}


# Returns the d register of the cons cell.
# Takes an additional parm, the store
def cdr [c: record, st: table] {
  $st | get-cell $c.ptr 'cdrs'
}
