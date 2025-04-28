import 'dart:math';

num pgf(num input) {
  num result = 0;
  result = 1 + ((input - 0.5) / (1 - input));
  return result;
}

num calculateBPI(int score, int average, int top, int note, {double coefficient = 1.175}) {
  int maxScore = 2 * note;

  if (score == top) {
    return 100;
  }

  num bpi = 0;
  num lowerLimit = -15;

  num s = score / maxScore;
  num k = average / maxScore;
  num z = top / maxScore;

  num S = (score == maxScore) ? 0.8 * maxScore : pgf(s);
  num K = pgf(k);
  num Z = (top == maxScore) ? 0.8 * maxScore : pgf(z);

  num _S = S / K;
  num _Z = Z / K;

  if (score >= average) {
    bpi = 100 * pow((log(_S) / log(_Z)), coefficient);
  } else {
    bpi = -100 * pow((-log(_S) / log(_Z)), coefficient);
  }

  bpi = max(bpi, lowerLimit);

  return bpi;
}

