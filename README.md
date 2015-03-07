# tic-tac-idris

This is a tic-tac-toe game written in Idris.

I wrote it as an exercise for learning basic functionality in Idris.

This program does not make much use of language facilities unique to
dependently-typed programming languages or Idris such as proof terms.
As such this tic-tac-toe implementation could be translated quite
straightforwardly to another functional programming language such
as Haskell.

For a program that makes heavier use of facilities unique to dependently-typed
languages, see my [proven-correct implementation of insertion sort].

[proven-correct implementation of insertion sort]: https://github.com/davidfstr/idris-insertion-sort

## Prerequisites

* Idris 0.9.16
* Make

## How to Run

```
make run
```

## Example Game

```
$ make run
idris -o TicTacToe TicTacToe.idr
./TicTacToe
   |   |   
---|---|---
   |   |   
---|---|---
   |   |   

Next move? (0-8) 4

   |   |   
---|---|---
   | X |   
---|---|---
   |   |   

Next move? (0-8) 0

 O |   |   
---|---|---
   | X |   
---|---|---
   |   |   

Next move? (0-8) 2

 O |   | X 
---|---|---
   | X |   
---|---|---
   |   |   

Next move? (0-8) 1

 O | O | X 
---|---|---
   | X |   
---|---|---
   |   |   

Next move? (0-8) 6

 O | O | X 
---|---|---
   | X |   
---|---|---
 X |   |   

X wins!
```

## License

MIT.
