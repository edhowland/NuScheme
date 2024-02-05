# Scheme print and format

def format-atom [x] -> string {
  $"($x)"
}



# formats a procedure, either builtin or lambda
def format-proc [exp] {
  match $exp {
    { type: 'builtin-procedure', name: $name} => $"Builtin procedure ($name)",
    {type: lambda, params: $params, body: $body} => $"lambda: ($params) ($body)",
    _ => 'Unknown procedure type'
  }
}


# Formats a cons list recursively calling format on each item returning a string
def format-list [exp: any, acc=[]] -> string {
  if (null? $exp) {
    $"\(($acc | str join ' ')\)"
  } else {
    format-list (cdr $exp) ($acc | append (format (car $exp)))
  }
}

# Formats a cons list
def _format-list [l: closure] -> string {
  let il = ($l | from sexp)
  $"\(($il | each {|it| format $it } | str join ' ')\)"
}


# Formats a boolean
def format-bool [val] {
  match $val {
    true => '#t',
    false => '#f',
    _ => 'unknown boolean'
  }
}

# formats an expression
def format [exp: any] -> string {
  match ($exp | typeof) {
    'nothing' => "null",
    'int' => { format-atom $exp },
    'string' => { format-atom $exp },
    'bool' => { format-bool $exp },
    'closure' => { format-list $exp },
    'record' => { format-proc $exp },
    _ => { "#Unknown#" }
  }
}


# Print the result of calling format on the S-EXP to the standard output
def scm-print [] {
  let val = $in
  print (format $val)
}
