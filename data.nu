# data.nu: Internal data structures for Scheme

# Construct a PODS; a plain old data struct
def pods [type: string, data: record, name=''] {
  {type: $type, data: $data, name: $name}
}


# Returns true if data is a record and has key name $key
def has-key [k] -> bool {
  let data = $in
  if ($data | typeof) == 'record' {
    $data | columns | any {|it| $it == $k }
  } else {
    false
  }
}



#def has-key [k: any] {
#  let data = $in
#  (($data | typeof) == 'record') and (try { $data | get $k; true } catch { false })
#}


# Returns true if input is a PODS (Plain Old Data Sctructure)
alias is-pods = has-key type
