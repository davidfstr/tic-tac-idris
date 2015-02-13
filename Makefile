compile:
	idris -o TicTacToe TicTacToe.idr

run: compile
	./TicTacToe
