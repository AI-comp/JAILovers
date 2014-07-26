package net.aicomp

import net.exkazuu.gameaiarena.manipulator.Manipulator
import net.exkazuu.gameaiarena.player.ExternalComputerPlayer
import org.apache.commons.cli.BasicParser
import org.apache.commons.cli.HelpFormatter
import org.apache.commons.cli.OptionBuilder
import org.apache.commons.cli.Options
import org.apache.commons.cli.ParseException
import org.apache.commons.cli.CommandLine

class Main {
	static val HELP = "h"
	static val FPS = "f"
	static val CUI_MODE = "c"
	static val RESULT_MODE = "r"
	static val REPLAY_MODE = "p"
	static val SILENT = "s"
	static val LIGHT_GUI_MODE = "l"
	static val EXTERNAL_AI_PROGRAM = "a"
	static val WORK_DIR_AI_PROGRAM = "w"
	static val NOT_SHOWING_LOG = "n"

	static def buildOptions() {
		OptionBuilder.hasArgs()
		OptionBuilder.withDescription("Set 1-4 AI players with external programs.")
		val externalAIOption = OptionBuilder.create(EXTERNAL_AI_PROGRAM)

		OptionBuilder.hasArgs()
		OptionBuilder.withDescription("Set working directories for external programs.")
		val workDirOption = OptionBuilder.create(WORK_DIR_AI_PROGRAM)

		val options = new Options().addOption(HELP, false, "Print this help.").addOption(FPS, false, "Enable CUI mode.").
			addOption(CUI_MODE, false, "Enable CUI mode.").addOption(RESULT_MODE, false,
				"Enable result mode which show only a screen of a result.").addOption(REPLAY_MODE, true,
				"Replay the specified .rep file.").addOption(LIGHT_GUI_MODE, false,
				"Enable light and fast GUI mode by reducing rendering frequency.").addOption(NOT_SHOWING_LOG, false,
				"Disable showing logs in the screen.").addOption(SILENT, false,
				"Disable writing log files in the log directory.").addOption(externalAIOption).addOption(workDirOption)
		options
	}

	static def printHelp(Options options) {
		val help = new HelpFormatter()
		help.printHelp("java -jar JAILovers.jar [OPTIONS]\n" + "[OPTIONS]: ", "", options, "", true)
	}

	static def String[] getOptionsValuesWithoutNull(CommandLine cl, String option) {
		if (cl.hasOption(option))
			cl.getOptionValues(option)
		else
			#[]
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
	}

	static def void main(String[] args) {
		val options = buildOptions()
		try {
			val parser = new BasicParser()
			val cl = parser.parse(options, args)
			if (cl.hasOption(HELP)) {
				printHelp(options)
			} else {
				val ais = #[
					new AIPlayerGameManipulator(#["java", "SampleAI"]),
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
