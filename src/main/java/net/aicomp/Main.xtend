package net.aicomp

import com.google.common.base.Strings
import com.google.common.collect.Lists
import java.io.IOException
import java.util.List
import net.exkazuu.gameaiarena.manipulator.Manipulator
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
			addOption(SILENT, false, "Disable writing a log file.").addOption(externalAIOption).addOption(workDirOption)
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
				start(new Game(), cl)
			}
		} catch (ParseException e) {
			System.err.println("Error: " + e.getMessage())
			printHelp(options)
			System.exit(-1)
		}
	}

	static def start(Game game, CommandLine cl) {
		val externalCmds = getOptionsValuesWithoutNull(cl, EXTERNAL_AI_PROGRAM)
		var workingDirs = getOptionsValuesWithoutNull(cl, WORK_DIR_AI_PROGRAM)
		if (workingDirs.isEmpty) {
			workingDirs = externalCmds.map[null]
		}
		if (externalCmds.length != workingDirs.length) {
			throw new ParseException("The numbers of arguments of -a and -w must be equal.")
		}

		val indices = (0 .. 3)
		val cmds = (externalCmds + indices.drop(externalCmds.length).map[Main.DEFAULT_COMMAND])
		val workingDirsItr = (workingDirs + indices.map[Main.DEFAULT_WORK_DIR]).iterator
		val ais = Lists.newArrayList
		cmds.forEach [ cmd, index |
			try {
				val com = new ExternalComputerPlayerWithErrorLog(cmd.split(" "), workingDirsItr.next)
				ais.add(
					new AIInitializer(com, index).limittingSumTime(1, 5000) ->
						new AIManipulator(com, index).limittingSumTime(1, 1000)
				)
			} catch (IOException e) {
				System.exit(-1)
			}
		]

		var tmpLogLevel = 2
		if (cl.hasOption(LOG_LEVEL)) {
			try {
				tmpLogLevel = Integer.parseInt(cl.getOptionValue(LOG_LEVEL, "2"))
			} catch (Exception e) {
			}
		}
		val logLevel = tmpLogLevel
		val silent = cl.hasOption(SILENT)
		Logger.instance.initialize(logLevel, silent)

		playGame(game, ais)

		Logger.instance.finalize()

		game
	}

	static def playGame(Game game, List<Pair<Manipulator<Game, String[]>, Manipulator<Game, String[]>>> ais) {
		game.initialize()

		ais.forEach[it.key.run(game)]

		while (!game.isFinished()) {
			if (game.isInitialState()) {
				Logger.instance.outputLog("", Logger.LOG_LEVEL_DETAILS)
			} else {
				Logger.instance.outputLog("", Logger.LOG_LEVEL_STATUS)
			}
			Logger.instance.outputLog("Turn " + game.turn, Logger.LOG_LEVEL_STATUS)

			val commands = Lists.newArrayList
			ais.forEach [
				commands.add(it.value.run(game).toList)
			]
			game.processTurn(commands)

			Logger.instance.outputLog("Turn finished. Game status:", Logger.LOG_LEVEL_DETAILS)
			Logger.instance.outputLog(game.status, Logger.LOG_LEVEL_STATUS)
		}

		Logger.instance.outputLog("", Logger.LOG_LEVEL_STATUS)
		Logger.instance.outputLog("Game Finished", Logger.LOG_LEVEL_STATUS)
		Logger.instance.outputLog("Winner: " + game.winner, Logger.LOG_LEVEL_RESULT)

		game
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

	new(int index) {
		_index = index
	}
}

class AIInitializer extends GameManipulator {
	val ExternalComputerPlayerWithErrorLog _com
	var List<String> _lines

	new(ExternalComputerPlayerWithErrorLog com, int index) {
		super(index)
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
		if (!_com.errorLog.isEmpty) {
			Logger.instance.outputLog("AI" + _index + ">>STDERR: " + _com.errorLog, Logger.LOG_LEVEL_DETAILS)
		}
		_lines.forEach [
			Logger.instance.outputLog("AI" + _index + ">>STDOUT: " + it, Logger.LOG_LEVEL_DETAILS)
		]
		_lines
	}
}

class AIManipulator extends GameManipulator {
	val ExternalComputerPlayerWithErrorLog _com
	var String _line

	new(ExternalComputerPlayerWithErrorLog com, int index) {
		super(index)
		_com = com
	}

	override protected runPreProcessing(Game game) {
		Logger.instance.outputLog("AI" + _index + ">>Writing to stdin, waiting for stdout", Logger.LOG_LEVEL_DETAILS)
		var input = ""
		if (game.isInitialState()) {
			input += game.getInitialInformation()
		}
		input += game.getTurnInformation(_index)

		Logger.instance.outputLog(input, Logger.LOG_LEVEL_DETAILS)
		_com.writeLine(input)
		_line = ""
	}

	override protected runProcessing() {
		_line = _com.readLine
	}

	override protected runPostProcessing() {
		if (!_com.errorLog.isEmpty) {
			Logger.instance.outputLog("AI" + _index + ">>STDERR: " + _com.errorLog, Logger.LOG_LEVEL_DETAILS)
		}
		Logger.instance.outputLog("AI" + _index + ">>STDOUT: " + _line, Logger.LOG_LEVEL_DETAILS)
		if (!Strings.isNullOrEmpty(_line)) {
			_line.trim().split(" ")
		} else {
			#[]
		}
	}
}
