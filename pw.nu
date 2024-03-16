# second attempt - rename to print-world.nu

# formats a list in world stream
def __format-list [acc='', prefix=''] -> string {
  let world = $in

  if ($world | __car | __null? | __result) {
    $acc
  } else {
    $world | __cdr | __format-list $"($acc)($prefix)($world | __car | __result)" ' '
  }
}


# formats s-expression in world stream
def __format [] -> string {
  let world = $in

  if ($world | __list?| __result) {
  $world | __format-list
  } else {
    $"($world | __result)"
  }
}
