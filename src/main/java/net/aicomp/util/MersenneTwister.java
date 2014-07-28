/*
  MersenneTwister from 数学的逆説
  http://homepage2.nifty.com/mathpara/
 */

package net.aicomp.util;

public class MersenneTwister {
	private static final int N = 624;
	private static final int M = 397;

	private final int mt[] = new int[N];

	private int mtIndex = N + 1;

	/**
	 * seedでRandomIntGeneratorのインスタンスを作る
	 * 
	 * @param seed
	 *            シード
	 */
	public MersenneTwister(int seed) {
		init(seed);
	}

	/**
	 * 配列seedArrayでRandomIntGeneratorのインスタンスを作る
	 * 
	 * @param seed
	 *            シード配列
	 */
	public MersenneTwister(int[] seedArray) {
		init(seedArray);
	}

	/**
	 * 一様分布の int 型の擬似乱数を返す。
	 * 
	 * @return 一様分布の int 型の次の擬似乱数値
	 */
	public int nextInt() {
		int nextInt = generateInt();

		// 精度を上げる為の調律
		nextInt = temper(nextInt);

		return nextInt;
	}

	public double random() {
		int i = nextInt();
		long l = i >= 0 ? i : (long) (i & 0x7FFFFFFF) + (1L << 31);
		return l * (1.0 / 4294967296.0);
	}

	/**
	 * seedでMersenne Twister配列を初期化する
	 * 
	 * @param seed
	 *            シード
	 */
	public void init(int seed) {

		long[] longMt = createLongMt(seed);

		setMt(longMt);
	}

	/**
	 * 配列seedArrayでMersenne Twister配列を初期化する
	 * 
	 * @param seedArray
	 *            シード配列
	 */
	public void init(int[] seedArray) {
		long[] longMt = createLongMt(19650218);

		final int max = (N > seedArray.length ? N : seedArray.length);
		for (int i = 1, j = 0, counter = 0; counter < max; i++, j++, counter++) {
			if (N <= i) {
				longMt[0] = longMt[N - 1];
				i = 1;
			}
			if (seedArray.length <= j) {
				j = 0;
			}
			longMt[i] ^= ((longMt[i - 1] ^ (longMt[i - 1] >>> 30)) * 1664525);
			longMt[i] += seedArray[j] + j;
			longMt[i] &= 0xffffffffL;
		}

		final int initial = max % (N - 1) + 1;
		for (int i = initial, counter = 0; counter < N - 1; i++, counter++) {
			if (N <= i) {
				longMt[0] = longMt[N - 1];
				i = 1;
			}
			longMt[i] ^= ((longMt[i - 1] ^ (longMt[i - 1] >>> 30)) * 1566083941);
			longMt[i] -= i;
			longMt[i] &= 0xffffffffL;
		}

		longMt[0] = 0x80000000L;

		setMt(longMt);
	}

	/**
	 * Mersenne Twisterアルゴリズムで、一様分布の int 型の擬似乱数を返す。
	 * 
	 * @return
	 */
	private synchronized int generateInt() {
		twist();

		int ret = mt[mtIndex];
		mtIndex++;

		return ret;
	}

	/**
	 * 配列をtwistする
	 *
	 */
	private void twist() {
		final int[] BIT_MATRIX = new int[] { 0x0, 0x9908b0df };
		final int UPPER_MASK = 0x80000000;
		final int LOWER_MASK = 0x7fffffff;

		if (mtIndex < N) {
			return;
		}

		if (mtIndex > N) {
			init(5489);
		}

		for (int i = 0; i < N; i++) {
			int x = (mt[i] & UPPER_MASK) | (mt[(i + 1) % N] & LOWER_MASK);
			mt[i] = mt[(i + M) % N] ^ (x >>> 1) ^ BIT_MATRIX[x & 0x1];
		}

		mtIndex = 0;
	}

	/**
	 * 調律する
	 * 
	 * @param num
	 *            調律するint
	 * @return 調律されたint
	 */
	private static int temper(int num) {

		num ^= (num >>> 11);
		num ^= (num << 7) & 0x9d2c5680;
		num ^= (num << 15) & 0xefc60000;
		num ^= (num >>> 18);

		return num;
	}

	/**
	 * 2^32 - 1以下のlongを、右32ビット列だけintに変換する
	 * 
	 * @param num
	 *            2^32 - 1以下のlong
	 * @return 変換したint
	 */
	private static int toInt(long num) {
		return (int) (num > Integer.MAX_VALUE ? num - 0x100000000L : num);
	}

	/**
	 * seedから、初期化したmtをlongで作る
	 * 
	 * @param seed
	 *            シード
	 * @return 初期化したmt
	 */
	private static long[] createLongMt(int seed) {
		long[] longMt = new long[N];

		longMt[0] = seed & 0xffffffffL;

		for (int i = 1; i < N; i++) {
			longMt[i] = longMt[i - 1];

			longMt[i] >>>= 30;
			longMt[i] ^= longMt[i - 1];
			longMt[i] *= 0x6C078965L;
			longMt[i] += i;
			longMt[i] &= 0xffffffffL;
		}

		return longMt;
	}

	/**
	 * long型の配列を、ビット配列としてintに変換して、インスタンス変数mtにセットする
	 * 
	 * @param longMt
	 *            配列
	 */
	synchronized private void setMt(long[] longMt) {
		for (int i = 0; i < N; i++) {
			mt[i] = toInt(longMt[i]);
		}

		mtIndex = N;
	}
}
