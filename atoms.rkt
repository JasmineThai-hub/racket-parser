#lang racket
(require "helper.rkt")
(require megaparsack megaparsack/text)
(require data/monad data/applicative)
(require data/either)
(provide (all-defined-out))


;;; ~~~ Atoms ~~~
; Define the reserved keywords parser:
(define reserved-word/p
  (or/p (try/p (string/p "write")) ; wrapped in try/p so it matches just the word. This allows for write01 to be used as a label
        (try/p (string/p "while"))
        (try/p (string/p "if"))
        (try/p (string/p "read"))
        (try/p (string/p "goto"))
        (try/p (string/p "gosub"))
        (try/p (string/p "return"))
        (try/p (string/p "break"))
        (try/p (string/p "end"))))

(define reserved-word-followed-by-unlikely-char/p ; parses for the reserved-word with \0 to essentially fail if the id is a reserved word.
  (do [_ <- reserved-word/p]
      [_ <- (string/p "\0")]
      (pure #f))) ; Doesn't matter what we return, this should always fail.


; id -> [a-zA-Z][a-zA-Z0-9]*
(define id/p
  (do [not-reserved <- (or/p reserved-word-followed-by-unlikely-char/p (pure #t))]
      [first-char <- letter/p]
      [rest-chars <- (many/p (or/p letter/p digit/p))]
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
