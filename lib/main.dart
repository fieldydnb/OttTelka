import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OttTelka',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class Channel {
  final String name;
  final String url;
  const Channel(this.name, this.url);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final String demoUrl = 'https://5g.towercom.sk/rtvs24-dash-mp4/manifest.mpd';

  List<Channel> get channels => [
        Channel('RTVS 24', demoUrl),
        Channel('RTVS 1', demoUrl),
        Channel('RTVS 2', demoUrl),
        Channel('RTVS 3', demoUrl),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OttTelka')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 16 / 9,
          children: [
            for (final ch in channels)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerPage(title: ch.name, url: ch.url),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow),
                    const SizedBox(width: 8),
                    Flexible(child: Text('Play ${ch.name}', overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final String title;
  final String url;
  const PlayerPage({super.key, required this.title, required this.url});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() => _ready = true);
        _controller
          ..setLooping(true)
          ..play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFullscreen() async {
    if (!_ready) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullscreenPlayer(controller: _controller, title: widget.title)),
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.fullscreen), onPressed: _openFullscreen),
        ],
      ),
      body: Center(
        child: _ready
            ? Stack(
                alignment: Alignment.bottomRight,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio == 0 ? 16 / 9 : _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: FloatingActionButton.small(
                      onPressed: _openFullscreen,
                      child: const Icon(Icons.fullscreen),
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class FullscreenPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final String title;
  const FullscreenPlayer({super.key, required this.controller, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
