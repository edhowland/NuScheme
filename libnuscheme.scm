(define pair? cons?)
(define inc (lambda (n) (+ n 1)))

(define atom? (lambda (x) (not (pair? x))))
