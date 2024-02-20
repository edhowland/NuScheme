# The Whole Wide World

# A world consist (at present) of:

# - The Store
# - The Environment
#    * with pointers back into the store
# - [opt] the current S-Expr to be evaluated


# There is a world_updater function that takes a closure of one argument, the world
# The user provides this closure which is expected to thread the world through
# a series of pipes and then returns the new modified world.
# ```nu
# world_updater {|w| $w | keybd-input | read | eval | scm-print }


# make a new world from a store and a environment pointing to that store
def "world make" [] {
  let tmp = {ttype: world, store: (store make (_mk-store-tbl) 1 0)}
  $tmp | insert 'nv' ($tmp.store | nv make) | insert 'result' null
}
