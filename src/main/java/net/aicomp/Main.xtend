package net.aicomp

import java.util.List
import net.exkazuu.gameaiarena.manipulator.Manipulator
import net.exkazuu.gameaiarena.player.ExternalComputerPlayer
import org.apache.commons.cli.BasicParser
import org.apache.commons.cli.CommandLine
import org.apache.commons.cli.HelpFormatter
import org.apache.commons.cli.OptionBuilder
import org.apache.commons.cli.Options
import org.apache.commons.cli.ParseException
import java.util.ArrayList

class Main {
	static val HELP = "h"
	static val RESULT_MODE = "r"
	static val SILENT = "s"
	static val EXTERNAL_AI_PROGRAM = "a"
	static val WORK_DIR_AI_PROGRAM = "w"
	static val NOT_SHOWING_LOG = "n"
	static val DEFAULT_COMMAND = "python SampleAI.py"

	static def buildOptions() {
		OptionBuilder.hasArgs()
		OptionBuilder.withDescription("Set 1-4 AI players with external programs.")
		val externalAIOption = OptionBuilder.create(EXTERNAL_AI_PROGRAM)

		OptionBuilder.hasArgs()
		OptionBuilder.withDescription("Set working directories for external programs.")
		val workDirOption = OptionBuilder.create(WORK_DIR_AI_PROGRAM)

		val options = new Options().addOption(HELP, false, "Print this help.").addOption(RESULT_MODE, false,
			"Enable result mode which show only a screen of a result.").addOption(NOT_SHOWING_LOG, false,
			"Disable showing logs in the screen.").addOption(SILENT, false,
			"Disable writing log files in the log directory.").addOption(externalAIOption).addOption(workDirOption)
		options
	}

	static def printHelp(Options options) {
		val help = new HelpFormatter()
		help.printHelp("java -jar JAILovers.jar [OPTIONS]\n" + "[OPTIONS]: ", "", options, "", true)
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
		val workingDirsItr = (workingDirs + (0 .. 3).map[null]).toList().iterator()
		val cmds = (externalCmds + (0 .. 3).drop(externalCmds.length).map[Main.DEFAULT_COMMAND])
		val ais = new ArrayList<AIManipulator>()
		cmds.forEach [ cmd, i |
			ais.add(new AIManipulator(i, cmd.split(" "), workingDirsItr.next))
		]
		playGame(ais)
	}

	static def playGame(List<AIManipulator> ais) {
		val game = new Game()
		game.initialize()

		ais.forEach [ ai |
			ai.getReady()
		]

		while (!game.isFinished()) {
			System.out.println("Starting a new turn")
			val commands = new ArrayList<List<String>>()
			ais.forEach [ ai, index |
				commands.add(ai.run(game).toList)
			]
			game.processTurn(commands)
			System.out.println("Turn finished. Game status:")
			System.out.println(game.status)
			System.out.println()
		}

		System.out.println("Winner: " + game.winner)
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
}

class AIManipulator extends GameManipulator {
	private ExternalComputerPlayer _com
	private String[] _commands
	private int _index

	new(int index, String[] commandWithArguments) {
		_index = index
		_com = new ExternalComputerPlayer(commandWithArguments)
	}

	new(int index, String[] commandWithArguments, String workingDir) {
		_index = index
		_com = new ExternalComputerPlayer(commandWithArguments, workingDir)
	}

	override protected runPreProcessing(Game game) {
		System.out.println("AI" + _index + ">>Writing to stdin, waiting for stdout")
		var input = ""
		if (game.isInitialState()) {
			input += game.getInitialInformation()
		}
		input += game.getTurnInformation(_index)

		System.out.print(input)
		_com.writeLine(input)
	}

	override protected runProcessing() {
		val line = _com.readLine
		System.out.println("AI" + _index + ">>STDOUT:" + line)
		_commands = line.trim().split(" ")
	}

	override protected runPostProcessing() {
		_commands
	}

	def getReady() {
		var line = ""
		do {
			line = _com.readLine
			System.out.println("AI" + _index + ">>STDOUT:" + line)
		} while (line.toLowerCase != "ready")
	}
}
