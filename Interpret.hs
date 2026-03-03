module Interpret where
-- this file contains the FORTH interpreter

import Val
import Eval
import qualified Data.Map.Strict as Map

-- Dictionary mapping user-defined word names to their token bodies
type Dict = Map.Map String [String]

-- States for the definition parser
data ParseState = Normal | CollectName | CollectBody String [String]

-- Execute a single token string against (stack, output, dict)
execToken :: ([Val], String, Dict) -> String -> ([Val], String, Dict)
execToken (stack, out, dict) token =
    let v = strToVal token
    in case v of
        Integer _ -> (v:stack, out, dict)
        Real _    -> (v:stack, out, dict)
        Id op ->
            case Map.lookup op dict of
                -- user-defined word: execute its body
                Just body -> foldl execToken (stack, out, dict) body
                -- built-in or unknown: delegate to evalOut
                Nothing ->
                    let (newStack, newOut) = evalOut op (stack, out)
                    in (newStack, newOut, dict)

-- Legacy inner function kept for backwards compatibility with unit tests
evalF :: ([Val], String) -> Val -> ([Val], String)
evalF s (Id op) = evalOut op s
evalF (s, out) x = (x:s, out)

-- State machine step: handles `: name ... ;` definition syntax
step :: (ParseState, [Val], String, Dict) -> String -> (ParseState, [Val], String, Dict)
-- Start of a word definition
step (Normal, stack, out, dict) ":" = (CollectName, stack, out, dict)
-- Normal execution: run the token
step (Normal, stack, out, dict) token =
    let (s', o', d') = execToken (stack, out, dict) token
    in (Normal, s', o', d')
-- Collect the name of the word being defined
step (CollectName, stack, out, dict) name = (CollectBody name [], stack, out, dict)
-- End of definition: store word in dictionary
step (CollectBody name body, stack, out, dict) ";" =
    (Normal, stack, out, Map.insert name (reverse body) dict)
-- Accumulate tokens for the word body
step (CollectBody name body, stack, out, dict) token =
    (CollectBody name (token:body), stack, out, dict)

-- Interpret a FORTH program string into (finalStack, output)
interpret :: String -> ([Val], String)
interpret text =
    let (_, stack, out, _) = foldl step (Normal, [], "", Map.empty) (words text)
    in (stack, out)
