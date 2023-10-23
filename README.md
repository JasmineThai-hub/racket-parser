# Racket Parser

## Overview
This is a parser written in Racket that can interpret a custom programming language based on the provided grammar. It uses the `megaparsack` and `megaparsack/text` libraries, which provide combinator parsing capabilities.

## Dependencies
Ensure you have the following modules and libraries:
- `megaparsack`
- `megaparsack/text`
- `data/monad`
- `data/applicative`
- `data/either`

Additionally, the parser relies on three custom modules:
- `helper.rkt`
- `atoms.rkt`
- `expressions.rkt`

Ensure that these files are in the same directory or their paths are properly referenced.

## Grammar
The grammar that this parser interprets is as follows:

```
program -> linelist $$ 
linelist -> line linelist | epsilon 
line ->  label stmt linetail 
label -> id: | epsilon 
linetail -> stmt+ | epsilon 
stmt -> id = expr; 
	| if (boolean) stmt; 
	| while (boolean) linelist endwhile;
	| read id; 
	| write expr; 
	| goto id; 
	| gosub id; 
	| return;
	| break;
	| end; 
boolean -> true | false | expr bool-op expr 
bool-op -> < | > | >= | <= | <> | =
expr -> id etail | num etail | (expr) 
etail -> + expr | - expr | * expr | / expr | epsilon
id -> [a-zA-Z][a-zA-Z0-9]*
num -> numsign digit digit*
numsign -> + | - | epsilon 
```

## Usage

1. **Parsing a list of lines**
   ```racket
   (parse-lines '("line1" "line2" ...))
   ```

   This function takes a list of strings and attempts to parse them based on the provided grammar. It returns a successful parse or an error message.

2. **Reading lines from a file**
   ```racket
   (read-lines "path/to/filename")
   ```

   This function reads lines from a file and returns them as a list of strings.

3. **Parsing a file**
   ```racket
   (parse "path/to/filename")
   ```

   This function reads lines from a file and then attempts to parse them. It returns a successful parse or an error message.

## How to Run

### With `main.rkt`

1. Execute the `main.rkt` script.
   ```racket
   racket main.rkt
   ```

2. You will be prompted to input a filename.
   ```
   Enter the filename (e.g., 'source1.txt'):
   ```

3. The program will parse the given file and either `ACCEPT` it if the syntax is correct or `DENY` it with an error message if there are syntax errors.

### With `test_main.rkt`

1. Execute the `test_main.rkt` script.
   ```racket
   racket test_main.rkt
   ```

2. This script will automatically parse all files in the `input` directory and display the results for each file.

3. At the end, a summary of all parsed files and their results (either 'success' or 'failure') will be displayed.

## Note

- Parsing is done with extensive logging for debugging purposes.
- The parser expects programs to terminate with "$$" as an end symbol.
- Doesn't allow for statement keywords to be used as a label or substring of a label

---
This README.md was generated using ChatGPT and providing the parser.rkt, test_main.rkt, main.rkt, and grammar.txt files

---

Personal note: I created a parser last semester (Spring 2023) with simpler grammar so I already had an idea of how to go about creating this. Once I researched more about megaparsack, 
it totally made writing this parser MUCH easier than previously because I didn't have to 'reinvent the wheel'. It also helped debug and streamline development when I separated the parse into atoms, expressions, etc.
I absolutely loved how clear the grammar shines through by using megaparsack. Overall, I'm pretty happy with my parser, big thanks to ChatGPT for helping me debug and pretty much providing that test_main and big thanks to Reece for a good reference!
