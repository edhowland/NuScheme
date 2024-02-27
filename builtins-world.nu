# Tools to create built in procedures and run them in the world

# Make a builtin procedure
# Takes a world and returns changed world
def _mk-builtin [name: string, cl: closure] {
  mut world = $in


  let bi = {type: builtin, name: $name, cl: $cl}
  $world = (world nv-updater {|st, nv| $st | _define $name $bi $nv })

  $world
}
