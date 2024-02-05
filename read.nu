# The Scheme reader - Used in both the REPL and when used in the load procedure

source typeof.nu
source errors.nu
source lex.nu

# The ordered list of matchers with precedence given over to more relevant
# matches. E.g. '(', ')' parens and '#t', '#f' are given higher precedence
# than raw strings

let scheme_matchers = [
  {|n| match-eos $n },
  {|n| match-whitespace $n },
  {|n| match-bool $n },
  {|n| match-int $n }
  {|n| match-paren $n },
  {|n| match-string $n },
]


# inner extractor
def read-lexeme [n: int] {
  let s = $in
  $scheme_matchers | each {|m| $s | do $m $n } | skip until {|it| $it | option some? } | first 1 | get 0 | option value
}

def read [] {
  let s = $in; let eos_ndx = ($s | str length)

  $env.offset = 0
  $env.result = []
  while $env.offset < $eos_ndx {
  $s | read-lexeme $env.offset | collect --keep-env {|it| $env.offset += $it.len; $env.result = ($env.result | append $it) }
#print -e $"off: ($env.offset), result: ($env.result)"
  }
  $env.result
}




# Ignores whitespace lexemes in the input stream
def ignore-whitespace [] {
  filter {|it|
    match $it {
      {type: ws, value: _, offset: _, len: _} => { false },
      _ => { true }
    }
  }
}


# lexer for string that ignores whitespace
def read-ignore [] {
  read | ignore-whitespace
}
