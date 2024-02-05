# Scheme error constructors

def symbol-not-found [k: any] {
  error make { msg: $"($k) not found"}
}


def syntax-error [msg='', line=0, column=0] {
  error make {msg: $"Syntax error: ($msg). ($line):($column)"}
}


# Generates a generic runtime error. May include an optional message for further context.
def runtime-error [msg?: string = ''] {
  error make {msg: $"Runtime error ($msg)"}
}




# Generates a Not Implement Yet error
# This error should only occur when some internal Nuscheme procedure is still a stub
def not-impl-error [proc_name: string] {
  error make {msg: $"($proc_name) not implemented yet"}
}


# Throws a Type error with expected type and actual type.
def type-error [e: string, a: string] {
  error make {msg: $"Type error: Expected: ($e), got: ($a)" }
}


def "error custom" [msg: string] {
  error make {msg: $msg}
}
