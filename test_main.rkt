#lang racket
(require "parser.rkt")
(require data/either)


; Get all files from the input directory
(define all-files (directory-list "input"))


; Mutable hash to store results for each file
(define results (make-hash))

(for-each (lambda (file)
            (define full-path (string-append "input/" (path->string file)))
            (printf "~n======================== ~a ========================~n~n" full-path)
            (match (parse full-path)
              [(success result) 
               (pretty-print result) 
               (printf "~n~nACCEPT :) ~n~n")
               (hash-set! results full-path 'success)]
              [(failure err-msg) 
               (displayln err-msg) 
               (printf "~n~nDENY :( ~n~n")
               (hash-set! results full-path 'failure)]))
          all-files)

; Print summary in sorted order
(printf "\n\n================= SUMMARY =================\n")
(for-each (lambda (file)
            (printf "~a: ~a~n" file (hash-ref results file)))
          (sort (hash-keys results) string<?))
