#lang racket
(require "parser.rkt")
(require data/either)


; Get filename from User input
(printf "Enter the filename (e.g., 'source1.txt'): ")
(define filename (string-append "input/" (read-line)))

; Parse the given file
(match (parse filename)
  [(success result) (pretty-print result) (printf "~n~nACCEPT :) ~n~n")]
  [(failure err-msg) (displayln err-msg) (printf "~n~nDENY :( ~n~n")])
