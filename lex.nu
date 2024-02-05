# The Scheme lexer

# TODO: refactor this out the common parse --regex bits
# Refactor steps:
#
# 1. Refactor Function in all the lex-* functions
#   * New function will take a regex pattern and a closure (The continuation)
# 2. Generalize the Lexeme constructors
#  * New function: 'lexeme make <type> <value> <offset> <len>
# 3. Redo all the match-* functions to  simplify and elminate all the individual lex-* functions

source option.nu


# These are constructors for Scheme lexemes.
# Given a string on the input, convert it into a record of:
#
# {type: int, value: 99, offset: 0, len 2}
# {type: string, value: 'cons', offset: 22, len 5}
# ... etc.


# The default lexeme. Used by parser to start the parsing process.
def "lexeme default" [] -> record {
  {type: default, value: null, offset: -1, len: -1}
}


# Returns a closure suitable for the filter  command
def lexeme-default? [
    --not (-n) # Logical not of the result
  ] {
  {|v|
    match $v {
      {type: default, value: _, offset: _, len: _} => { (not $not) and true },
      _ => { ($not) or false }
    }
  }
}

# Returns true if this lexeme is a default.


# Finds a empty or end of input and constructs a EOS lexeme
def lex-eos [n: int] -> record {
  if ($in | is-empty) {
    { type: eos, value: '', offset: $n, len: 0}
  } else {
    type-error 'Empty string' 'Not an empty string'
  }
}


# Constructor for the whitespace lexeme
def lex-whitespace [n: int] -> record {
  let s = $in
  try {
    let poss = ($s | parse --regex '^(\s+)' | get capture0.0)
    {type: ws, value: $poss, offset: $n, len: ($poss | str length) }
  } catch {
    type-error 'String consisting of only whitespace' 'unknown'
  }
}



# Constructor for the bool lexeme
def lex-bool [n: int] -> record {
  let s = $in
  try {
    let poss = ($s | parse --regex '^(#t|#f)' | get capture0.0) 
    let poss_len = ($poss | str length)
    match $poss {
      '#t' => { {type: bool, value: true, offset: $n, len: $poss_len } },
      '#f' => { {type: bool, value: false, offset: $n, len: $poss_len } },
    }
  } catch {
    type-error 'Scheme boolean literal' 'unknown'
  }
}

# Constructs a new integer lexeme from input with offset
def lex-int [n: int] -> record {
  let s = $in
  try {
    let poss = ($s | parse --regex '^(-?[0-9]+)' | get capture0.0)
    if ($poss | is-empty) { runtime-error }
  let i = ($poss | into int)
    let l = ($poss | str length)
    {type: int, value: $i, offset: $n, len: $l}
  } catch { type-error 'int' ($s | typeof) }
}


# Returns string  lexeme with offset n and len of length of passed in string
# This is probably broken
def lex-string [n: int] -> record {
  let s = $in
  try {
    let poss = ($s | parse --regex '^([^\(\)#0-9][^\(\) \n\t]*)' | get capture0.0)
  { type: string, value: $poss, offset: $n, len: ($poss | str length)}
  } catch {
  type-error 'string' 'unknown'
  }
}







def lex-paren [n] -> record {
  let s = $in
  try {
    let poss = ($s | parse --regex '^(\(|\))' | get capture0.0)
    let poss_len = ($poss | str length)
    match $poss { "\(" => { {type: lparen, value: $poss, offset: $n, len: $poss_len} }, "\)" => { {type: rparen, value: $poss, offset: $n, len: $poss_len } } }
  } catch {
    type-error 'Parenthesis' $"<($s)>"
  }
}


# Lexeme matchers
# Each type are tried and if succesful, returns a Some(<lexeme-type>), else None

# Tries to match the end of the string
def match-eos [off: int] -> record {
  try {
    lex-eos $off | option some
  } catch {
    option none
  }
}


def match-whitespace [off: int] -> record {
  try {
    str substring $off.. | lex-whitespace $off | option some
  } catch {
    option none
}
}


def match-int [off: int] -> record {
  let val = $in
  try {
    $val | str substring $off.. | lex-int $off  | option some
  } catch {
    option none
  }
}




def match-string [off: int] -> record {
  try {
    str substring $off.. | lex-string $off | option some
  } catch {
    option none
  }
}



def match-bool [off: int] -> record {
    try {
    str substring $off.. | lex-bool $off | option some
  } catch {
    option none
  }
}


def match-paren [off: int] -> record {
    try {
    str substring $off.. | lex-paren $off | option some
  } catch {
    option none
  }
}





# Testing matchers


# Always succeeds with lexeme: default
def match-successs [off: int] -> record {
  str substring $off.. | lex-default $off | option some
}

# Always fails on any input returning None every time.
# Useful for insrting broken lexemes somewhere within the precedence stack.
def match-fail [off: int] -> record {
  option none
}


# convenience methods. Possibly useful to parsers


# Unwraps a lexeme to its value, throwing an type error if not a lexeme
def "lex unwrap" [] -> any {
  match $in {
    {type: _, value: $value, offset: _, len: _} => { $value },
    _ => { type-error 'Lexeme' 'unknown' }
  }
}


# Predicates

# Returns true if item is a Lexeme
def is-lexeme [] {
  let data = $in
  match $data {
    {type: _, value: _, offset: _, len: _} => { true },
    _ => { false }
  }
}



# TODO: Consider removing this alias and just renaming the OG fn
alias "lexeme unwrap" = alex unwrap

# Is the lexeme some sort of whitespace?
# Returns true if type is ws
def is-whitespace [] {
match $in {
      {type: ws, value: _, offset: _, len: _} => true,
      _ => false
    }
}


# constructor for simple types


# Creates a stand-alone left paren lexeme
def "lparen make" [] { '(' | lex-paren 0 }

# Creates a stand-alone right paren lexeme
def "rparen make" [] { ')' | lex-paren 0 }


# lexeme matching

# Is the input item eq? in type to the parameter?
def type-eq? [that: record] -> bool {
  let data = $in
  match $data {
    {type: $type} if $that.type == $type => true, 
  _ => false
  }
}
