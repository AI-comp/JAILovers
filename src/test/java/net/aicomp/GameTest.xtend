package net.aicomp;

import org.apache.commons.cli.BasicParser
import org.junit.Test

import static org.hamcrest.Matchers.*
import static org.junit.Assert.*

class GameTest {
	@Test def void conductGame2() {
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
		System.out.println(TestableGame.xorShiftRandom)
	}
	
	@Test def void conductGame() {
		assertThat(new Game(), is(not(nullValue)))
		val parser = new BasicParser()

		val cl = parser.parse(
			Main.buildOptions,
			#[
				"-a",
				"java SampleAI 1",
				"-w",
				"defaultai",
				"-a",
				"java SampleAI 2",
				"-w",
				"defaultai",
				"-a",
				"java SampleAI 3",
				"-w",
				"defaultai",
				"-a",
				"java SampleAI 4",
				"-w",
				"defaultai"
			]
		)
		Main.start(cl)
	}
}
