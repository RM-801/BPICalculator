import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'song_detail_page.dart';
import '../models/song.dart';
import '../save.dart';
import '../calc.dart';
import '../widgets/menu.dart';

// import '../services/sort_service.dart';
// import '../widgets/filters.dart';
// import '../widgets/song_list_item.dart';

Future<List<Song>> loadSongs() async {
  String jsonString = await rootBundle.loadString('assets/data_fixed.json');
  final jsonData = json.decode(jsonString);
  print('JSON data loaded: ${jsonData['body'].length} songs');

  final List<dynamic> bodyList = jsonData['body'];
  final songs = bodyList.map((songJson) {
    print('Processing song: ${songJson['title']}');
    return Song.fromJson(songJson as Map<String, dynamic>);
  }).toList();

  print('Total songs processed: ${songs.length}');
  return songs;
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
    '3': true, // SPH
    '4': true, // SPA
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
            icon: const Icon(Icons.sort),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('排序方式'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('按 BPI 升序'),
                        onTap: () {
                          _sortSongsByBPI(ascending: true);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text('按 BPI 降序'),
                        onTap: () {
                          _sortSongsByBPI(ascending: false);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppMenuDrawer(),
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
                          child: Text('难度筛选',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      difficultyFilters[entry.key] =
                                          value ?? false;
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
                          child: Text('级别筛选',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
                        query.isEmpty ? '请输入搜索关键词' : '没有找到匹配的歌曲',
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("${searchResults[index].title} (${difficultyNames[searchResults[index].difficulty]})"),
                          subtitle: FutureBuilder<int?>(
                            future: getUserScore(searchResults[index].title, searchResults[index].difficultyLevel),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text('加载中...');
                              }
                              if (snapshot.hasError) {
                                return Text('加载失败');
                              }
                              final score = snapshot.data ?? 0;
                              final percentage = (score / (2 * searchResults[index].notes)) * 100;

                              return Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "$score (${percentage.toStringAsFixed(2)}%)",
                                      textAlign: TextAlign.left, // 左对齐
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'BPI: ${calculateBPI(score, searchResults[index].avg, searchResults[index].wr, searchResults[index].notes).toStringAsFixed(2)}',
                                      textAlign: TextAlign.right, // 右对齐
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
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
    // 完全匹配的结果
    final exactMatches = allSongs.where((song) {
      return song.title.toLowerCase() == query.toLowerCase();
    }).toList();

    // 部分匹配的结果
    final partialMatches = allSongs.where((song) {
      return song.title.toLowerCase().contains(query.toLowerCase()) &&
          song.title.toLowerCase() != query.toLowerCase();
    }).toList();

    // 合并完全匹配和部分匹配的结果
    final filteredSongs = [
      ...exactMatches,
      ...partialMatches,
    ];

    // 进一步筛选难度和级别
    return filteredSongs.where((song) {
      bool matchesDifficulty = difficultyFilters[song.difficulty] ?? false;
      bool matchesLevel = levelFilters[song.difficultyLevel] ?? false;
      return matchesDifficulty && matchesLevel;
    }).toList();
  }

  void _sortSongsByBPI({bool ascending = true}) async {
    // 创建一个 Map 存储每首歌曲的 BPI
    Map<String, double> bpiMap = {};

    // 加载每首歌曲的 BPI
    for (var song in allSongs) {
      final savedBPI = await getUserBPI(song.title, song.difficultyLevel) ?? -15.0;
      final key = '${song.title}_${song.difficultyLevel}';
      bpiMap[key] = savedBPI;
    }

    // 根据 BPI 排序
    setState(() {
      allSongs.sort((a, b) {
        final keyA = '${a.title}_${a.difficultyLevel}';
        final keyB = '${b.title}_${b.difficultyLevel}';

        if (ascending) {
          return (bpiMap[keyA] ?? -15.0).compareTo(bpiMap[keyB] ?? -15.0);
        } else {
          return (bpiMap[keyB] ?? -15.0).compareTo(bpiMap[keyA] ?? -15.0);
        }
      });

      // 更新搜索结果
      searchResults = _filterSongs();
    });
  }
}
