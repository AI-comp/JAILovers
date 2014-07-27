package net.aicomp

import java.util.List

class Utility {
	static def increment(List<Integer> integers, int i, int j) {
		integers.set(i, integers.get(i) + j)
	}

	static def <T> get(List<List<T>> arrays, int firstIndex, int secondIndex) {
		arrays.get(firstIndex).get(secondIndex)
	}
}
