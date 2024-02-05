# eval.nu: meta-circular evaluator in Nu

# source scheme-lib.nu


# Application of procedures to S-Expression(s) arguments
use assert


# Evaluate a begin form.
# Returns the  tuple of new environment and result of last form evaluated.
def "begin run" [forms, nv] {
  $forms | reduce -f [$nv, null] {|it, acc| eval (sexp $it) $acc.0 }
}




# Run a lambda with args replacing its environment as a new environment frame
# extending current frame with args bound to parameter symbols
def "lambda run" [proc: record, args: list, nv: any] {
  # put new env frame here

  #trace-it 'inside lambda run'
  match $proc {
{type: lambda, params: $params, body: $body, nv: $nv1} => {
    #trace-it $"running lambda: ($params) body: ($body) with args: ($args)"
      let nv0 = ($params | zip $args | reduce -f $nv1 {|it, acc| define $it.0 $it.1 $acc })
      let res = (begin run $body (cons-append $nv0 $nv))
      #trace-it $"returning |($res.1)| from lambda run"
    $res.1 # TODO: must also handle returning new environment, if one was modified
  },
    _ => { runtime-error $"lambda run proc: ($proc) args: ($args)" }
  }
}



# Given the  procedure and un-evaluated cons list of args (maybe empty)
# apply the procedure to the args after they have been evaluated
def apply [proc_call: any, nv: any] {
  let proc_ev = (eval (car $proc_call) $nv | get 1)
  let ag = (eval-args (cdr $proc_call) $nv | from sexp)
  #trace-it $"apply:($proc_ev), args: ($ag)" 
  match $proc_ev {
    {type:'builtin-procedure', data: {params: $params, body: $cl}} => { 
      #trace-it $"calling builtin procedure ($proc_ev) with ($ag)"
      builtin run $proc_ev $ag $nv
    },
    {type: lambda} => {
      #trace-it $"calling lambda run ($proc_ev) with ($ag)"
      lambda run $proc_ev $ag $nv
    },
    _ => { runtime-error $"in apply proc: ($proc_call | from sexp)" }
  }
}



# Why is load a special form?
# Because we do not (yet) have support for double quoted strings as string types

# Regular load procedure. Loads a Scheme file, wraps in a begin form
# and evaluates in the current passed in environment
# Written to be used inside eval as part of the 'load' special form.
def load-eval [fname: string, nv] {
  let src = (open --raw $fname)
  let form = $"\(begin ($src)\)"
  trace-it $"in load function: ($fname) form: ($form)"
  eval (sexp ($form | scm-parse)) $nv
}


# Tries to evaluate a given S-Exp in the passed in environment
# Returns the (possibly changed) environment and the reduced S-EXp as a tuple.
def eval [val: any, nv=null] {
  mut new_env = $nv
  # $reduction (the possibly reduced $val is also returned
  let reduction = if ($val | is-atom) {
  $val
  } else if (symbol? $val) {
    lookup $val $nv
  } else if (list? $val) {
    # Special Forms
    if (car $val) == 'quote' {
      cadr $val
    } else if (car $val) == 'if' {
      let pred = (cadr $val)
      let then_clause = (caddr $val)
      let else_clause = (cadddr $val)
      let pred_res = (eval $pred $nv)
      if $pred_res.1 {
        let then_res = (eval $then_clause $nv)
        $then_res.1
      } else {
        let else_res = (eval $else_clause $nv)
        $else_res.1
      }
    } else if  (car $val) == 'begin' {  # The begin special form
      let res = (begin run (cdr $val | from sexp) $nv)
      $new_env = $res.0
      $res.1
    } else if (car $val) == 'load' {
      trace-it 'in eval of load special form'
      let res = (load-eval (cadr $val) $nv)
      $new_env = $res.0
      $res.1
    } else if (car $val) == 'lambda' {
      lambda make (cadr $val) (cddr $val) $nv    # Although makes a single S-EXP lambda
    } else if (car $val) == 'define' {
      let res = (eval (caddr $val) $nv)
      $new_env = (define (cadr $val) $res.1 $res.0)
    } else {
    apply $val $nv
    }
  } else {
  syntax-error $"eval: got:($val)" 
  }
  [$new_env, $reduction]
}


# Workaroun because calling eval within a Nu closure has weird Variable not found error
# Also remember Nu bug with hard panic on using recursion with variable assignment



# Main

# Takes a Nu version of an S-Expression (I.e. a Nu list or atom) and reduces it
  # Might return either an atom, a cons list or nothing (if just updating the environment)
def --env scm-eval [] {
  let sexp = $in
  let res = (eval (sexp $sexp) $env.__)
  $env.__ = $res.0
  $res.1
}

# Wraps eval and returns the main result, ignoring the returned new environment
def simple-eval [val: any, nv: any] {
  eval $val | get 1
}



# Given a cons list of arguments, run eval over each argument returning a new cons list.
def eval-args [args: any, nv: any] {
  if (null? $args) {
    null
  } else {
    cons (eval (car $args) $nv | get 1) (eval-args (cdr $args) $nv)
  }
}
