# lambda.nu : The lambda abstraction

# Constructor for lambda expressions
def lambda [params: list, body: list, nv: closure] {
  { type: lambda, params: $params, body: $body, nv: $nv}
}


# Helper function for eval to be able to call the above lambda constructor
def "lambda make" [params: closure, body: any, nv] {
  lambda ($params | from sexp) ($body | from sexp)  $nv
}




# Forward declaration of lambda run so apply function can see it

def "_lambda run" [proc: record, args: list, nv: any] { runtime-error 'fwd decl for lambda run' }

