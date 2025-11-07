import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // KRITICKÉ: MediaKit.ensureInitialized() MUSÍ byť PRVÝ!
  try {
    MediaKit.ensureInitialized();
    print('✓ MediaKit initialized');
  } catch (e) {
    print('❌ MediaKit error: $e');
  }
  
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
    Channel('Jednotka', 'https://livesim2.dashif.org/livesim2/testpic_2s/Manifest.mpd', 'assets/logos/jednotka.png'),
    Channel('Dvojka', 'https://livesim2.dashif.org/livesim2/WAVE/av/combined.mpd', 'assets/logos/dvojka.png'),
    Channel(':24', 'https://5g.towercom.sk/rtvs24-dash-mp4/manifest.mpd', 'assets/logos/stvr24.png'),
    Channel('Šport', 'https://livesim2.dashif.org/livesim2/testpic4_8s/Manifest600.mpd', 'assets/logos/sport.png'),
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
                      builder: (_) => PlayerPage(title: ch.name, url: ch.url),
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

  const PlayerPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    _play();
  }

  Future<void> _play() async {
    try {
      print('🎬 Opening stream: ${widget.url}');
      await player.open(Media(widget.url));
      print('✓ Stream opened successfully');
    } catch (e) {
      print('❌ Error opening stream: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Video(
          controller: controller,
          controls: MaterialVideoControls,
        ),
      ),
    );
  }
}
