module Main

import Data.Fin
import Data.Vect

--------------------------------------------------------------------------------
-- Player

data Player = X | O | N  -- N means nobody
instance Eq Player where
    X == X = True
    O == O = True
    N == N = True
    _ == _ = False
instance Show Player where
    show X = "X"
    show O = "O"
    show N = " "

otherPlayer : Player -> Player
otherPlayer p = case p of
    X => O
    O => X
    N => N

--------------------------------------------------------------------------------
-- BoardSquares (and accessors)

BoardSquares : Type
BoardSquares = Vect 9 Player

blankBoardSquares : BoardSquares
blankBoardSquares = [N,N,N,N,N,N,N,N,N]

rows : BoardSquares -> Vect 3 (Vect 3 Player)
rows [a,b,c,d,e,f,g,h,i] = [[a,b,c],[d,e,f],[g,h,i]]

cols : BoardSquares -> Vect 3 (Vect 3 Player)
cols sqs = transpose (rows sqs)

--------------------------------------------------------------------------------
-- Board (and Accessors)

record Board : Type where
    MkBoard : (squares : BoardSquares) ->
              (whoseTurn : Player) -> Board

initialBoard : Board
initialBoard = MkBoard blankBoardSquares X

BoardLocation : Type
BoardLocation = Fin 9

{-
-- TODO: Need to fix type of (+) in the standard library first.
--       Should be:      (Fin n) -> (Fin m) -> (Fin (n + m - 1))
--       But is instead: (Fin n) -> (Fin m) -> (Fin (n + m))
mkBoardLocation : Fin 3 -> Fin 3 -> BoardLocation
mkBoardLocation x y =
    (y + y + y) + x
     3   5   7    9
 -}

square : Board -> BoardLocation -> Player
square b loc =
    index loc (squares b)

isPositionOccupied : Board -> BoardLocation -> Bool
isPositionOccupied b loc =
    (square b loc) /= N

--------------------------------------------------------------------------------
-- winner : BoardSquares -> Maybe Player

allEqTo : Eq t => t -> Vect n t -> Bool
allEqTo e Nil       = True
allEqTo e (x :: xs) = if x == e then (allEqTo e xs)
                                else False

allEq : Eq t => Vect n t -> Bool
allEq Nil       = True
allEq (x :: xs) = allEqTo x xs

winnerInList : Vect (S n') Player -> Maybe Player
winnerInList (x :: xs) = 
    let isWinner = allEq (x :: xs) in
    if isWinner then if x /= N then Just x
                               else Nothing
                else Nothing

-- TODO: Surely this is in the standard library...
firstJust : Vect n (Maybe t) -> Maybe t
firstJust Nil       = Nothing
firstJust (m :: ms) =
    case m of
        Nothing => firstJust ms
        Just x  => Just x

-- TODO: Surely this is in the standard library...
firstJust' : List (Maybe t) -> Maybe t
firstJust' Nil       = Nothing
firstJust' (m :: ms) =
    case m of
        Nothing => firstJust' ms
        Just x  => Just x

winnerRowCol : BoardSquares -> Maybe Player
winnerRowCol sqs = firstJust' [firstJust (map winnerInList (rows sqs)),
                               firstJust (map winnerInList (cols sqs))]

winnerDiag : BoardSquares -> Maybe Player
winnerDiag [a,b,c,d,e,f,g,h,i] = 
    if      a == e && e == i && a /= N then Just a
    else if c == e && e == g && c /= N then Just c
                                       else Nothing

{-
-- TODO: Surely this is in the standard library...
-- TODO: Figure out why I can't match on Nil. Compile error.
-- TODO: Rename "eType" to "E" without confusing the compiler.
-- TODO: Reorder arguments to be: Vect n eType -> eType -> Maybe (Fin n)
indexOf : Eq eType => {n:Nat} -> eType -> Vect n eType -> Maybe (Fin n)
indexOf {n} e v =
    case v of
        Nil => 
            Nothing
        x::xs => 
            case (x == e) of
                True =>
                    Just (the (Fin n) 0)
                False =>
                    case (indexOf e xs) of
                        Just index => index + 1  -- NOTE: requires linear memory
                        Nothing    => Nothing
-}

-- TODO: Surely this is in the standard library...
contains : Eq eType => Vect n eType -> eType -> Bool
contains Nil e =
    False
contains (x::xs) e =
    (e == x) || (contains xs e)

winnerTie : BoardSquares -> Maybe Player
winnerTie sqs =
    if (contains sqs N) then Nothing
                        else Just N

winner : BoardSquares -> Maybe Player
winner sqs = firstJust' [winnerRowCol sqs, winnerDiag sqs, winnerTie sqs]

--------------------------------------------------------------------------------
-- Board Mutators

-- TODO: Exercise: Refuse to play at an occupied location at *compile* time
-- TODO: Exercise: Refuse to play if there is a winner at *compile* time
move : Board -> BoardLocation -> Maybe Board
move b loc = 
    if (not (isJust (winner (squares b)))) &&
       (not (isPositionOccupied b loc)) then
        Just (MkBoard (replaceAt loc (whoseTurn b) (squares b))
                                  (otherPlayer (whoseTurn b)))
    else
        Nothing

-- TODO: Implement a takeMoveBack method
-- TODO: Exercise: Refuse to take back a move on an empty board at *compile* time

--------------------------------------------------------------------------------
-- Main

-- NOTE: Implementation is probably quadratic time unless recursive string
--       appends are specially optimized. Unlikely.
-- 
-- TODO: Figure out how to make this work with (List String)
--       in addition to (Vect n String). Probably some kind of
--       type generalization is required.
intercalateAcc : String -> Vect n String -> String -> String
intercalateAcc separator Nil result =
    result
intercalateAcc separator (x::xs) result =
    intercalateAcc separator xs (result ++ separator ++ x)

intercalate : String -> Vect n String -> String
intercalate separator Nil =
    ""
intercalate separator (x::xs) =
    intercalateAcc separator xs x

formatCell : Player -> String
formatCell cell =
    " " ++ (show cell) ++ " "

formatBoardRow : Vect 3 Player -> String
formatBoardRow row = 
    intercalate "|" (map formatCell row)

formatBoardSquares : BoardSquares -> String
formatBoardSquares sqs = 
    intercalate "\n---|---|---\n" (map formatBoardRow (rows sqs))

formatBoard : Board -> String
formatBoard board =
    formatBoardSquares (squares board)

inputFin : (n:Nat) -> IO (Fin n)
inputFin n = do
    line <- getLine
    -- TODO: Detect and reject non-integer input
    let int = the Integer (cast line)
    case (integerToFin int n) of
        Just int' => return int'
        Nothing   => inputFin n  -- out of bounds; try again

runGame : Board -> IO ()
runGame board = do
    putStrLn (formatBoard board)
    putStrLn ""
    case (winner (squares board)) of
        Just theWinner =>
            case theWinner of
                N => putStrLn "Tie!"
                _ => putStrLn ((show theWinner) ++ " wins!")
        Nothing => do
            putStr "Next move? (0-8) "
            loc' <- inputFin 9 
            putStrLn ""
            let loc = the BoardLocation loc'
            case (move board loc) of
                Just newBoard => runGame newBoard
                Nothing       => runGame board    -- illegal move; try again

main : IO ()
main = do
    runGame initialBoard
    