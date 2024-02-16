# Todo list


- ,? Fix: built in proc: cons?
  * Was fixed

Because builtins must deal ONLY with Nu internal data types


- Must Fix: cons list do not work correctly

```scm
(define l (cons 1 (cons 2 null)))

(car l)
```

throws error
