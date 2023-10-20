#lang racket
(require "helper.rkt")
(require megaparsack megaparsack/text)
(require data/monad data/applicative)
(require data/either)
(provide (all-defined-out))


;;; ~~~ Atoms ~~~
; id -> [a-zA-Z][a-zA-Z0-9]*
(define id/p
  (do [first-char <- letter/p]  ; Start with a letter
      [rest-chars <- (many/p (or/p letter/p digit/p))]  ; Followed by zero or more letters or digits
      (pure (string->symbol (list->string (cons first-char rest-chars))))))



; numsign -> + | - | epsilon
(define numsign/p
  (or/p (string/p "+")
        (string/p "-")
        (pure "")))


; num -> numsign digit digit*
(define num/p
  (do [sign <- numsign/p]
      [d <- digit/p]
      [ds <- (many/p digit/p)]
      (pure (string->number (string-append sign (list->string (cons d ds)))))))


; bool-op -> < | > | >= | <= | <> | =
(define bool-op/p
  (do
      [ws1 <- (or/p whitespace/p)]
      [op <- (or/p (string/p "<")
                   (string/p ">")
                   (string/p ">=")
                   (string/p "<=")
                   (string/p "<>")
                   (string/p "="))]
      [ws <- (or/p whitespace/p)]
      (pure op)))
