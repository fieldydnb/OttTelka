import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

void main() {
  runApp(const MyApp());
}

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final String streamUrl = 'https://5g.towercom.sk/rtvs24-dash-mp4/manifest.mpd';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OttTelka')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play RTVS 24'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(url: streamUrl)));
              },
            ),
          ),
          const Expanded(child: Center(child: Text('Vyberte kanál a stlačte Play', style: TextStyle(fontSize: 16)))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Domov'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
        ],
        currentIndex: 0,
        onTap: (_) {},
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final String url;
  const PlayerPage({super.key, required this.url});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    super.initState();
    BetterPlayerConfiguration betterPlayerConfiguration = const BetterPlayerConfiguration(
      autoPlay: true,
      allowedScreenSleep: false,
      aspectRatio: 16/9,
      fullScreenByDefault: false,
    );

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      useAsmsSubtitles: false,
      drmConfiguration: null,
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController!.setupDataSource(dataSource);
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RTVS 24')),
      body: GestureDetector(
        onTap: () {
          // toggle fullscreen
          _betterPlayerController?.enterFullScreen();
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: 16/9,
            child: BetterPlayer(controller: _betterPlayerController!),
          ),
        ),
      ),
    );
  }
}
