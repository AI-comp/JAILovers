package net.aicomp

import java.util.List

class Utility {
	public static val LOG_LEVEL_RESULT = 0
	public static val LOG_LEVEL_STATUS = 1
	public static val LOG_LEVEL_DETAILS = 2

	static def increment(List<Integer> integers, int i, int j) {
		integers.set(i, integers.get(i) + j)
	}

	static def <T> get(List<List<T>> arrays, int firstIndex, int secondIndex) {
		arrays.get(firstIndex).get(secondIndex)
	}

	static def outputLog(String message, int targetLogLevel, int logLevel) {
		if (logLevel >= targetLogLevel) {
			System.out.println(message.trim)
		}
	}
}
