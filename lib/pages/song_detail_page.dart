import 'package:flutter/material.dart';

import '../calc.dart';
import '../save.dart';
import '../models/song.dart';

class InfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const InfoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class SongDetailPage extends StatefulWidget {
  final Song song;
  SongDetailPage({required this.song});
  @override
  _SongDetailPageState createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  final TextEditingController _scoreController = TextEditingController();
  num? _bpi;
  int? _savedScore;

  @override
  void initState() {
    super.initState();
    _loadSavedScore(); // 在初始化时加载保存的分数
  }

  Future<void> _loadSavedScore() async {
    final savedScore =
        await getUserScore(widget.song.title, widget.song.difficultyLevel);
    final savedBPI =
        await getUserBPI(widget.song.title, widget.song.difficultyLevel);
    if (mounted) {
      // 确保组件仍然挂载
      setState(() {
        _savedScore = savedScore;
        if (savedScore != null) {
          _scoreController.text = savedScore.toString();
        }
        if (savedBPI != null) {
          _bpi = savedBPI;
        } else if (savedScore != null) {
          // 如果没有保存的 BPI，但有保存的分数，则重新计算 BPI
          _bpi = calculateBPI(
            savedScore,
            widget.song.avg,
            widget.song.wr,
            widget.song.notes,
            coefficient: widget.song.coef > 0 ? widget.song.coef : 1.175,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 居中对齐
          children: [
            Text(
              widget.song.title,
              style: TextStyle(fontSize: 18), // 主标题
            ),
            Text(
              "${difficultyNames[widget.song.difficulty] ?? ""} ☆${widget.song.difficultyLevel}",
              style: TextStyle(fontSize: 14), // 副标题
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(2.0),
        child: Column(
          children: [
            Row(
              children: [
                InfoColumn(title: 'Note数', value: widget.song.notes.toString()),
                InfoColumn(title: '全国TOP', value: widget.song.wr.toString()),
                InfoColumn(title: '皆传平均', value: widget.song.avg.toString()),
                InfoColumn(
                  title: '谱面系数',
                  value: widget.song.coef > 0
                      ? widget.song.coef.toString()
                      : "N/A（默认为1.175）",
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(scoreToGrade(_savedScore ?? 0, widget.song.notes)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("百分比:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          "${calculatePercentage(_savedScore ?? 0, widget.song.notes).toStringAsFixed(2)}%"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("BPI:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_bpi?.toStringAsFixed(2) ?? "-15"),
                    ],
                  ),
                ),
              ],
            ),
            TextField(
              controller: _scoreController,
              decoration: InputDecoration(
                labelText: '你的分数',
                suffixText: _savedScore != null ? '已保存' : null,
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () async {
                final score = int.tryParse(_scoreController.text) ?? 0;

                // 计算 BPI
                setState(() {
                  _bpi = calculateBPI(
                    score,
                    widget.song.avg,
                    widget.song.wr,
                    widget.song.notes,
                    coefficient:
                        widget.song.coef > 0 ? widget.song.coef : 1.175,
                  );
                });

                // 保存分数和 BPI
                await saveUserScore(widget.song.title,
                    widget.song.difficultyLevel, score, _bpi!);

                // 更新 _savedScore 并触发 UI 刷新
                setState(() {
                  _savedScore = score;
                });
              },
              child: Text('保存分数'),
            ),
          ],
        ),
      ),
    );
  }
}
