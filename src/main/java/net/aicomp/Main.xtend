package net.aicomp

import net.exkazuu.gameaiarena.manipulator.Manipulator
import net.exkazuu.gameaiarena.player.ExternalComputerPlayer
import org.apache.commons.cli.BasicParser
import org.apache.commons.cli.HelpFormatter
import org.apache.commons.cli.OptionBuilder
import org.apache.commons.cli.Options
import org.apache.commons.cli.ParseException

class Main {
	val HELP = "h"
	val FPS = "f"
	val CUI_MODE = "c"
	val RESULT_MODE = "r"
	val REPLAY_MODE = "p"
	val SILENT = "s"
	val USER_PLAYERS = "u"
	val LIGHT_GUI_MODE = "l"
	val EXTERNAL_AI_PROGRAM = "a"
	val WORK_DIR_AI_PROGRAM = "w"
	val INTERNAL_AI_PROGRAM = "i"
	val NOT_SHOWING_LOG = "n"

	def buildOptions() {
		OptionBuilder.hasArg()
		OptionBuilder.withDescription(
			"Set 0-3 user players. When specifying no player option (-u, -a, -i), a game is provided for 1 user player and 2 default internal AI players")
		val userOption = OptionBuilder.create(USER_PLAYERS)

		OptionBuilder.hasArgs()
		OptionBuilder.withDescription("Set 1-3 AI players with external programs.")
		val externalAIOption = OptionBuilder.create(EXTERNAL_AI_PROGRAM)

		OptionBuilder.hasArgs()
		OptionBuilder.withDescription("Set working directories for external programs.")
		val workDirOption = OptionBuilder.create(WORK_DIR_AI_PROGRAM)

		OptionBuilder.hasArgs()
		OptionBuilder.withDescription("Set 1-3 AI players with internal classes for debugging puropose.")
		val internalAIOption = OptionBuilder.create(INTERNAL_AI_PROGRAM)

		OptionBuilder.withDescription(
			"FPS to adjust game speed. Default value is 30 for user mode or 1000 for ai mode.")
		OptionBuilder.hasArg()
		OptionBuilder.withArgName("fps")
		val fpsOption = OptionBuilder.create(FPS)

		val options = new Options().addOption(HELP, false, "Print this help.").addOption(FPS, false, "Enable CUI mode.").
			addOption(CUI_MODE, false, "Enable CUI mode.").addOption(RESULT_MODE, false,
				"Enable result mode which show only a screen of a result.").addOption(REPLAY_MODE, true,
				"Replay the specified .rep file.").addOption(LIGHT_GUI_MODE, false,
				"Enable light and fast GUI mode by reducing rendering frequency.").addOption(NOT_SHOWING_LOG, false,
				"Disable showing logs in the screen.").addOption(SILENT, false,
				"Disable writing log files in the log directory.").addOption(userOption).addOption(externalAIOption).
			addOption(workDirOption).addOption(internalAIOption).addOption(fpsOption)
		options
	}

	def printHelp(Options options) {
		val help = new HelpFormatter()
		help.printHelp("java -jar Terraforming.jar [OPTIONS]\n" + "[OPTIONS]: ", "", options, "", true)
	}

	def void main(String[] args) {
		val options = buildOptions()
		try {
			val parser = new BasicParser()
			val cl = parser.parse(options, args)
			if (cl.hasOption(HELP)) {
				printHelp(options)
			} else {
				val ais = #[new AIPlayerGameManipulator(#["java", "SampleAI"]),
					new AIPlayerGameManipulator(#["java", "SampleAI"]),
					new AIPlayerGameManipulator(#["java", "SampleAI"]),
					new AIPlayerGameManipulator(#["java", "SampleAI"])
				].map[it.limittingTime(1000)]
				// do a game
			}
		} catch (ParseException e) {
			System.err.println("Error: " + e.getMessage())
			printHelp(options)
			System.exit(-1)
		}
	}
}

class Game {
}

// Generics parameters <Game, String[]> indicate runPreProcessing receives Game object
// and runProcessing and runPostProcessing returns String[] object
abstract class GameManipulator extends Manipulator<Game, String[]> {
}

class AIPlayerGameManipulator extends GameManipulator {
	private ExternalComputerPlayer _com
	private Game _game
	private String[] _result

	new(String[] commandWithArguments) {
		_com = new ExternalComputerPlayer(commandWithArguments)
	}

	new(String[] commandWithArguments, String workingDir) {
		_com = new ExternalComputerPlayer(commandWithArguments, workingDir)
	}

	override protected runPreProcessing(Game game) {
		_game = game
	}

	override protected runProcessing() {
		val line = _com.readLine
		// do something
		_result = #[]
	}

	override protected runPostProcessing() {
		_result
	}
}
