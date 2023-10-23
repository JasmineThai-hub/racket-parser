#lang racket
(require "helper.rkt")
(require "atoms.rkt")
(require "expressions.rkt")
(require megaparsack megaparsack/text)
(require data/monad data/applicative)
(require data/either)

(provide (all-defined-out))


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
   (try/p (do (string/p "write")
            [ws1 <- (or/p whitespace/p)]
            [e <- (log-parser "Stmt: Attempting to parse expr in WRITE" expr/p)]
            [ws2 <- (or/p whitespace/p)]
            (string/p ";")
            (pure (list 'write e))))
   (try/p (do (string/p "while")
            [ws1 <- (or/p whitespace/p)]
            (string/p "(")
            [ws2 <- (or/p whitespace/p)]
            [cond <- (log-parser "Stmt: Attempting to parse boolean/p in while" boolean/p)]
            [ws3 <- (or/p whitespace/p)]
            (string/p ")")
            [ws4 <- (or/p whitespace/p)]
            [ll <- (log-parser "Stmt: Attempting to parse linelist in while" linelist/p)]
            [ws5 <- (or/p whitespace/p)]
            (string/p "endwhile")
            [ws6 <- (or/p whitespace/p)]
            (string/p ";")
            (pure (list 'while cond ll 'endwhile))))
   (try/p (do (string/p "if")
            [ws1 <- (or/p whitespace/p)]
            (string/p "(")
            [ws2 <- (or/p whitespace/p)]
            [cond <- boolean/p]
            [ws3 <- (or/p whitespace/p)]
            (string/p ")")
            [ws4 <- (or/p whitespace/p)]
            [s <- (log-parser "Stmt: Attempting to parse stmt in IF" stmt/p)]
            (pure (list 'if cond s))))
   (try/p (do (string/p "read")
            [ws1 <- (or/p whitespace/p)]
            [identifier <- id/p]
            [ws2 <- (or/p whitespace/p)]
            (string/p ";")
            (pure (list 'read identifier))))
   (try/p (do (string/p "goto")
     [ws1 <- (or/p whitespace/p)]
     [identifier <- id/p]
     [ws2 <- (or/p whitespace/p)]
     (string/p ";")
     (pure (list 'goto identifier))))
   (do (string/p "gosub")
     [ws1 <- (or/p whitespace/p)]
     [identifier <- (log-parser "Stmt: Attempting to parse id/p in GOSUB!!!" id/p)]
     [ws2 <- (or/p whitespace/p)]
     (string/p ";")
     (pure (list 'gosub identifier)))
   (try/p (do (string/p "return")
            [ws1 <- (or/p whitespace/p)]
            (string/p ";")
            (pure 'return)))
   (try/p (do (string/p "break")
            [ws1 <- (or/p whitespace/p)]
            (string/p ";")
            (pure 'break)))
   (try/p (do (string/p "end")
            [ws1 <- (or/p whitespace/p)]
            (string/p ";")
            (pure 'end)))
   (try/p (do [identifier <- id/p]
            [ws1 <- (or/p whitespace/p)]
            (string/p "=")
            [ws2 <- (or/p whitespace/p)]
            [e <- expr/p]
            [ws3 <- (or/p whitespace/p)]
            (string/p ";")
            (pure (list 'assign identifier e))))))


;;; ~~~ Program Structure ~~~

; label -> id: | epsilon 
(define label/p 
  (or/p
    (do [identifier <- (try/p (do [id <- id/p]
                                (string/p ":")
                                (pure id)))]
        (pure identifier))
    void/p))


; linetail -> stmt+ | epsilon 
(define linetail/p
  (or/p (do [stmts <- (many/p stmt/p)]
          (pure stmts))
        void/p))

; line ->  label stmt linetail
(define line/p
  (or/p 
    (do [label <- (try/p (do [l <- (log-parser "Line: Attempting to parse label" label/p)]
                            (many/p space/p)
                            (pure l)))]
        [stmt <- (log-parser "Line: Attempting to parse stmt" stmt/p)]
        [tail <- (log-parser "Line: Attempting to parse linetail" linetail/p)]
        (pure (list (list label) stmt tail)))
    (do [stmt <- (log-parser "Line: Attempting to parse stmt" stmt/p)] ; No label case
        [tail <- (log-parser "Line: Attempting to parse linetail" linetail/p)]
        (pure (list '() stmt tail)))))


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
