package net.aicomp;

public class TestableGame extends Game {
	private int x = 123456789;
	private int y = 362436069;
	private int z = 521288629;
	private int w = 88675123;

	public TestableGame(int seed) {
		w = seed;
	}

	@Override
	protected int nextInt(int inclusiveMin, int inclusiveMax) {
		return xorShiftRandom() % (inclusiveMax - inclusiveMin + 1)
				+ inclusiveMin;
	}

	public int xorShiftRandom() {
		int t = x ^ (x << 11);
		x = y;
		y = z;
		z = w;
		w = (w ^ (w >>> 19) ^ (t ^ (t >>> 8)));
		return w & 0x7fffffff;
	}
}
