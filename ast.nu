# The AST for Nuscheme

# An Abstract Syntax Tree or AST is either:
# - A leaf node (consisting of 1 atom)
# - A sub tree consisting of a list of leaf nodes, possibly empty


# Constructs a new AST node
def ast-new [v: any] -> record {
  { type: AST, node: $v }
}

# Constructs the initial (empty) AST root node.
def ast-init [] {
  ast-new null
}



# Returns true if the passed value in is actually an AST node
def is-ast [] -> bool {
  match $in {
    { type: AST, node: _ } => true,
    _ => false
  }
}


# Given a parser tuple on input consisting of the tree so far and the rest of the
# stream of remaining lexemes, applies the closure f to the top of the
# stream  and takes the returned value from f and creates a new AST subtree
# returning the new [AST, lexeme-stream-tail]
def ast-applyf [f: closure] -> list {
  let data = $in
  let not_lexeme = (lexeme-default? --not)
  let lexeme = ($data.1 | first 1 | get 0)
  let tail = ($data.1 | skip 1)
  let node = (do $f $lexeme)
  [[($data.0 | filter $not_lexeme | append $node)], $tail]
}


# Does the final unwrap. Expects Result:Ok varient to contain the tuple
# of 1 AST root|single item, and an empty list in the second part of the tuple.
def ast-final [] -> any {
  result unwrap --ok  | get 0
}
