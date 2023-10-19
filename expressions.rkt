#lang racket
(require "helper.rkt")
(require "atoms.rkt")
(require megaparsack megaparsack/text)
(require data/monad data/applicative)
(require data/either)

(provide (all-defined-out))


;;; ~~~ Expressions ~~~

; expr -> id etail | num etail | (expr)
(define expr/p
  (or/p (do [identifier <- (log-parser "Expr: Attempting to parse identifier" id/p)]
            [ws1 <- (or/p whitespace/p)]
            [tail <- etail/p]
            (pure (list identifier tail)))
        (do [number <- (log-parser "Expr: Attempting to parse num" num/p)]
            [ws1 <- (or/p whitespace/p)]
            [tail <- etail/p]
            (pure (list number tail)))
        (do (string/p "(")
            [ws1 <- (or/p whitespace/p)]
            [e <- expr/p]
            (string/p ")")
            (pure e))))


; boolean -> true | false | expr bool-op expr 
(define boolean/p
  (or/p (string/p "true")
        (string/p "false")
        (do [lhs <- expr/p]
            [op <- bool-op/p]
            [rhs <- expr/p]
            (pure (list op lhs rhs)))))


; etail -> + expr | - expr | * expr | / expr | epsilon
(define etail/p
  (or/p (do [op <- (or/p (string/p "+") (string/p "-") (string/p "*") (string/p "/"))]
            [ws1 <- (or/p whitespace/p)]
            [e <- expr/p]
            (pure (list op e)))
        void/p))
