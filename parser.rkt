#lang racket
(require "helper.rkt")
(require "atoms.rkt")
(require "expressions.rkt")
(require megaparsack megaparsack/text)
(require data/monad data/applicative)
(require data/either)

(provide (all-defined-out))

;;; Note: This parser uses maybe type
;;; pure == just ==> successful match
;;; void/p == nothing ==> failed match

;;; ~~~ Statements ~~~

; stmt -> id = expr; 
; | if (boolean) stmt; 
; | while (boolean) linelist endwhile;
; | read id; 
; | write expr; 
; | goto id; 
; | gosub id; 
; | return;
; | break;
; | end;
(define stmt/p
  (or/p 
   ; if (boolean) stmt;
   (do (string/p "if")
     [ws1 <- (or/p whitespace/p)]
     (string/p "(")
     [ws2 <- (or/p whitespace/p)]
     [cond <- boolean/p]
     [ws3 <- (or/p whitespace/p)]
     (string/p ")")
     [ws4 <- (or/p whitespace/p)]
     [s <- (log-parser "Stmt: Attempting to parse stmt in IF" stmt/p)]
     (pure (list 'if cond s)))

   ; read id;
   (do (string/p "read")
     [ws1 <- (or/p whitespace/p)]
     [identifier <- id/p]
     [ws2 <- (or/p whitespace/p)]
     (string/p ";")
     (pure (list 'read identifier)))


   ; write expr;
   (do (string/p "write")
     [ws1 <- (or/p whitespace/p)]
     [e <- expr/p]
     [ws2 <- (or/p whitespace/p)]
     (string/p ";")
     (pure (list 'write e)))
   
   ; while (boolean) linelist endwhile;
   (do (string/p "while")
     [ws1 <- (or/p whitespace/p)]
     (string/p "(")
     [ws2 <- (or/p whitespace/p)]
     [cond <- boolean/p]
     [ws3 <- (or/p whitespace/p)]
     (string/p ")")
     [ws4 <- (or/p whitespace/p)]
     [ll <- linelist/p]
     (string/p "endwhile")
     (pure (list 'while cond ll)))


   ; goto id;
   (do (string/p "goto")
     [ws1 <- (or/p whitespace/p)]
     [identifier <- id/p]
     [ws2 <- (or/p whitespace/p)]
     (string/p ";")
     (pure (list 'goto identifier)))


   ; gosub id;
   (do (string/p "gosub")
     [ws1 <- (or/p whitespace/p)]
     [identifier <- id/p]
     [ws2 <- (or/p whitespace/p)]
     (string/p ";")
     (pure (list 'gosub identifier)))

   ; return;
   (do (string/p "return")
     [ws1 <- (or/p whitespace/p)]
     (string/p ";")
     (pure 'return))

   ; break;
   (do (string/p "break")
     [ws1 <- (or/p whitespace/p)]
     (string/p ";")
     (pure 'break))

   ; end;
   (do (string/p "end")
     [ws1 <- (or/p whitespace/p)]
     (string/p ";")
     (pure 'end))

  
   ; id = expr;
   (do [identifier <- id/p]
     [ws1 <- (or/p whitespace/p)]
     (string/p "=")
     [ws2 <- (or/p whitespace/p)]
     [e <- expr/p]
     [ws3 <- (or/p whitespace/p)]
     (string/p ";")
     (pure (list 'assign identifier e)))
   ))


;;; ~~~ Program Structure ~~~

; label -> id: | epsilon 
(define label/p 
  (or/p
    (do [identifier <- (try/p (do [id <- id/p] (string/p ":") (pure id)))] ; try/p so we don't consume token if it's a reserved word (meaning it's a beginning of a statement!)
        (pure identifier))
    void/p))


; linetail -> stmt+ | epsilon 
(define linetail/p
  (or/p (do [stmts <- (many+/p stmt/p)]
          (pure stmts))
        void/p))

; line ->  label stmt linetail
(define line/p
  (do [maybe-label <- (log-parser "Line: Attempting to parse label" label/p)]
    (if maybe-label
        (many/p space/p)
        void/p)
    [stmt <- (log-parser "Line: Attempting to parse stmt" stmt/p)]
    [tail <- (log-parser "Line: Attempting to parse linetail" linetail/p)]
    (pure (list (if maybe-label (list maybe-label) '()) stmt tail))))


; linelist -> line linelist | epsilon 
(define linelist/p
  (or/p 
   (do [head <- (log-parser "Linelist: Attempting to parse line" line/p)]
     (many/p space/p)
     [tail <- (log-parser "Linelist: Attempting to parse subsequent linelist" linelist/p)]
     (log-parser "Linelist: Finished attempting to parse linelist" (pure (if (void? tail) head (flatten (list head tail))))))
   (or/p (log-parser "Linelist: Detected potential end" whitespace/p) void/p)))


; program -> linelist $$
(define program/p
  (do [ll <- (log-parser "Program: Parsing linelist" linelist/p)]
    (string/p "$$")
    (pure ll)))


;;; ~~~ Putting It All Together! ~~~
; function to parse a list of lines.
(define (parse-lines lines)
  (define input (string-join lines "\n"))

  ; Parse the input
  (define output (parse-string program/p input))

  (match output
    [(success _) output] ; Parsed Successfully!
    [(failure error) (format-error-message error lines)])) ; Show error


(define (read-lines filename)
  (define file (open-input-file filename))
  (define lines (port->lines file))
  (close-input-port file)
  lines)

; function that combines reading and parsing.
(define (parse filename)
  (define lines (read-lines filename))
  (parse-lines lines))
