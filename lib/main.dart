import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'calc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'main.g.dart';

// 难度显示名称
final Map<String, String> difficultyNames = {
    '3': 'SPH',
    '4': 'SPA',
    '10': 'SPL',
    '8': 'DPH',
    '9': 'DPA',
    '11': 'DPL',
};

// 歌曲数据模型
@JsonSerializable()
class Song {
  final String title;
  final String difficulty;
  final int wr;
  final int avg;
  final int notes;
  final String bpm;
  final String difficultyLevel;
  final String dpLevel;
  final double coef;

  Song({
    required this.title,
    required this.difficulty,
    required this.wr,
    required this.avg,
    required this.notes,
    required this.bpm,
    required this.difficultyLevel,
    required this.dpLevel,
    required this.coef,
  });

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  Map<String, dynamic> toJson() => _$SongToJson(this);
}

// 加载歌曲数据
Future<List<Song>> loadSongs() async {
  String jsonString = await rootBundle.loadString('assets/data_fixed.json');
  final jsonData = json.decode(jsonString);
  print('JSON data loaded: ${jsonData['body'].length} songs');
  
  final List<dynamic> bodyList = jsonData['body'];
  final songs = bodyList
      .map((songJson) {
        print('Processing song: ${songJson['title']}');
        return Song.fromJson(songJson as Map<String, dynamic>);
      })
      .toList();
  
  print('Total songs processed: ${songs.length}');
  return songs;
}

// 模糊匹配函数
bool filterSongTitle(String query, String title) {
  return title.toLowerCase().contains(query.toLowerCase());
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BPI Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SongSearchPage(),
    );
  }
}

class SongSearchPage extends StatefulWidget {
  @override
  _SongSearchPageState createState() => _SongSearchPageState();
}

class _SongSearchPageState extends State<SongSearchPage> {
  List<Song> allSongs = [];
  List<Song> searchResults = [];
  String query = '';
  bool isLoading = true;
  String? errorMessage;
  
  // 难度选项和选中状态
  final Map<String, bool> difficultyFilters = {
    '3': true,  // SPH
    '4': true,  // SPA
    '10': true, // SPL
    // '8': false,  // DPH
    // '9': false,  // DPA
    // '11': false, // DPL
  };

  // 级别筛选状态
  final Map<String, bool> levelFilters = {
    '11': true, // 11级
    '12': true, // 12级
  };

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _loadSongs();
//      await _loadSavedScore();
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await loadSongs();
      print('Loaded ${songs.length} songs'); // Debug print
      setState(() {
        allSongs = songs;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      print('Error loading songs: $e'); // Debug print
      setState(() {
        isLoading = false;
        errorMessage = '加载歌曲数据失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSongs,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('歌曲搜索'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                searchResults = _filterSongs();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 难度和级别筛选器
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 难度筛选器
                Expanded(
                  flex: 5, // 设置宽度比例为 3
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('难度筛选', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Wrap(
                          spacing: 2.0,
                          children: difficultyFilters.entries.map((entry) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: entry.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      difficultyFilters[entry.key] = value ?? false;
                                      searchResults = _filterSongs();
                                    });
                                  },
                                ),
                                Text(difficultyNames[entry.key]!),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 级别筛选器
                Expanded(
                  flex: 2, // 设置宽度比例为 1
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('级别筛选', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Wrap(
                          spacing: 8.0,
                          children: levelFilters.entries.map((entry) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: entry.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      levelFilters[entry.key] = value ?? false;
                                      searchResults = _filterSongs();
                                    });
                                  },
                                ),
                                Text('☆${entry.key}'),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: '搜索歌曲',
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                  searchResults = _filterSongs();
                });
              },
            ),
            const SizedBox(height: 8),
            Text('搜索结果数量: ${searchResults.length}'),
            const SizedBox(height: 8),
            Expanded(
              child: searchResults.isEmpty
                  ? Center(
                      child: Text(
                        query.isEmpty
                            ? '请输入搜索关键词'
                            : '没有找到匹配的歌曲',
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(searchResults[index].title),
                          subtitle: Text(difficultyNames[searchResults[index].difficulty] ?? 'Unknown'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SongDetailPage(
                                  song: searchResults[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 修改筛选函数
  List<Song> _filterSongs() {
    return allSongs.where((song) {
      bool matchesQuery = query.isEmpty || 
          song.title.toLowerCase().contains(query.toLowerCase());
      bool matchesDifficulty = difficultyFilters[song.difficulty] ?? false;
      bool matchesLevel = levelFilters[song.difficultyLevel] ?? false;
      return matchesQuery && matchesDifficulty && matchesLevel;
    }).toList();
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
    _loadSavedScore();  // 在初始化时加载保存的分数
  }

  Future<void> _loadSavedScore() async {
    final savedScore = await getUserScore(widget.song.title, widget.song.difficultyLevel);
    final savedBPI = await getUserBPI(widget.song.title, widget.song.difficultyLevel);
    if (mounted) {  // 确保组件仍然挂载
      setState(() {
        _savedScore = savedScore;
        if (savedScore != null) {
          _scoreController.text = savedScore.toString();
        }
        if (savedBPI != null) {
          _bpi = savedBPI;
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
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Note数', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.song.notes.toString()),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('全国TOP', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.song.wr.toString()),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('皆传平均', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.song.avg.toString()),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('谱面系数', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.song.coef > 0 ? widget.song.coef.toString() : "N/A（默认为1.175）"),
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
              onPressed: () {
                final score = int.tryParse(_scoreController.text) ?? 0;
                setState(() {
                  _bpi = calculateBPI(
                    score,
                    widget.song.avg,
                    widget.song.wr,
                    widget.song.notes,
                    coefficient: widget.song.coef>0?widget.song.coef:1.175,
                  );
                });
                saveUserScore(widget.song.title, widget.song.difficultyLevel, score, _bpi!);
              },
              child: Text('保存分数'),
            ),
            if (_bpi != null)  // 只在有 BPI 值时显示
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'BPI是：${_bpi!.toStringAsFixed(2)}',  // 保留两位小数
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 保存用户分数和BPI到SharedPreferences
Future<void> saveUserScore(String songTitle, String difficultyLevel, int score, num bpi) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final key = '${songTitle}_${difficultyLevel}';
  await prefs.setString('${key}_score', score.toString());
  await prefs.setDouble('${key}_bpi', bpi.toDouble());
}

// 获取用户分数
Future<int?> getUserScore(String songTitle, String difficultyLevel) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final key = '${songTitle}_${difficultyLevel}';
  final scoreStr = prefs.getString('${key}_score');
  if (scoreStr != null) {
    return int.tryParse(scoreStr);
  }
  return null;
}

// 获取用户BPI
Future<double?> getUserBPI(String songTitle, String difficultyLevel) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final key = '${songTitle}_${difficultyLevel}';
  return prefs.getDouble('${key}_bpi');
}