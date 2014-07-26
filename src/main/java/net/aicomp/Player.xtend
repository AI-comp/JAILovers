package net.aicomp

class Player {
	private int _index
	private int _integerPopularity
	private int _multiplier

	new(int index, int numPlayers) {
		_index = index
		_integerPopularity = 0
		_multiplier = factorial(numPlayers)
	}

	def compareTo(Player other) {
		if(_integerPopularity > other._integerPopularity) 1 else -1
	}

	def addPopularity(int numerator, int denominator) {
		_integerPopularity += numerator * _multiplier / denominator
	}

	def getPopularity() {
		_integerPopularity as double / _multiplier
	}

	def int factorial(int n) {
		if(n <= 0) 1 else n * factorial(n - 1)
	}
}
