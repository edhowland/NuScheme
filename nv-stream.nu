# temp name for streaming conformant environment

# Using a lookup  style of stacked cons frames

# Creates a new root of the environment and attaches it to the present store
# takes store on input and returns new store
def "nv make" [] {
  let store = $in
  let res = ($store | _cons 'undefined' 'root')

  $res
}
