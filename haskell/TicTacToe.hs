
import Data.List (intersperse, group)
import System.IO (print, getLine)
import System.Exit (exitSuccess)

-- 
-- Users
--
data User = X | O
    deriving(Show, Eq)

otherUser :: User -> User
otherUser X = O
otherUser O = X

-- 
-- Squares
--
data Square = Move User | Empty Int
    deriving(Eq)

instance Show Square where
    show (Move x)   = " " ++ (show x) ++ " "
    show (Empty x)  = "(" ++ (show x) ++ ")"

filled :: Square -> Bool
filled (Move _) = True
filled _        = False

-- 
-- Boards
--
data Board = Board [[Square]]
    deriving(Eq)

instance Show Board where
    show (Board ls) = concat (intersperse "---+---+---\n" (map showLine ls))
        where
            showLine xs = concat (intersperse "|" (map show xs)) ++ "\n"

full :: Board -> Bool
full (Board squares) = all filled (concat squares)

-- 
-- Results
--
data Result = Continue User Board | Error User Board | Win User Board | Draw Board

instance Show Result where
    show (Continue user board) = show board ++ "Select a square, " ++ show user ++ ": "
    show (Error user board)    = show board ++ "Select a square, " ++ show user ++ ": "
    show (Win user board)      = show board ++ show user ++ " Wins!"
    show (Draw board)          = show board ++ "It's a Draw!"

-- 
-- Initial Board
--
startingBoard :: Board
startingBoard = Board [[Empty 1,Empty 2,Empty 3],
                       [Empty 4,Empty 5,Empty 6],
                       [Empty 7,Empty 8,Empty 9]]

matchSquare :: User -> Int -> Square -> Square
matchSquare user position (Empty x) | x == position = Move user
matchSquare _ _ square                              = square

-- This evaluates the board and determines the result of the current user's action
outcome :: User -> Board -> Result
outcome user board =
      case board of
           (Board [[a, _, _],
		           [_, b, _],
				   [_, _, c]]) | eq a b c -> Win user board

           (Board [[_, _, a],
				   [_, b, _],
				   [c, _, _]]) | eq a b c -> Win user board

           (Board [[a, b, c],
				   [_, _, _],
				   [_, _, _]]) | eq a b c -> Win user board

           (Board [[_, _, _],
				   [a, b, c],
				   [_, _, _]]) | eq a b c -> Win user board

           (Board [[_, _, _],
				   [_, _, _],
				   [a, b, c]]) | eq a b c -> Win user board

           (Board [[a, _, _],
				   [b, _, _],
				   [c, _, _]]) | eq a b c -> Win user board

           (Board [[_, a, _],
				   [_, b, _],
				   [_, c, _]]) | eq a b c -> Win user board

           (Board [[_, _, a],
				   [_, _, b],
				   [_, _, c]]) | eq a b c -> Win user board

           _ | full board -> Draw board
             | otherwise  -> Continue (otherUser user) board
	where
		eq a b c = a == b && b == c
			 

move :: User -> Int -> Board -> Result
move user pos board = result user pos board (place user pos board)
    where
        place user pos (Board lines) = Board (map (placeInLine user pos) lines)

        placeInLine user pos         = map (matchSquare user pos)

        result user pos orig board 
            | orig == board          = Error user orig
            | otherwise              = outcome user board

main :: IO ()
main = loop (Continue X startingBoard)
    where 
        loop result = do 
            print result
            case result of
                 Win user board      -> exitSuccess
                 Draw board          -> exitSuccess
                 Continue user board -> getInput user board
                 Error user board    -> getInput user board
        getInput user board = do
             pos <- readLn::IO Int 
             loop (move user pos board)

