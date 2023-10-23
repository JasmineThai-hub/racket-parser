## Sources

---

**Official racket documentation**: [https://docs.racket-lang.org/guide](https://docs.racket-lang.org/guide)

**Big reference** was **megaparsack**: [Megaparsack: Practical Parser Combinators](https://racket-lang.org)

Most of the time spent was just building from this example:

**2.2 Parsing sequences**: [racket-lang.org](https://racket-lang.org)

```racket
(define two-integers/p
    (do [x <- integer/p]
        (many/p space/p #:min 1)
        [y <- integer/p]
        (pure (list x y))))
```

using `or/p` for multiple paths as needed and used `do` to chain parsers.

**Note**: I didn’t tokenize the input because most of the examples were just consuming strings and just this line “Parsers that operate on strings, like char/p and integer/p, will not work with tokens from parser-tools/lex because tokens can contain arbitrary data.” made it undesirable.

---
**Programming Language Pragmatics by Michael L. Scott**

Ch. 2.3 Parsing Figure 2.17 for pseudocode reference

---
**Error handling**: [https://docs.racket-lang.org/reference/exns.html#%28def._%28%28quote._~23~25kernel%29._srcloc-line%29%29](https://docs.racket-lang.org/reference/exns.html#%28def._%28%28quote._~23~25kernel%29._srcloc-line%29%29)

---
**Github Reference**:

[ReeceMcMillin/CS441ParserProject: A simple Racket-based parser for a small textbook language.](https://github.com/ReeceMcMillin/CS441ParserProject)
- I tried to reference this sparsely and looked more at the megaparsack documentation. I aimed at making this parser mine by making the grammar more transparent and the code more readable

---
