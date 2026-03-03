-- HSpec tests for Eval.hs
-- Execute: runhaskell EvalSpec.hs

import Test.Hspec
import Test.QuickCheck
import Control.Exception (evaluate)
import Val
import Eval

main :: IO ()
main = hspec $ do
  describe "eval" $ do
    context "*" $ do
        it "multiplies integers" $ do
            eval "*" [Integer 2, Integer 3] `shouldBe` [Integer 6]

        it "multiplies floats" $ do
            eval "*" [Integer 2, Real 3.0] `shouldBe` [Real 6.0]
            eval "*" [Real 3.0, Integer 3] `shouldBe` [Real 9.0]
            eval "*" [Real 4.0, Real 3.0] `shouldBe` [Real 12.0]

        it "errors on too few arguments" $ do
            evaluate (eval "*" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (eval "*" [Integer 2]) `shouldThrow` errorCall "Stack underflow"

    context "+" $ do
        it "adds integers" $ do
            eval "+" [Integer 3, Integer 5] `shouldBe` [Integer 8]

        it "adds floats and integers" $ do
            eval "+" [Real 1.5, Integer 2] `shouldBe` [Real 3.5]
            eval "+" [Integer 1, Real 2.5] `shouldBe` [Real 3.5]
            eval "+" [Real 1.0, Real 2.0] `shouldBe` [Real 3.0]

        it "errors on too few arguments" $ do
            evaluate (eval "+" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (eval "+" [Integer 1]) `shouldThrow` errorCall "Stack underflow"

    context "-" $ do
        -- "5 3 -" pushes 5 then 3; stack=[Integer 3, Integer 5]; result=5-3=2
        it "subtracts integers (second - top)" $ do
            eval "-" [Integer 3, Integer 5] `shouldBe` [Integer 2]
            eval "-" [Integer 5, Integer 3] `shouldBe` [Integer (-2)]

        it "subtracts floats" $ do
            eval "-" [Real 1.0, Real 4.0] `shouldBe` [Real 3.0]

        it "errors on too few arguments" $ do
            evaluate (eval "-" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (eval "-" [Integer 1]) `shouldThrow` errorCall "Stack underflow"

    context "/" $ do
        -- "8 2 /" pushes 8 then 2; stack=[Integer 2, Integer 8]; result=8 div 2=4
        it "divides integers (second / top)" $ do
            eval "/" [Integer 2, Integer 8] `shouldBe` [Integer 4]
            eval "/" [Integer 3, Integer 9] `shouldBe` [Integer 3]

        it "divides floats" $ do
            eval "/" [Real 2.0, Real 6.0] `shouldBe` [Real 3.0]

        it "errors on too few arguments" $ do
            evaluate (eval "/" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (eval "/" [Integer 2]) `shouldThrow` errorCall "Stack underflow"

    context "^" $ do
        -- "2 10 ^" pushes 2 then 10; stack=[Integer 10, Integer 2]; result=2^10=1024
        it "computes integer power (second ^ top)" $ do
            eval "^" [Integer 10, Integer 2] `shouldBe` [Integer 1024]
            eval "^" [Integer 2, Integer 3] `shouldBe` [Integer 9]

        it "errors on too few arguments" $ do
            evaluate (eval "^" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (eval "^" [Integer 2]) `shouldThrow` errorCall "Stack underflow"

    context "DUP" $ do
        it "duplicates values" $ do
            eval "DUP" [Integer 2] `shouldBe` [Integer 2, Integer 2]
            eval "DUP" [Real 2.2] `shouldBe` [Real 2.2, Real 2.2]
            eval "DUP" [Id "x"] `shouldBe` [Id "x", Id "x"]

        it "errors on empty stack" $ do
            evaluate (eval "DUP" []) `shouldThrow` errorCall "Stack underflow"

  describe "evalOut" $ do
      context "." $ do
        it "prints top of stack" $ do
            evalOut "." ([Id "x"], "") `shouldBe` ([],"x")
            evalOut "." ([Integer 2], "") `shouldBe` ([], "2")
            evalOut "." ([Real 2.2], "") `shouldBe` ([], "2.2")

        it "errors on empty stack" $ do
            evaluate(evalOut "." ([], "")) `shouldThrow` errorCall "Stack underflow"

      context "EMIT" $ do
        it "prints ASCII character for integer" $ do
            evalOut "EMIT" ([Integer 65], "") `shouldBe` ([], "A")
            evalOut "EMIT" ([Integer 72], "") `shouldBe` ([], "H")
            evalOut "EMIT" ([Integer 10], "") `shouldBe` ([], "\n")

        it "prints ASCII character for float (rounded)" $ do
            evalOut "EMIT" ([Real 65.0], "") `shouldBe` ([], "A")

        it "errors on empty stack" $ do
            evaluate(evalOut "EMIT" ([], "")) `shouldThrow` errorCall "Stack underflow"

      context "CR" $ do
        it "appends newline to output" $ do
            evalOut "CR" ([], "") `shouldBe` ([], "\n")
            evalOut "CR" ([Integer 5], "hello") `shouldBe` ([Integer 5], "hello\n")

      context "STR" $ do
        it "converts integer to string on stack" $ do
            evalOut "STR" ([Integer 42], "") `shouldBe` ([Id "42"], "")
            evalOut "STR" ([Integer 0], "") `shouldBe` ([Id "0"], "")

        it "converts float to string on stack" $ do
            evalOut "STR" ([Real 3.14], "") `shouldBe` ([Id "3.14"], "")

        it "leaves Id unchanged" $ do
            evalOut "STR" ([Id "hello"], "") `shouldBe` ([Id "hello"], "")

        it "errors on empty stack" $ do
            evaluate(evalOut "STR" ([], "")) `shouldThrow` errorCall "Stack underflow"

      context "CONCAT2" $ do
        -- stack [Id "world", Id "hello"]: pops "world" then "hello", result "helloworld"
        it "concatenates two strings (second ++ top)" $ do
            evalOut "CONCAT2" ([Id "world", Id "hello"], "") `shouldBe` ([Id "helloworld"], "")
            evalOut "CONCAT2" ([Id "B", Id "A"], "") `shouldBe` ([Id "AB"], "")

        it "errors on non-string arguments" $ do
            evaluate(evalOut "CONCAT2" ([Integer 1, Id "x"], "")) `shouldThrow` anyException

        it "errors on too few arguments" $ do
            evaluate(evalOut "CONCAT2" ([Id "x"], "")) `shouldThrow` anyException

      context "CONCAT3" $ do
        -- stack [Id "3", Id "2", Id "1"]: pops "3","2","1", result "123"
        it "concatenates three strings (third ++ second ++ top)" $ do
            evalOut "CONCAT3" ([Id "3", Id "2", Id "1"], "") `shouldBe` ([Id "123"], "")
            evalOut "CONCAT3" ([Id "c", Id "b", Id "a"], "") `shouldBe` ([Id "abc"], "")

        it "errors on non-string arguments" $ do
            evaluate(evalOut "CONCAT3" ([Integer 1, Id "b", Id "a"], "")) `shouldThrow` anyException

      it "eval pass-through" $ do
         evalOut "*" ([Real 2.0, Integer 2], "blah") `shouldBe` ([Real 4.0], "blah")
