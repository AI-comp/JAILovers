package net.aicomp

import java.util.ArrayList
import java.util.Random

import static extension net.aicomp.Utility.*
import com.google.common.base.Function

class Game {
	private ArrayList<Heroine> _heroines
	int _initialTurn
	int _lastTurn
	int _turn
	Random _random
	Replay _replay

	int _numPlayers

	new(int seed) {
		_heroines = new ArrayList<Heroine>()
		_initialTurn = 1
		_lastTurn = 10
		_turn = _initialTurn
		_random = new Random()
		_replay = new Replay(seed)
	}

	def initialize() {
		initialize(4)
	}

	def initialize(int numPlayers) {
		initialize(numPlayers, numPlayers * 2)
	}

	def initialize(int numPlayers, int numHeroines) {
		_numPlayers = numPlayers
		populateHeroines(numHeroines)
	}

	def populateHeroines(int numHeroines) {
		_heroines = new ArrayList<Heroine>()
		(0 .. numHeroines).forEach [ i |
			val enthusiasm = Math.floor(_random.nextInt * 4) + 3 as int
			_heroines.add(new Heroine(enthusiasm, _numPlayers))
		]
	}

	def isWeekday() {
		_turn % 2 == 1
	}

	def getNumRequiredCommands() {
		if(isWeekday()) 5 else 2
	}

	def getNumHeroines() {
		_heroines.size()
	}

	def getNumPlayers() {
		_numPlayers
	}

	def getNumTurns() {
		_lastTurn - _initialTurn
	}

	def processTurn(Commands commands) {
		_heroines.forEach [ heroine |
			heroine.refresh()
		]
		
	}
}

class Replay {
	int _seed
	Commands _commands

	new(int seed) {
		_seed = seed
	}
}

class Commands {
	ArrayList<ArrayList<Integer>> _commands

	new() {
		_commands = new ArrayList<ArrayList<Integer>>()
	}

	def get(int turn, int index) {
		_commands.get(turn).get(index)
	}
}

class Player {
}

class Heroine {
	double _enthusiasm
	int _numPlayers
	ArrayList<Integer> _revealedLove
	ArrayList<Integer> _realLove
	boolean _dated

	new(double enthusiasm, int numPlayers) {
		_enthusiasm = enthusiasm
		_numPlayers = numPlayers
		_revealedLove = new ArrayList<Integer>()
		_realLove = new ArrayList<Integer>()
		(0 .. numPlayers).forEach [ i |
			_revealedLove.add(0)
			_realLove.add(0)
		]
		_dated = false
	}

	def date(int playerIndex, boolean isWeekday) {
		if (isWeekday) {
			_realLove.increment(playerIndex, 1)
			_revealedLove.increment(playerIndex, 1)
		} else {
			_realLove.increment(playerIndex, 2)
		}
		_dated = true
	}

	def filterPlayersByLove(ArrayList<Player> players, Function<ArrayList<Integer>, Integer> func, boolean real) {
		val allLove = if(real) _realLove else _revealedLove
		val targetLove = func.apply(allLove)
		val targetPlayers = new ArrayList<Player>()
		for (player : players) {
			if (allLove.get(player.getIndex()) == targetLove) {
				targetPlayers.add(player)
			}
		}
		targetPlayers
	}

	def refresh() {
		_dated = false
	}

	def getDatedBit() {
		if(_dated) 1 else 0
	}
}

class Utility {
	static def increment(ArrayList<Integer> integers, int i, int j) {
		integers.set(i, integers.get(i) + j)
	}

	static def max(ArrayList<Integer> array) {
		var ret = Integer.MAX_VALUE
		for (value : array) {
			ret = Math.max(ret, value)
		}
		ret
	}

	static def min(ArrayList<Integer> array) {
		var ret = Integer.MAX_VALUE
		for (value : array) {
			ret = Math.min(ret, value)
		}
		ret
	}
}
