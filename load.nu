# infrastructure support for the load procedure

def --env load1 [fname] {
  open --raw $fname | scm-parse | scm-eval | scm-print
}




# Helper function for Nu REPL environment
# Does the same action as load special form taking a path and evaluating
# but in the global environment.
def --env load [fname: string] {
  let src = (open --raw $fname)
  let form = $"\(begin ($src)\)"
  $form | scm-parse | scm-eval | scm-print
}
