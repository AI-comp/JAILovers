package net.aicomp

import com.google.common.base.Strings
import com.google.common.collect.Lists
import java.util.List
import net.exkazuu.gameaiarena.manipulator.Manipulator
import net.exkazuu.gameaiarena.player.ExternalComputerPlayer
import org.apache.commons.cli.BasicParser
import org.apache.commons.cli.CommandLine
import org.apache.commons.cli.HelpFormatter
import org.apache.commons.cli.OptionBuilder
import org.apache.commons.cli.Options
import org.apache.commons.cli.ParseException

class Main {
	static val HELP = "h"
	static val LOG_LEVEL = "l"
	static val SILENT = "s"
	static val EXTERNAL_AI_PROGRAM = "a"
	static val WORK_DIR_AI_PROGRAM = "w"
	static val DEFAULT_COMMAND = "java SampleAI"
	static val DEFAULT_WORK_DIR = "./defaultai"

	static def buildOptions() {
		OptionBuilder.hasArgs()
		OptionBuilder.withDescription("Set 1-4 AI players with external programs.")
		val externalAIOption = OptionBuilder.create(EXTERNAL_AI_PROGRAM)

		OptionBuilder.hasArgs()
		OptionBuilder.withDescription("Set working directories for external programs.")
		val workDirOption = OptionBuilder.create(WORK_DIR_AI_PROGRAM)

		val options = new Options().addOption(HELP, false, "Print this help.").addOption(LOG_LEVEL, true,
			"Specify the log level. 0: Show only result 1: Show game status 2: Show detailed log (defaults to 2)").
			addOption(SILENT, false, "Disable writing log files.").addOption(externalAIOption).addOption(workDirOption)
		options
	}

	static def printHelp(Options options) {
		val help = new HelpFormatter()
		help.printHelp("java -jar AILovers.jar [OPTIONS]\n" + "[OPTIONS]: ", "", options, "", true)
	}

	static def void main(String[] args) {
		val options = buildOptions()
		try {
			val parser = new BasicParser()
			val cl = parser.parse(options, args)
			if (cl.hasOption(HELP)) {
				printHelp(options)
			} else {
				start(cl)
			}
		} catch (ParseException e) {
			System.err.println("Error: " + e.getMessage())
			printHelp(options)
			System.exit(-1)
		}
	}

	static def start(CommandLine cl) {
		val externalCmds = getOptionsValuesWithoutNull(cl, EXTERNAL_AI_PROGRAM)
		var workingDirs = getOptionsValuesWithoutNull(cl, WORK_DIR_AI_PROGRAM)
		if (workingDirs.isEmpty) {
			workingDirs = externalCmds.map[null]
		}
		if (externalCmds.length != workingDirs.length) {
			throw new ParseException("The numbers of arguments of -a and -w should be equal.")
		}

		var tmpLogLevel = 2
		if (cl.hasOption(LOG_LEVEL)) {
			try {
				tmpLogLevel = Integer.parseInt(cl.getOptionValue(LOG_LEVEL, "2"))
			} catch (Exception e) {
			}
		}
		val logLevel = tmpLogLevel
		val silent = cl.hasOption(SILENT)

		val indices = (0 .. 3)
		val cmds = (externalCmds + indices.drop(externalCmds.length).map[Main.DEFAULT_COMMAND])
		val workingDirsItr = (workingDirs + indices.map[Main.DEFAULT_WORK_DIR]).iterator
		val indicesItr = indices.iterator
		val ais = cmds.map [
			val com = new ExternalComputerPlayer(it.split(" "), workingDirsItr.next)
			val index = indicesItr.next
			new AIInitializer(com, index, logLevel, silent).limittingSumTime(1, 5000) ->
				new AIManipulator(com, index, logLevel, silent).limittingSumTime(1, 1000)
		].toList

		playGame(ais, logLevel, silent)
	}

	static def playGame(List<Pair<Manipulator<Game, String[]>, Manipulator<Game, String[]>>> ais, int logLevel,
		boolean silent) {
		val game = new Game()
		game.initialize()

		ais.forEach[it.key.run(game)]

		while (!game.isFinished()) {
			if (game.isInitialState()) {
				Utility.outputLog("", Utility.LOG_LEVEL_DETAILS, logLevel)
			} else {
				Utility.outputLog("", Utility.LOG_LEVEL_STATUS, logLevel)
			}
			Utility.outputLog("Turn " + game.turn, Utility.LOG_LEVEL_STATUS, logLevel)

			val commands = Lists.newArrayList
			ais.forEach [
				commands.add(it.value.run(game).toList)
			]
			game.processTurn(commands)

			Utility.outputLog("Turn finished. Game status:", Utility.LOG_LEVEL_DETAILS, logLevel)
			Utility.outputLog(game.status, Utility.LOG_LEVEL_STATUS, logLevel)
		}

		Utility.outputLog("", Utility.LOG_LEVEL_STATUS, logLevel)
		Utility.outputLog("Game Finished", Utility.LOG_LEVEL_STATUS, logLevel)
		Utility.outputLog("Winner: " + game.winner, Utility.LOG_LEVEL_RESULT, logLevel)
	}

	static def String[] getOptionsValuesWithoutNull(CommandLine cl, String option) {
		if (cl.hasOption(option))
			cl.getOptionValues(option)
		else
			#[]
	}
}

// Generics parameters <Argument, String[]> indicate runPreProcessing receives Argument object
// and runProcessing and runPostProcessing returns String[] object
abstract class GameManipulator extends Manipulator<Game, String[]> {
	protected val int _index
	protected val int _logLevel
	protected val boolean _silent

	new(int index, int logLevel, boolean silent) {
		_index = index
		_logLevel = logLevel
		_silent = silent
	}
}

class AIInitializer extends GameManipulator {
	val ExternalComputerPlayer _com
	var List<String> _lines

	new(ExternalComputerPlayer com, int index, int logLevel, boolean silent) {
		super(index, logLevel, silent)
		_com = com
	}

	override protected runPreProcessing(Game game) {
		_lines = Lists.newArrayList
	}

	override protected runProcessing() {
		var line = ""
		do {
			line = _com.readLine
			if (line != null) {
				line = line.trim
				_lines.add(line)
			}
		} while (line != null && line.toLowerCase != "ready")
	}

	override protected runPostProcessing() {
		_lines.forEach [
			Utility.outputLog("AI" + _index + ">>STDOUT: " + it, Utility.LOG_LEVEL_DETAILS, _logLevel)
		]
		_lines
	}
}

class AIManipulator extends GameManipulator {
	val ExternalComputerPlayer _com
	var String _line

	new(ExternalComputerPlayer com, int index, int logLevel, boolean silent) {
		super(index, logLevel, silent)
		_com = com
	}

	override protected runPreProcessing(Game game) {
		Utility.outputLog("AI" + _index + ">>Writing to stdin, waiting for stdout", Utility.LOG_LEVEL_DETAILS, _logLevel)
		var input = ""
		if (game.isInitialState()) {
			input += game.getInitialInformation()
		}
		input += game.getTurnInformation(_index)

		Utility.outputLog(input, Utility.LOG_LEVEL_DETAILS, _logLevel)
		_com.writeLine(input)
		_line = ""
	}

	override protected runProcessing() {
		_line = _com.readLine
	}

	override protected runPostProcessing() {
		Utility.outputLog("AI" + _index + ">>STDOUT:" + _line, Utility.LOG_LEVEL_DETAILS, _logLevel)
		if (!Strings.isNullOrEmpty(_line)) {
			_line.trim().split(" ")
		} else {
			#[]
		}
	}
}
