# For NuScheme builtin procedures
# Create  a builtin procedure from a closure that only ..rest parameter
def "builtin make" [name: string, params: list, body: closure] {
  pods 'builtin-procedure' {params: $params, body: $body} $name
}

def builtin? [x: any] -> bool {
  ($x | is-pods) and (($x | get type) == 'builtin-procedure')
}


# Run a builtin given the builtin data structure and some arguments and the environment
def "builtin run" [p: record, args: list, nv: any] {
  match $p {
    {type: 'builtin-procedure', data: {params: $params, body: $body}} => {
      do $body $args
    },
    _ => { runtime-error }
  }
}
 


# Wrapper to bind closure to synbol for builtin procedure.
def --env define-builtin [name: string, cl: closure] {
  $env.__ =  (define $name (builtin make  $name [] $cl) $env.__)
}

