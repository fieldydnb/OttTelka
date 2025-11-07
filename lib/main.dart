import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OttTelka',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class Channel {
  final String name;
  final String url;
  final String logoAsset;
  const Channel(this.name, this.url, this.logoAsset);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  List<Channel> get channels => [
    Channel('Jednotka', 'https://livesim2.dashif.org/livesim2/testpic_2s/Manifest.mpd', 'assets/logos/jednotka.png'),
    Channel('Dvojka', 'https://livesim2.dashif.org/livesim2/WAVE/av/combined.mpd', 'assets/logos/dvojka.png'),
    Channel(':24', 'https://5g.towercom.sk/rtvs24-dash-mp4/manifest.mpd', 'assets/logos/stvr24.png'),
    Channel('Šport', 'https://livesim2.dashif.org/livesim2/testpic4_8s/Manifest600.mpd', 'assets/logos/sport.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STVR LiveTelka')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            for (final ch in channels)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerPage(title: ch.name, url: ch.url, logo: ch.logoAsset),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(ch.logoAsset, width: 100, height: 100, fit: BoxFit.contain),
                      const SizedBox(height: 12),
                      Text(ch.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
  final String logo;
  const PlayerPage({super.key, required this.title, required this.url, required this.logo});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
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
    WakelockPlus.disable();
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
