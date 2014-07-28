package net.aicomp

import com.google.common.collect.Lists
import java.util.Collections
import java.util.List
import java.util.Random
import net.aicomp.util.MersenneTwister

import static extension net.aicomp.Utility.*

class Game {
	val int _initialTurn
	val int _lastTurn
	val MersenneTwister _mt
	val Replay _replay

	var List<Heroine> _heroines
	var int _turn
	var int _numPlayers

	new() {
		_heroines = Lists.newArrayList()
		_initialTurn = 1
		_lastTurn = 10
		_turn = _initialTurn
		_mt = new MersenneTwister(new Random().nextInt)
		_replay = new Replay()
	}

	new(int seed) {
		_heroines = Lists.newArrayList()
		_initialTurn = 1
		_lastTurn = 10
		_turn = _initialTurn
		_mt = new MersenneTwister(seed)
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
		_heroines = (1 .. numHeroines).map [
			val enthusiasm = (_mt.random() * 4) as int + 3
			new Heroine(enthusiasm, _numPlayers)
		].toList
	}

	def isWeekday() {
		_turn % 2 == 1
	}

	def getNumRequiredCommands() {
		if(isWeekday) 5 else 2
	}

	def getNumHeroines() {
		_heroines.size
	}

	def getNumPlayers() {
		_numPlayers
	}

	def getNumTurns() {
		_lastTurn - _initialTurn
	}

	def processTurn(List<List<String>> commands) {
		_heroines.forEach[it.refresh()]

		_replay.allCommands.add(
			(0 ..< _numPlayers).map [
				Lists.newArrayList().toList
			].toList)

		(0 ..< _numPlayers).forEach [ playerIndex |
			(0 ..< numRequiredCommands).forEach [
				var targetHeroineIndex = try {
					Integer.parseInt(commands.get(playerIndex, it))
				} catch (Exception e) {
					0
				}
				if (!(targetHeroineIndex >= 0 && targetHeroineIndex < _heroines.size)) {
					targetHeroineIndex = 0
				}
				_heroines.get(targetHeroineIndex).date(playerIndex, isWeekday)
				_replay.allCommands.get(_turn - 1, playerIndex).add(targetHeroineIndex)
			]
		]
		_turn += 1
	}

	def isInitialState() {
		_turn == _initialTurn
	}

	def isFinished() {
		_turn > _lastTurn
	}

	def getInitialInformation() {
		#[
			#[_lastTurn - _initialTurn + 1, _numPlayers, _heroines.length].join(' '),
			_heroines.map[it.enthusiasm].join(' ')
		].join('\n') + '\n'
	}

	def getTurnInformation(int playerIndex) {
		val lines = Lists.newArrayList(
			#[_turn, if(isWeekday) 'W' else 'H'].join(' ')
		)

		lines.addAll(
			_heroines.map [ heroine |
				val enemyIndices = (0 ..< _numPlayers).filter [
					it != playerIndex
				].toList
				val enemyLove = enemyIndices.map [
					heroine.revealedLove.get(it)
				]
				(#[heroine.revealedLove.get(playerIndex)] + enemyLove).join(' ')
			])

		lines.add(_heroines.map[it.realLove.get(playerIndex)].join(' '))

		if (isWeekday) {
			lines.add(_heroines.map[it.getDatedBit()].join(' '))
		}

		lines.join('\n') + '\n'
	}

	def getStatus() {
		val lines = Lists.newArrayList(
			'Enthusiasm:',
			_heroines.map[it.enthusiasm].join(' '),
			'Real Love:'
		)
		lines.addAll(_heroines.map[it.realLove.join(' ')])

		if (isWeekday) {
			lines.add('Dated:')
			lines.add(_heroines.map[it.getDatedBit()].join(' '))
		}

		lines.add('Ranking:')
		lines.addAll(
			ranking.map [
				'Player ' + it.index + ': ' + it.getPopularity() + ' popularity'
			])

		return lines.join('\n') + '\n'
	}

	def getTerminationText(int playerIndex) {
		''
	}

	def getRanking() {
		val playersWithWinningPopularity = getPlayersWithTotalPopularity(true, true)
		val playersWithLosingPopularity = getPlayersWithTotalPopularity(false, true)

		(0 .. getNumPlayers() - 1).forEach [
			playersWithWinningPopularity.get(it).decreaseIntegerPopularity(
				playersWithLosingPopularity.get(it).integerPopularity)
		]

		Collections.sort(playersWithWinningPopularity)
		return playersWithWinningPopularity
	}

	def getPlayersWithTotalPopularity(boolean winning, boolean real) {
		val players = (0 .. numPlayers - 1).map [
			new Player(it, numPlayers)
		].toList()
		_heroines.forEach [ heroine |
			val func = if (winning)
					[List<Integer> array|Collections.max(array)]
				else
					[List<Integer> array|Collections.min(array)]
			val targetPlayers = heroine.filterPlayersByLove(players, func, real);
			targetPlayers.forEach [
				it.addPopularity(heroine.enthusiasm, targetPlayers.size)
			]
		]
		players
	}

	def getWinner() {
		val ranking = ranking
		if (ranking.get(0).popularity == ranking.get(1).popularity) {
			''
		} else {
			ranking.get(0).index.toString
		}
	}

	def getReplay() {
		_replay
	}

	def getTurn() {
		return _turn
	}
}

class Replay {
	val List<List<List<Integer>>> _allCommands

	new() {
		_allCommands = Lists.newArrayList()
	}

	def getAllCommands() {
		_allCommands
	}
}
