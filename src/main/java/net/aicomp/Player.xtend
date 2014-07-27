package net.aicomp

class Player implements Comparable<Player> {
	val int _index
	val int _multiplier

	var int _integerPopularity

	new(int index, int numPlayers) {
		_index = index
		_integerPopularity = 0
		_multiplier = factorial(numPlayers)
	}

	def getIndex() {
		_index
	}

	override compareTo(Player other) {
		if(_integerPopularity > other.integerPopularity) -1 else 1
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

	def decreaseIntegerPopularity(int decrement) {
		_integerPopularity -= decrement
	}

	def getIntegerPopularity() {
		_integerPopularity
	}
}
