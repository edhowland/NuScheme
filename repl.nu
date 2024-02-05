# The main Read-Eval-Print Loop


# Stores an initial prompt
$env.__ = (define 'scm-prompt' '>> ', $env.__)

# Set up a way to exit via break
$env.__ = (define exit (builtin make exit [] {|| break }) $env.__)


# Single fire of Read-Eval-print
def --env rep [] {
  try {
    input (lookup 'scm-prompt' $env.__) | scm-parse | scm-eval | scm-print
  } catch {|e| print -e $e.msg }
}



# For testing
# Read then Eval only
def --env re [] {
    input (lookup 'scm-prompt' $env.__) | scm-parse | scm-eval
}


# For testing
# only parses the input but does not eval it
def --env r [] {
    input (lookup 'scm-prompt' $env.__) | scm-parse
}



# The loop for REPL . Loops over rep above, can exit via (exit)
alias scm-repl = loop { rep }
