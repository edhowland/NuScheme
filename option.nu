# The Option or Maybe monad
# Just wrappers, constructors and predicates and unwrappers

def "option some" []: any -> record {
  let val = $in
  {type: Option, _: { Some: $val }}
}


def "option none" [] -> record {
  {type: Option, _: { None: null } }
}


def "option map" [cl: closure] {
  let o = $in
  match $o {
    {type: Option, _: {Some: $v}} => { do $cl $v },
    {type: Option, _: {None: null}} => { },
    _ => { type-error 'Option' ($o | describe) }
  }
}


def "option value" []: record -> any {
  option map {|x| $x }
}


alias "option unwrap" = option value


def "option some?" []: record -> bool {
  match $in {
    {type: Option, _: {Some: _}} => { true },
    {type: Option, _: {None: _}} => { false },
    _ => { type-error 'Option' 'unknown' }
  }
}


def "option none?" []: record -> bool {
  match $in {
    {type: Option, _: {None: _}} => { true },
    {type: Option, _: {Some: _}} => { false },
    _ => { type-error 'Option' 'unknown' }
  }
}


# Get the  type (if any) of the Option, and maybe its value
def "option type" [] {
  match $in {
    {type: Option, _: { Some: $v}} => { $"Some\(($v)\)" },
    {type: Option, _: {None: _}} => { "None" },
    _ => { "Not an Option" }
  }
}
