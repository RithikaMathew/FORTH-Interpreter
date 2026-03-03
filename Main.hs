module Main where

-- Running: cabal run tests/t1.4TH

import Interpret
import System.Environment

main :: IO ()
main = do
    (fileName:_) <- getArgs
    contents <- readFile fileName
    let (stack, output) = interpret contents
    putStr output
    if null stack
        then return ()
        else do
            putStrLn "Warning: Stack not empty at end of execution"
            putStrLn $ "Stack: " ++ show stack
