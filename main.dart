import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OttTelka',
      theme: ThemeData.dark(),
      home: ChannelListPage(),
    );
  }
}

class Channel {
  final String name;
  final String url;
  Channel(this.name, this.url);
}

class ChannelListPage extends StatelessWidget {
  final List<Channel> channels = [
    Channel('RTVS 24', 'https://5g.towercom.sk/rtvs24-dash-mp4/manifest.mpd'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OttTelka — Channels')),
      body: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final ch = channels[index];
          return ListTile(
            title: Text(ch.name),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PlayerPage(channel: ch)),
            ),
          );
        },
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final Channel channel;
  PlayerPage({required this.channel});
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.channel.url)
      ..initialize().then((_) {
        setState(() {});
      });
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.channel.name)),
      body: Center(
        child: _videoController != null && _videoController!.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : CircularProgressIndicator(),
      ),
    );
  }
}
