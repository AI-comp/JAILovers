package net.aicomp

import java.io.File
import java.io.PrintWriter

class Logger {
	public static val LOG_LEVEL_RESULT = 0
	public static val LOG_LEVEL_STATUS = 1
	public static val LOG_LEVEL_DETAILS = 2

	private static var Logger _instance
	private var PrintWriter _writer
	private var int _logLevel
	private var boolean _silent

	private new() {
	}

	public static def getInstance() {
		if (_instance == null) {
			_instance = new Logger
		}
		return _instance
	}

	def initialize(int logLevel, boolean silent) {
		_logLevel = logLevel
		_silent = silent

		if (!_silent) {
			val file = new File("./log.txt")
			if (!file.exists()) {
				file.createNewFile()
			}
			_writer = new PrintWriter(file.getAbsoluteFile())
		}
	}

	override finalize() {
		if (_writer != null) {
			_writer.close()
		}
	}

	def outputLog(String message, int targetLogLevel) {
		if (_logLevel >= targetLogLevel) {
			System.out.println(message.trim)
			if (!_silent) {
				_writer.println(message.trim)
			}
		}
	}
}
