-- HSpec tests for Interpret.hs
-- Execute: runhaskell InterpretSpec.hs

import Test.Hspec
import Test.QuickCheck
import Control.Exception (evaluate)
import Val
import Eval
import Interpret

main :: IO ()
main = hspec $ do
  describe "evalF" $ do
    it "preserves output for numbers" $ do
        evalF ([], "x") (Real 3.0) `shouldBe` ([Real 3.0], "x")

    it "passes through operators" $ do
        evalF ([Real 2.2, Integer 2], "") (Id "*") `shouldBe` ([Real 4.4], "")

    it "propagates output" $ do
        evalF ([Integer 2], "") (Id ".") `shouldBe` ([],"2")

  describe "interpret" $ do
    context "RPN arithmetic" $ do
        it "multiplies two integers" $ do
            interpret "2 3 *" `shouldBe` ([Integer 6], "")

        -- numerical precision makes this tricky
        it "multiplies floats and integers" $ do
            interpret "2 2.2 3.4 * *" `shouldBe` ([Real 14.960001], "")

        it "adds two integers" $ do
            interpret "4 5 +" `shouldBe` ([Integer 9], "")

        it "subtracts integers (second - top)" $ do
            interpret "10 3 -" `shouldBe` ([Integer 7], "")

        it "divides integers (second / top)" $ do
            interpret "12 4 /" `shouldBe` ([Integer 3], "")

        it "computes power (second ^ top)" $ do
            interpret "2 8 ^" `shouldBe` ([Integer 256], "")

    context "Printout" $ do
        it "computes product and outputs" $ do
            interpret "2 6 * ." `shouldBe` ([], "12")

        it "outputs with CR" $ do
            interpret "3 4 + . CR" `shouldBe` ([], "7\n")

        it "emits ASCII character" $ do
            interpret "65 EMIT" `shouldBe` ([], "A")

        it "converts to string and prints" $ do
            interpret "99 STR ." `shouldBe` ([], "99")

        it "concatenates two strings" $ do
            interpret "1 STR 2 STR CONCAT2 ." `shouldBe` ([], "12")

        it "concatenates three strings" $ do
            interpret "1 STR 2 STR 3 STR CONCAT3 ." `shouldBe` ([], "123")

    context "User-defined words (bonus)" $ do
        it "defines and calls a simple word" $ do
            interpret ": SQUARE DUP * ; 5 SQUARE" `shouldBe` ([Integer 25], "")

        it "uses a user-defined word to produce output" $ do
            interpret ": DOUBLE DUP + ; 6 DOUBLE ." `shouldBe` ([], "12")

        it "defines multiple words and chains them" $ do
            interpret ": SQ DUP * ; : CUBE DUP SQ * ; 3 CUBE ." `shouldBe` ([], "27")

        it "definition does not consume stack" $ do
            interpret "4 : IGNORED DUP ; 4" `shouldBe` ([Integer 4, Integer 4], "")
