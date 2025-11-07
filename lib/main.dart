import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STVR LiveTV',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
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
  Channel('Jednotka', 'https://commondatastorage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4', 'assets/logos/jednotka.png'),
  Channel('Dvojka', 'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ElephantsDream.mp4', 'assets/logos/dvojka.png'),
  Channel(':24', 'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ForBiggerBlazes.mp4', 'assets/logos/stvr24.png'),
  Channel('Šport', 'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ForBiggerEscapes.mp4', 'assets/logos/sport.png'),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STVR LiveTV')),
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
                      Image.asset(
                        ch.logoAsset,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ch.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  const PlayerPage({
    super.key,
    required this.title,
    required this.url,
    required this.logo,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController _controller;
  bool isInitialized = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _controller.initialize();
      _controller.play();
      setState(() => isInitialized = true);
    } catch (e) {
      setState(() => errorMessage = 'Chyba: $e');
      print('❌ Player error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: isInitialized
          ? Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    FloatingActionButton(
                      backgroundColor: Colors.black54,
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: errorMessage != null
                  ? Text(errorMessage!)
                  : const CircularProgressIndicator(),
            ),
    );
  }
}
