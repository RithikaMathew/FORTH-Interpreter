# FORTH Interpreter

A Haskell implementation of a FORTH-like stack-based interpreter.

## How to Build and Run

Make sure you are inside the `FORTH` directory before running any commands.

### Install dependencies

```
cabal install
```

### Build the executable

```
cabal build
```

### Run a FORTH program

```
cabal run tests/t1.4TH
```

Or directly with the compiled executable:

```
dist/build/FORTH/FORTH tests/t1.4TH
```

### Run the unit tests

Each spec file can be run independently using `runhaskell`:

```
runhaskell ValSpec.hs
runhaskell EvalSpec.hs
runhaskell InterpretSpec.hs
```

You need `hspec` installed: `cabal install hspec`

## Language Features

### Stack Operations

- `DUP` — duplicate the top element of the stack

### Arithmetic Operators

All operators pop two values and push the result. The top of stack is the
right-hand operand (e.g. `8 2 /` computes 8 ÷ 2 = 4).

| Operator | Description               | Example           |
|----------|---------------------------|-------------------|
| `*`      | Multiplication            | `3 4 *` → `12`   |
| `+`      | Addition                  | `3 4 +` → `7`    |
| `-`      | Subtraction (second − top)| `10 3 -` → `7`   |
| `/`      | Division (second ÷ top)   | `8 2 /` → `4`    |
| `^`      | Power (second ^ top)      | `2 10 ^` → `1024`|

Integer arguments produce integer results; if either argument is a float the
result is a float.

### Output Operations

| Word       | Description                                             |
|------------|---------------------------------------------------------|
| `.`        | Pop and print the top of the stack                      |
| `CR`       | Print a newline                                         |
| `EMIT`     | Pop a number and print the ASCII character for that code |
| `STR`      | Convert the top of stack to its string representation   |
| `CONCAT2`  | Concatenate top two strings (second ++ top)             |
| `CONCAT3`  | Concatenate top three strings (third ++ second ++ top)  |

### User-Defined Words (Bonus)

You can define your own words using the FORTH `: name ... ;` syntax:

```
: SQUARE DUP * ;
5 SQUARE .
```

Definitions can appear anywhere in the program. A defined word can call other
previously defined words.

## Non-Empty Stack Warning

If any values remain on the stack when execution finishes, the interpreter
prints a warning and shows the leftover stack contents:

```
Warning: Stack not empty at end of execution
Stack: [Integer 3,Integer 2,Integer 1]
```

## Functional Tests

Test programs live in the `tests/` directory. Each `.4TH` file has a
corresponding `.out` file with the expected output.

| File         | Description                             |
|--------------|-----------------------------------------|
| `t1.4TH`     | Basic multiplication                    |
| `t2.4TH`     | Addition and subtraction                |
| `t3.4TH`     | Division and power                      |
| `t4.4TH`     | EMIT — print "Hello" via ASCII codes    |
| `t5.4TH`     | STR and CONCAT2                         |
| `t6.4TH`     | DUP and multiplication                  |
| `t7.4TH`     | Non-empty stack warning                 |
| `t8.4TH`     | User-defined word SQUARE (bonus)        |
| `t9.4TH`     | CONCAT3                                 |
| `t10.4TH`    | User-defined word CUBE (bonus)          |

## Notes on Implementation

- **Arithmetic**: Mixed integer/float expressions promote to float, matching
  standard Haskell numeric coercion.
- **`^` power**: Uses Haskell's built-in `^` for integer exponentiation and
  `**` for float.
- **User-defined words**: Implemented by threading a `Data.Map` dictionary
  through the interpreter state machine. Definitions are recorded as token
  lists and re-executed via `foldl` when the word is called.
- **Flow dependency removed**: The rewritten interpreter uses standard Haskell
  function application instead of the `flow` pipe operator.

## Packaging

Before submitting, remove the `dist` directory (contains the large compiled
executable):

```
rm -rf dist
```

Then create the zip archive:

```
zip -r FORTH.zip FORTH/
```
## Development Notes/ Challenges

- Had to install QuickCheck and hspec outside the project directory 
  using `cabal install --lib` due to cabal project conflicts
- GHC installation was initially broken and required a manual 
  reinstall via ghcup
- The containers package needed to be explicitly passed when running 
  InterpretSpec.hs with runhaskell
