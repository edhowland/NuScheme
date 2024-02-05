# 3rd attempt: A proper recursive descent this time

alias eos? = type-eq? (lex-eos 0)
# aliases to make math parsers look pretty

# Is input a lparen lexeme?
alias lparen? = type-eq? (lparen make)

# Is lexeme on input an rparen?
alias rparen? = type-eq? (rparen make)




# Ignores whitespace lexemes in the input stream
def ignore-whitespace [] {
  filter {|it|
    match $it {
      {type: ws, value: _, offset: _, len: _} => { false },
      _ => { true }
    }
  }
}


# Try to match a particular lexeme based on closure
def match-it [pred: closure] {
  if not (cursor | do $pred) {
    false
  } else {
  true
  }
}



# Match a lexeme that is true given closure and consume it
def --env match-consume [pred: closure, token?='<token-type>'] {
  if not (cursor | do $pred) {
    syntax-error $"Expected ($token) token but got (cursor) instead"
  }
  get-token
}


def  --env match-exact [token] {
  match-consume {
  match $in {
  {type: $type} => { $token == $type },
    _ => false
  }
  } $token
}

# Lexer stuff interfaces incoming stream of lexemes with our parser
# Resets the cursor and next pointers.
def --env reset-cursor [] {
  $env.cursor = 0
  if ($env.tokens | length) > 1 { $env.next = 1} else { $env.next = 0 }  
}



# Saves the incoming lexeme streme in $env.tokens
def --env save-tokens [] {
  $env.tokens = $in
  reset-cursor
}


# Gets the next token and advances the cursor. Also advances the next token pointer.
def --env get-token [] {
  let tok = ($env.tokens | get $env.cursor)
  $env.cursor += 1
  $env.next. += 1
  $tok
}





# Examines the token at the current cursor
def cursor [] {
  $env.tokens | get $env.cursor
}

# Look ahead at the next token in the stream
def peek [] {
  $env.tokens | get -i  $env.next
}

# Initializes the parser (so far)
def --env init-parser [] {
  read-ignore | append (lex-eos 0) | save-tokens
}


# True if  typeof item is not a list and one of the valid lexeme atomic types
def atomic? [] -> bool {
  let data = $in
  if ($data | typeof) == 'list' {
    false
  } else {
    match $data {
      {type: string} => true,
      {type: int} => true,
      {type: bool} => true,
      _ => { syntax-error $"Not an atomic type: ($data)" }
    }
  }
}


# Either one (parser in a) closure or the other must succeed.
# If the first parser succeeds, then other parser is short-circuited.
def --env either [left: closure, right: closure] {
  try {
  do --env $left
} catch { do --env  $right }
}


# Main parser

# Parses  either an atom or a list recursively
def --env parse-sexp [] {
  either { parse-atom } { parse-list }
}




# Parses the next token if it is atomic and advances the cursor
# Returns the value of the lexeme encountered
def --env parse-atom [] {
  if (cursor | atomic?) {
  get-token | get value
  } else {
    syntax-error $"Encountered an on-atomic lexeme"
  }
}


# Parses a single list (tODO fix this comment)
def --env parse-list [] -> list {
  mut sexp = []
  match-consume { lparen? } 'lparen'
  while not ((match-it { rparen? }) or (match-it { eos? })) {
$sexp = ($sexp | append [(parse-sexp)])
  }
  match-consume { rparen? } 'rparen'
  $sexp
}


# Reads input, lexes it and initializes the parser
def --env r1 [] {
  input '>> ' |  init-parser
}




# Start here

# Invokes the parser chain
def --env scm-parse [] {
  init-parser
  let sexp = (parse-sexp)
  if not (cursor | eos?) {
  syntax-error 'Expected end of input, but got something else'
} else {
    $sexp
  }
}
