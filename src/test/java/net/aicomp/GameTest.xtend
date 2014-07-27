package net.aicomp;

import org.junit.Test

import static org.hamcrest.Matchers.*
import static org.junit.Assert.*

class GameTest {
	@Test def constructGame() {
		assertThat(new Game(), is(not(nullValue)))
	}
}
