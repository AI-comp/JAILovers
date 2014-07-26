package net.aicomp

import java.util.List
import java.util.ArrayList
import com.google.common.base.Function
import com.google.common.collect.Lists

import static extension net.aicomp.Utility.*

class Heroine {
	int _enthusiasm
	int _numPlayers
	List<Integer> _revealedLove
	List<Integer> _realLove
	boolean _dated

	new(int enthusiasm, int numPlayers) {
		_enthusiasm = enthusiasm
		_numPlayers = numPlayers
		_revealedLove = Lists.newArrayList()
		_realLove = Lists.newArrayList()
		(1 .. numPlayers).forEach [ _ |
			_revealedLove.add(0)
			_realLove.add(0)
		]
		_dated = false
	}

	def void date(int playerIndex, boolean isWeekday) {
		if (isWeekday) {
			_realLove.increment(playerIndex, 1)
			_revealedLove.increment(playerIndex, 1)
		} else {
			_realLove.increment(playerIndex, 2)
		}
		_dated = true
	}

	def filterPlayersByLove(List<Player> players, Function<List<Integer>, Integer> func, boolean real) {
		val allLove = if(real) _realLove else _revealedLove
		val targetLove = func.apply(allLove)
		val targetPlayers = new ArrayList<Player>()
		for (player : players) {
			if (allLove.get(player.index) == targetLove) {
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

	def getEnthusiasm() {
		return _enthusiasm
	}
}
