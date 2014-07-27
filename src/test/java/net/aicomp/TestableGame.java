package net.aicomp;

public class TestableGame extends Game {
  private static long x = 123456789L;
  private static long y = 362436069L;
  private static long z = 521288629L;
  private static long w = 88675123L;

  @Override
  protected int nextInt(int inclusiveMin, int inclusiveMax) {
    return 0;
  }

  private static long xorShiftRandom() {
    long t = x ^ (x << 11);
    x = y;
    y = z;
    z = w;
    w = (w ^ (w >>> 19) ^ (t ^ (t >>> 8)));
    return w & 0x7fffffffffffffffL;
  }
}
