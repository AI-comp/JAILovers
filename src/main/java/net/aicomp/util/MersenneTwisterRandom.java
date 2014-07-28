package net.aicomp.util;

import java.util.Random;

public class MersenneTwisterRandom extends Random {

	private static final long serialVersionUID = 2479573230251354962L;

	private MersenneTwister generator = null;

	public MersenneTwisterRandom() {
		this(System.currentTimeMillis());
	}

	public MersenneTwisterRandom(long seed) {
		super(seed);
		setSeed(seed);
	}

	public MersenneTwisterRandom(int[] seedArray) {
		init(seedArray);
	}

	@Override
	synchronized public void setSeed(long seed) {
		int[] seedArray = new int[2];
		seedArray[0] = (int) (seed & 0xffffffff);
		seedArray[1] = (int) (seed >>> 32);

		if (seedArray[1] == 0) {
			init(seedArray[0]);
		} else {
			init(seedArray);
		}
	}

	@Override
	protected int next(int bits) {
		return generator.nextInt() >>> (32 - bits);
	}

	synchronized public void setSeed(int[] seedArray) {
		init(seedArray);
	}

	private void init(int seed) {
		if (generator == null) {
			generator = new MersenneTwister(seed);
		} else {
			generator.init(seed);
		}
	}

	private void init(int[] seedArray) {
		if (generator == null) {
			generator = new MersenneTwister(seedArray);
		} else {
			generator.init(seedArray);
		}
	}
}
