# primitives for tracing the execution of procedure calls

# the trace log is stored in the environment. The trace hook is a closure
# that must be executed witha 'do --env $env._trace_hook string args'



# Writes list to trace log
def trace-logf [logfname='trace.log'] {
  to nuon | save --append $logfname
  "\n" | save --append $logfname
} 
$env._trace_log = []
$env._trace_hook = {|...rest| $env._trace_log = ($env._trace_log | append [$rest]); $rest | trace-logf }

# Displays the current log in human readable format
def disp-trace [] {
  $env._trace_log | each {|i| $i | str join ' ' }
}


# Friendly way to call the $env._trace_hook closure
alias trace-it = do --env $env._trace_hook



# testing
def fun-with-tracing [] { trace-it 'in fun-with-tracing' }




# Initialize
rm -f trace.log

trace-it $"Start trace: (date now | date to-record)"
