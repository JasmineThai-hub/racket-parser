#lang racket
(require racket/struct)
(require megaparsack)
(require data/either)
(require megaparsack megaparsack/text)
(require data/monad data/applicative)
(provide (all-defined-out))

; define whitespaces
(define whitespace/p (many/p (or/p (char/p #\space) (char/p #\newline) (char/p #\tab))))

; debugging function
(define (log-parser msg p)
  (do [result <- p]
      (_ <- (pure (begin 
                    (display msg) 
                    (display ": ")
                    (display result)
                    (newline))))
      (pure result)))


; Error handling
(define (format-error-message error lines)
  ; Extract line number and the line with the error from the message source location
  (define source-location (message-srcloc error))
  (define line-number (srcloc-line source-location))
  (define error-line (list-ref lines (- line-number 1)))

  ; Error location indicator
  (define (construct-location-indicator start-length indicator-length)
    (list->string (append (make-list start-length #\space)
                          (make-list indicator-length #\^))))

  ; Error indicator
  (define error-indicator 
    (construct-location-indicator (srcloc-column source-location) (srcloc-span source-location)))

  ; Return formatted error message
  (failure (string-append (parse-error->string error)
                          "\n"
                          (number->string line-number) " | " error-line "\n"
                          "    " error-indicator "\n")))
