# collapsing of eval() frames detects when error occurs within eval()

    Code
      # Full
      print(trace, simplify = "none", dir = dir, srcrefs = srcrefs)
    Output
          x
       1. +-base::eval()
       2. \-base::.handleSimpleError(...)
       3.   \-rlang (local) h(simpleError(msg, call))
    Code
      # Focused
      print_focused_trace(trace, dir = dir, srcrefs = srcrefs)
    Output
          x
       1. +-base::eval()
       2. \-base::.handleSimpleError(...)
       3.   \-rlang (local) h(simpleError(msg, call))
    Code
      # Branch
      print(trace, simplify = "branch", dir = dir, srcrefs = srcrefs)
    Output
       1. base::eval()
       2. base::.handleSimpleError(...)
       3. rlang (local) h(simpleError(msg, call))

