package net.aicomp;

import net.aicomp.util.MersenneTwister
import org.apache.commons.cli.BasicParser
import org.junit.Test

import static org.hamcrest.Matchers.*
import static org.junit.Assert.*

class GameTest {
	def buildArguments(int seed1, int seed2, int seed3, int seed4) {
		#[
			"-a",
			"java SampleAI " + seed1,
			"-w",
			"defaultai",
			"-a",
			"java SampleAI " + seed2,
			"-w",
			"defaultai",
			"-a",
			"java SampleAI " + seed3,
			"-w",
			"defaultai",
			"-a",
			"java SampleAI " + seed4,
			"-w",
			"defaultai"
		]
	}

	@Test def void conductGame_0_1_2_3_4() {
		val cl = new BasicParser().parse(
			Main.buildOptions,
			buildArguments(0, 1, 2, 3)
		)
		val game = Main.start(new Game(4), cl)
		assertThat(game.ranking.get(0).index, is(0))
		assertThat(game.ranking.get(1).index, is(2))
		assertThat(game.ranking.get(2).index, is(3))
		assertThat(game.ranking.get(3).index, is(1))
		assertThat(game.ranking.get(0).popularity, is(2.0))
		assertThat(game.ranking.get(1).popularity, is(1.5))
		assertThat(game.ranking.get(2).popularity, is(0.0))
		assertThat(game.ranking.get(3).popularity, is(-3.5))
	}

	@Test def void conductGame_5_6_7_8_9() {
		val cl = new BasicParser().parse(
			Main.buildOptions,
			buildArguments(5, 6, 7, 8)
		)
		val game = Main.start(new Game(9), cl)
		assertThat(game.ranking.get(0).index, is(3))
		assertThat(game.ranking.get(1).index, is(0))
		assertThat(game.ranking.get(2).index, is(1))
		assertThat(game.ranking.get(3).index, is(2))
		assertThat(game.ranking.get(0).popularity, is(5.0))
		assertThat(game.ranking.get(1).popularity, is(-1.0))
		assertThat(game.ranking.get(2).popularity, is(-2.0))
		assertThat(game.ranking.get(3).popularity, is(-2.0))
	}
}
