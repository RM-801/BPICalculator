// ignore_for_file: non_constant_identifier_names

import 'dart:math';

double logBase(num base, num value) {
  return log(value) / log(base);
}

num pgf(num input) {
  num result = 0;
  result = 1 + ((input - 0.5) / (1 - input));
  return result;
}

num calculatePercentage(int score, int note)
{
  double percentage = 100 * score / (2 * note);
  return percentage;
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

double calculateOverallBPI (List<double> bpi)
{
  int n = bpi.length;
  double k = logBase(2,n);
  double overallBPI = 0;
  for(int i = 0; i < bpi.length; i++)
  {
    overallBPI += pow(bpi[i],k);
  }
    overallBPI /= k;
    overallBPI = pow(overallBPI, 1 / k).toDouble();
  return overallBPI;
}

enum Grade {
  MAX,
  AAA,
  AA,
  A,
  B,
  C,
  D,
  E,
  F,
}

class GradeThreshold {
  final Grade grade;
  final double threshold;

  const GradeThreshold(this.grade, this.threshold);
}

String scoreToGrade(int score, int note) 
{
  int maxScore = 2 * note;
  // 特殊情况：输入错误或MAX
    if (score > maxScore || score < 0 || note <= 0)
    {
      return "error";
    }

    if (score == maxScore) 
    {
      return "MAX+0";
    }

  double percentage = score / maxScore;

  // 定义等级和对应的阈值
  const List<GradeThreshold> thresholds = [
    GradeThreshold(Grade.MAX, 9 / 9),
    GradeThreshold(Grade.AAA, 8 / 9),
    GradeThreshold(Grade.AA, 7 / 9),
    GradeThreshold(Grade.A, 6 / 9),
    GradeThreshold(Grade.B, 5 / 9),
    GradeThreshold(Grade.C, 4 / 9),
    GradeThreshold(Grade.D, 3 / 9),
    GradeThreshold(Grade.E, 2 / 9),
  ];

  // 遍历阈值，找到对应的等级
  for (var i = 1; i < thresholds.length; i++) {
    if (percentage >= thresholds[i].threshold) {
      String upperGradeName = thresholds[i-1].grade.name;
      String lowerGradeName = thresholds[i].grade.name;
      int upperGradeBase = (thresholds[i-1].threshold * maxScore).ceil();
      int lowerGradeBase = (thresholds[i].threshold * maxScore).ceil();

      // 判断percentage是离更上一个等级更近，还是离当前的等级更近
      if (percentage > (thresholds[i].threshold + 0.5 / 9)) {
        return "$upperGradeName-${upperGradeBase - score}";
      } else {
        return "$lowerGradeName+${score - lowerGradeBase}";
      }
    }
  }

  // F特殊处理
  return percentage <= maxScore/9 ? "F+$score" : "E-${(2/9 * maxScore).ceil()-score}";
}