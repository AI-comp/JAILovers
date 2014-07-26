package net.aicomp

import com.google.common.collect.Lists
import java.util.ArrayList
import java.util.Collections
import java.util.List
import java.util.Random

import static extension net.aicomp.Utility.*

class Game {
	List<Heroine> _heroines
	int _initialTurn
	int _lastTurn
	int _turn
	Random _random
	Replay _replay

	int _numPlayers

	new() {
		_heroines = Lists.newArrayList()
		_initialTurn = 1
		_lastTurn = 10
		_turn = _initialTurn
		_random = new Random()
		_replay = new Replay()
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
		(1 .. numHeroines).forEach [
			val enthusiasm = (Math.floor(_random.nextInt * 4) + 3 ) as int
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

	def processTurn(List<List<String>> commands) {
		_heroines.forEach[it.refresh()]

		_replay.allCommands.add((1 .. _numPlayers).map[#[]].toList)
		(1 .. _numPlayers).forEach [ playerIndex |
			(1 .. numRequiredCommands).forEach [
				var parsedCommand = try {
					Integer.parseInt(commands.get(playerIndex, it))
				} catch (Exception e) {
					0
				}
				val targetHeroineIndex = Math.max(Math.min(parsedCommand, _heroines.length), 0)
				_heroines.get(targetHeroineIndex).date(playerIndex, isWeekday)
				_replay.allCommands.get(_turn - 1, playerIndex).add(targetHeroineIndex)
			]
		]
		_turn += 1
	}

	def getTerminationText(int playerIndex) {
		''
	}

	def getRanking() {
		val playersWithWinningPopularity = getPlayersWithTotalPopularity(true, true);
		val playersWithLosingPopularity = getPlayersWithTotalPopularity(false, true);

		(0 .. getNumPlayers() - 1).forEach [ playerIndex |
			playersWithWinningPopularity.get(playerIndex).decreaseIntegerPopularity(
				playersWithLosingPopularity.get(playerIndex).integerPopularity)
		]

		Collections.sort(playersWithWinningPopularity)
		return playersWithWinningPopularity
	}

	def getPlayersWithTotalPopularity(boolean winning, boolean real) {
		val players = (0 .. getNumPlayers() - 1).map [ playerIndex |
			new Player(playerIndex, getNumPlayers())
		].toList()
		_heroines.forEach [ heroine |
			val func = if (winning)
					[List<Integer> array|Collections.max(array)]
				else
					[List<Integer> array|Collections.min(array)]
			val targetPlayers = heroine.filterPlayersByLove(players, func, real);
			targetPlayers.forEach [ targetPlayer |
				targetPlayer.addPopularity(heroine.enthusiasm, targetPlayers.size())
			]
		]
		players
	}

	def getWinner() {
		val ranking = getRanking()
		if (ranking.get(0).getPopularity() == ranking.get(1).getPopularity()) {
			''
		} else {
			ranking.get(0).index
		}
	}

	def getReplay() {
		_replay
	}
}

class Replay {
	private List<List<List<Integer>>> _allCommands

	def getAllCommands() {
		_allCommands
	}
}

class Utility {
	static def increment(List<Integer> integers, int i, int j) {
		integers.set(i, integers.get(i) + j)
	}

	static def <T> get(List<List<T>> arrays, int firstIndex, int secondIndex) {
		arrays.get(firstIndex).get(secondIndex)
	}
}
