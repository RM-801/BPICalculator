import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 版本号与版本名映射
const Map<String, String> versionMap = {
  "32": "Pinky Crush",
  "31": "EPOLIS",
  "30": "RESIDENT",
  "29": "CastHour",
  "28": "BISTROVER",
  "27": "HEROIC VERSE",
  "26": "Rootage",
  "25": "CANNON BALLERS",
  "24": "SINOBUZ",
  "23": "copula",
  "22": "PENDUAL",
  "21": "SPADA",
  "20": "tricoro",
  "19": "Lincle",
  "18": "Resort Anthem",
  "17": "SIRIUS",
  "16": "EMPRESS",
  "15": "DJ TROOPERS",
  "14": "GOLD",
  "13": "DistorteD",
  "12": "HAPPY SKY",
  "11": "RED",
  "10": "10th",
  "9": "9th",
  "8": "8th",
  "7": "7th",
  "6": "6th",
  "5": "5th"
};

// 状态缩写映射
const Map<String, String> statusAbbr = {
  'FULLCOMBO': 'FC',
  'EX HARD CLEAR': 'EXHC',
  'HARD CLEAR': 'HC',
  'CLEAR': 'NC',
  'EASY CLEAR': 'EC',
  'ASSISTED CLEAR': 'AC',
  'FAILED': 'F',
  'NO PLAY': 'N',
};

String getVersionName(String version) {
  return versionMap[version] ?? version;
}

Future<List<EarthPowerSong>> loadEarthPowerSongs() async {
  final jsonString =
      await rootBundle.loadString('assets/earth_power_filled.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  final prefs = await SharedPreferences.getInstance();

  return jsonList.map((e) {
    final song = EarthPowerSong.fromJson(e);
    final key = '${song.title}_${song.difficulty}';
    song.status = prefs.getString(key) ?? 'NO PLAY';
    return song;
  }).toList();
}

class EarthPowerSong {
  final String title;
  final String difficulty;
  final String level;
  final String version;
  final String normal;
  final String hard;
  String status;

  EarthPowerSong({
    required this.title,
    required this.difficulty,
    required this.level,
    required this.version,
    required this.normal,
    required this.hard,
    this.status = 'NO PLAY',
  });

  factory EarthPowerSong.fromJson(Map<String, dynamic> json) {
    return EarthPowerSong(
      title: json['title'],
      difficulty: json['difficulty'],
      level: json['level'],
      version: json['version'],
      normal: json['normal'],
      hard: json['hard'],
    );
  }
}

class EarthPowerPage extends StatefulWidget {
  const EarthPowerPage({super.key});

  @override
  State<EarthPowerPage> createState() => _EarthPowerPageState();
}

class _EarthPowerPageState extends State<EarthPowerPage> {
  Set<String> selectedVersions = {};
  Set<String> selectedStatus = {};
  final ValueNotifier<int> statusBarNotifier = ValueNotifier(0);
  bool showNormal = false; // 新增

  @override
  void dispose() {
    statusBarNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<EarthPowerSong>>(
          future: loadEarthPowerSongs(),
          builder: (context, snapshot) {
            int belowHardCount = 0;
            int belowNormalCount = 0;
            if (snapshot.hasData) {
              final songs = snapshot.data!;
              belowHardCount = songs
                  .where((song) =>
                      song.status != 'FULLCOMBO' &&
                      song.status != 'EX HARD CLEAR' &&
                      song.status != 'HARD CLEAR')
                  .length;
              belowNormalCount = songs
                  .where((song) =>
                      song.status != 'FULLCOMBO' &&
                      song.status != 'EX HARD CLEAR' &&
                      song.status != 'HARD CLEAR'&&
                      song.status != 'NORMAL CLEAR')
                  .length;
            }
            return Text(showNormal?'SP☆12ノマゲ表(未ノマゲ：$belowNormalCount)':'SP☆12ハード表(未難：$belowHardCount)');
          },
        ),
      ),
      body: FutureBuilder<List<EarthPowerSong>>(
        future: loadEarthPowerSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }
          final songs = snapshot.data ?? [];
          if (songs.isEmpty) {
            return const Center(child: Text('暂无数据'));
          }

          var filteredSongs = songs.where((song) {
            final versionOk = selectedVersions.isEmpty ||
                selectedVersions.contains(song.version);
            final statusOk = selectedStatus.isEmpty ||
                selectedStatus.contains(song.status);
            return versionOk && statusOk;
          }).toList();

          // 根据 showNormal 分组
          final Map<String, List<EarthPowerSong>> grouped = {};
          for (var song in filteredSongs) {
            final key = showNormal ? song.normal : song.hard;
            grouped.putIfAbsent(key, () => []).add(song);
          }

          return ListView(
            children: [
              // 统计栏（只刷新自己）
              ValueListenableBuilder(
                valueListenable: statusBarNotifier,
                builder: (context, _, __) {
                  // 统计各状态数量
                  Map<String, int> statusCount = {
                    for (var abbr in statusAbbr.values) abbr: 0,
                  };
                  for (var song in filteredSongs) {
                    final abbr = statusAbbr[song.status] ?? 'N';
                    statusCount[abbr] = (statusCount[abbr] ?? 0) + 1;
                  }
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: statusAbbr.values.map((abbr) {
                            return Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(abbr,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('${statusCount[abbr]}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // 筛选器
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          // 版本筛选
                          FilterChip(
                            label: const Text('版本筛选'),
                            selected: selectedVersions.isNotEmpty,
                            onSelected: (_) async {
                              final result = await showDialog<Set<String>>(
                                context: context,
                                builder: (context) {
                                  final temp = Set<String>.from(selectedVersions);
                                  return AlertDialog(
                                    title: const Text('选择版本'),
                                    content: SizedBox(
                                      width: 300,
                                      height: 400,
                                      child: ListView(
                                        children: versionMap.entries.map((e) {
                                          return StatefulBuilder(
                                            builder: (context, setStateDialog) {
                                              return CheckboxListTile(
                                                value: temp.contains(e.key),
                                                title: Text(e.value),
                                                onChanged: (v) {
                                                  if (v == true) {
                                                    temp.add(e.key);
                                                  } else {
                                                    temp.remove(e.key);
                                                  }
                                                  setStateDialog(() {});
                                                },
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, temp),
                                        child: const Text('确定'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (result != null) {
                                setState(() {
                                  selectedVersions = result;
                                });
                              }
                            },
                          ),
                          // 状态筛选
                          FilterChip(
                            label: const Text('状态筛选'),
                            selected: selectedStatus.isNotEmpty,
                            onSelected: (_) async {
                              final result = await showDialog<Set<String>>(
                                context: context,
                                builder: (context) {
                                  final temp = Set<String>.from(selectedStatus);
                                  return AlertDialog(
                                    title: const Text('选择状态'),
                                    content: SizedBox(
                                      width: 300,
                                      height: 400,
                                      child: ListView(
                                        children: [
                                          ..._SongCardState.statusOptions
                                              .map((s) => StatefulBuilder(
                                                    builder:
                                                        (context, setStateDialog) {
                                                      return CheckboxListTile(
                                                        value: temp.contains(s),
                                                        title: Text(s),
                                                        onChanged: (v) {
                                                          if (v == true) {
                                                            temp.add(s);
                                                          } else {
                                                            temp.remove(s);
                                                          }
                                                          setStateDialog(() {});
                                                        },
                                                      );
                                                    },
                                                  )),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, temp),
                                        child: const Text('确定'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (result != null) {
                                setState(() {
                                  selectedStatus = result;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    // 切换按钮
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showNormal = !showNormal;
                        });
                      },
                      child: Text(showNormal ? '切换到 Hard' : '切换到 Normal'),
                    ),
                  ],
                ),
              ),
              // 分组展示
              ...grouped.entries.map((entry) {
                return ExpansionTile(
                  title: Align(
                    alignment: Alignment.center,
                    child: Text(
                      entry.key,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // 设定最小卡片宽度，比如 260
                            const minCardWidth = 260.0;
                            int columns = (constraints.maxWidth / minCardWidth)
                                .floor()
                                .clamp(2, 5);
                            double cardWidth =
                                (constraints.maxWidth - (columns - 1) * 8) /
                                    columns;

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entry.value.map((song) {
                                return SizedBox(
                                  width: cardWidth,
                                  child: SongCard(
                                    song: song,
                                    onStatusChanged: () {
                                      statusBarNotifier.value++;
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class SongCard extends StatefulWidget {
  final EarthPowerSong song;
  final VoidCallback? onStatusChanged;

  const SongCard({required this.song, this.onStatusChanged, super.key});

  @override
  State<SongCard> createState() => _SongCardState();
}

class _SongCardState extends State<SongCard> {
  String status = 'NO PLAY';

  static const List<String> statusOptions = [
    'FULLCOMBO',
    'EX HARD CLEAR',
    'HARD CLEAR',
    'CLEAR',
    'EASY CLEAR',
    'ASSISTED CLEAR',
    'FAILED',
    'NO PLAY',
  ];

  @override
  void initState() {
    super.initState();
    _loadLampStatus();
  }

  Future<void> _loadLampStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${widget.song.title}_${widget.song.difficulty}';
    setState(() {
      status = prefs.getString(key) ?? 'NO PLAY';
      widget.song.status = status;
    });
  }

  Future<void> _saveLampStatus(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${widget.song.title}_${widget.song.difficulty}';
    await prefs.setString(key, value);
    widget.song.status = value;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'FULLCOMBO':
        return Colors.amber;
      case 'EX HARD CLEAR':
        return Colors.yellow;
      case 'HARD CLEAR':
        return Colors.red;
      case 'CLEAR':
        return Colors.blue;
      case 'EASY CLEAR':
        return Colors.lightGreen;
      case 'ASSISTED CLEAR':
        return const Color(0xFF8C86FC);
      case 'FAILED':
        return Colors.grey;
      case 'NO PLAY':
        return Colors.transparent;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: getStatusColor(status),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.song.title,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            Text(
              '${widget.song.difficulty}  ${getVersionName(widget.song.version)}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            PopupMenuButton<String>(
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onSelected: (value) {
                if (!mounted) return;
                setState(() {
                  status = value;
                  widget.song.status = value;
                });
                _saveLampStatus(value); // 保存到本地
                widget.onStatusChanged?.call(); // 通知统计栏刷新
              },
              itemBuilder: (context) => statusOptions
                  .map((s) => PopupMenuItem(value: s, child: Text(s)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
