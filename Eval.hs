module Eval where
-- This file contains definitions for functions and operators

import Val
import Data.Char (chr)

-- main evaluation function for operators and
-- built-in FORTH functions with no output
-- takes a string and a stack and returns the stack
-- resulting from evaluation of the function
eval :: String -> [Val] -> [Val]

-- Multiplication
-- if arguments are integers, keep result as integer
eval "*" (Integer x: Integer y:tl) = Integer (x*y) : tl
-- if any argument is float, make result a float
eval "*" (x:y:tl) = (Real $ toFloat x * toFloat y) : tl
eval "*" _ = error "Stack underflow"

-- Addition
eval "+" (Integer x: Integer y:tl) = Integer (x+y) : tl
eval "+" (x:y:tl) = (Real $ toFloat x + toFloat y) : tl
eval "+" _ = error "Stack underflow"

-- Subtraction: second - top (e.g. "5 3 -" = 2)
eval "-" (Integer x: Integer y:tl) = Integer (y-x) : tl
eval "-" (x:y:tl) = (Real $ toFloat y - toFloat x) : tl
eval "-" _ = error "Stack underflow"

-- Division: second / top (e.g. "8 2 /" = 4)
eval "/" (Integer x: Integer y:tl) = Integer (y `div` x) : tl
eval "/" (x:y:tl) = (Real $ toFloat y / toFloat x) : tl
eval "/" _ = error "Stack underflow"

-- Power: second ^ top (e.g. "2 10 ^" = 1024)
eval "^" (Integer x: Integer y:tl) = Integer (y ^ x) : tl
eval "^" (x:y:tl) = (Real $ toFloat y ** toFloat x) : tl
eval "^" _ = error "Stack underflow"

-- Duplicate the element at the top of the stack
eval "DUP" (x:tl) = (x:x:tl)
eval "DUP" [] = error "Stack underflow"

-- this must be the last rule
-- it assumes that no match is made and preserves the string as argument
eval s l = Id s : l


-- variant of eval with output
-- state is a stack and string pair
evalOut :: String -> ([Val], String) -> ([Val], String)

-- print element at the top of the stack
evalOut "." (Id x:tl, out) = (tl, out ++ x)
evalOut "." (Integer i:tl, out) = (tl, out ++ (show i))
evalOut "." (Real x:tl, out) = (tl, out ++ (show x))
evalOut "." ([], _) = error "Stack underflow"

-- EMIT: pop a number and print the ASCII character with that code
evalOut "EMIT" (Integer n:tl, out) = (tl, out ++ [chr n])
evalOut "EMIT" (Real x:tl, out) = (tl, out ++ [chr (round x)])
evalOut "EMIT" ([], _) = error "Stack underflow"

-- CR: print a newline
evalOut "CR" (stack, out) = (stack, out ++ "\n")

-- STR: convert top of stack to its string representation
evalOut "STR" (Integer n:tl, out) = (Id (show n):tl, out)
evalOut "STR" (Real x:tl, out) = (Id (show x):tl, out)
evalOut "STR" (Id s:tl, out) = (Id s:tl, out)
evalOut "STR" ([], _) = error "Stack underflow"

-- CONCAT2: concatenate top two strings (second ++ top)
evalOut "CONCAT2" (Id s1:Id s2:tl, out) = (Id (s2 ++ s1):tl, out)
evalOut "CONCAT2" _ = error "CONCAT2 requires two string arguments"

-- CONCAT3: concatenate top three strings (third ++ second ++ top)
evalOut "CONCAT3" (Id s1:Id s2:Id s3:tl, out) = (Id (s3 ++ s2 ++ s1):tl, out)
evalOut "CONCAT3" _ = error "CONCAT3 requires three string arguments"

-- this has to be the last case
-- if no special case, ask eval to deal with it and propagate output
evalOut op (stack, out) = (eval op stack, out)
