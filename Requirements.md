## Introduction

The main goal of this assignment is to help you familiarize yourself with Haskell language and the workflows around `cabal`, the package/builder manager.

In this assignment, you need to add more features to the FORTH interpreter and to write extensive tests. This will be a complete project with an executable and lots of tests. The hope is that you can use this as a template for other class projects.

## Installing packages

Make sure you are inside the FORTH directory
```
cabal install; cabal install hbase
```

## Running the provided code

For general instructions on how to use `cabal` see: https://www.haskell.org/cabal/users-guide/developing-packages.html

To compile the existing code do:
```
cabal build
```

To run the code:
```
cabal run tests/t1.4TH
```
or directly the executable
```
dist/build/FORTH/FORTH
```

The last argument is the test file

## Running the unit tests

The easiest way to run the unit HSpec tests is using `runhaskell` command
```
runhaskell ValSpec.hs
runhaskell EvalSpec.hs
runhaskell InterpretSpec.hs
```

## What to do as part of the assignment

1. Change the code in `Main.hs` so that, if the stack is not empty at the end of execution,  a message gets printed on the screen saying so and the stack content gets printed. Make sure at least one of your test cases covers this situation.

2. Add more built-in function definitions to `Eval.hs` and write unit tests for them in `EvalSpec.hs`. At a minimum, you should add operators +,-,/ ^(power) and the functions:
  * `EMIT`: takes a number from the stack and prints the character with the corresponding ASCI code
  * `CR`: prints a new line (for nice formating)
  * `STR`: converts the argument into a string (needs to work for all types)
  * `CONCAT2` and `CONCAT3` concatenates 2 or 3 strings from the stack (errors if arguments not strings)

3. Write 10 complete test files `t1.4TH` to `t10.4TH` (replace existing `t1.4TH`) and 10 corresponding output files `t1.out` to `t10.out`. Your code, when executing the `*.4TH` file should produce the exact output in `*.out` file. Write the output files by hand to test the correctness of the code. These are so called "functional tests" (as opposed to the smaller unit tests)

4. Write a Readme.md file with notes on how to run your code, situations you encountered, etc.

5. Submit a `.zip` archive of your project. Before you archive, remove the dist directory (since it has a large executable in it).

## Bonus (20%)

Implement user defined functions. Look up FORTH documentation for the syntax. Write test cases covering the bonus.

Note: you need to make substantial changes to the code for this since Haskell does not allow global variables. You need to remember somehow the function definitions and apply them.



