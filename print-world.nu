# formatters and printers for different kind of S-Expressions
# Eventually, this will xform true into #t and false to #f along with other
# Scheme related data types


# Formats a cons list in the result field of world stream
def __perf-format-list [
    pretty: bool,  # Wraps the output in pretty parens
    acc='',  # The accumulator that is returned after recursion hist base case
    prefix=''
  ] -> string {
  let world = $in

  if ($world | __car | __null? | __result) {
      if $pretty {
      $"\(($acc)\)"
    } else {
      $acc
    }
  } else {
    $world | __cdr | __perf-format-list $pretty $"($acc)($prefix)($world | __car | __result)" ' '
  }
}






# formats list in incoming world stream
# Output is a string so must occur at termination of pipeline
def __format-list [
    --pretty (-p), # Optionally wraps output string in balanced parens
  ] -> string {
  __perf-format-list $pretty
}

# pretty print the result field in the passed in worldtstring
alias pp = __format-list --pretty
