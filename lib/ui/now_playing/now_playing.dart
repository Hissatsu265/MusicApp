import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_1/data/model/song.dart';
import 'package:flutter_1/ui/now_playing/audio_player_manager.dart';
import 'package:just_audio/just_audio.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.songs, required this.song});

  final Song song;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingsong: song,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.songs, required this.playingsong});

  final Song playingsong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animcontroler;
  late AudioPlayerManager _audioPlayerManager;
  late int selected_itemIndex;
  late Song _song;
  late double _currentAnimation;

  @override
  void initState() {
    _currentAnimation=0.0;
    super.initState();
    _animcontroler = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    );
    _song=widget.playingsong;

    _audioPlayerManager =
        AudioPlayerManager(songurl: _song.source);
    _audioPlayerManager.init();

    selected_itemIndex=widget.songs.indexOf(widget.playingsong);
  }

  @override
  void dispose() {
    _audioPlayerManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenwidth - delta) / 2;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Now Playing'),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ),
        child: Scaffold(
            body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _song.album,
              ),
              const SizedBox(height: 16),
              const Text('__ ___ __'),
              const SizedBox(height: 48),
              //----------------------------------------
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_animcontroler),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/Music_icon.png',
                    image: _song.image,
                    width: screenwidth - delta,
                    height: screenwidth - delta,
                    imageErrorBuilder: (context, error, stackTr) {
                      return Image.asset(
                        'assets/Music_icon.png',
                        width: screenwidth - delta,
                        height: screenwidth - delta,
                      );
                    },
                  ),
                ),
              ),
              //-----------------------------------------
              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.share),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_song.title),
                          const SizedBox(height: 8),
                          Text(_song.artist,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  )),
                        ],
                      ),
                      IconButton(
                          onPressed: () {}, icon: Icon(Icons.favorite_outline)),
                    ],
                  ),
                ),
              ),
              //-----------------------------------------------------------
              Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, bottom: 16, top: 32),
                child: _progressBarPlaying(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, bottom: 16, top: 8),
                child: _mediaButton(),
              ),
            ],
          ),
        )));
  }

  Widget _mediaButton() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: null,
              icon: Icons.shuffle,
              color: Colors.black45,
              size: 24.0),
          MediaButtonControl(
              function: _setPrevSong,
              icon: Icons.skip_previous,
              color: Colors.black45,
              size: 32.0),
          _playbutton(),
          MediaButtonControl(
              function: _setNextSong,
              icon: Icons.skip_next,
              color: Colors.black45,
              size: 32.0),
          MediaButtonControl(
              function: null,
              icon: Icons.repeat,
              color: Colors.black45,
              size: 24.0),
        ],
      ),
    );
  }
  void _setNextSong(){
    _animcontroler.stop();
    _currentAnimation=0.0;
    selected_itemIndex+=1;
    final nextSong=widget.songs[selected_itemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song=nextSong;
    });
  }
  void _setPrevSong(){
    _animcontroler.stop();
    _currentAnimation=0.0;
    selected_itemIndex-=1;
    final nextSong=widget.songs[selected_itemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song=nextSong;
    });
  }
  StreamBuilder<DurationState> _progressBarPlaying() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationstate = snapshot.data;
          final progress = durationstate?.progress ?? Duration.zero;
          final buffer = durationstate?.buffered ?? Duration.zero;
          final total = durationstate?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffer,
            onSeek: _audioPlayerManager.player.seek,
            baseBarColor: Colors.grey.withOpacity(0.3),
            progressBarColor: Colors.lightGreenAccent,
            bufferedBarColor: Colors.grey.withOpacity(0.6),
            thumbColor: Colors.green,
            barHeight: 5,
          );
        });
  }

  StreamBuilder<PlayerState> _playbutton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playstate = snapshot.data;
          final processingState = playstate?.processingState;
          final playing = playstate?.playing;
          if (processingState == ProcessingState.buffering ||
              processingState == ProcessingState.loading) {
            return Container(
              margin: const EdgeInsets.all(8),
              width: 48,
              height: 48,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.play();
                  _animcontroler.forward(from: _currentAnimation);
                  _animcontroler.repeat();
                },
                icon: Icons.play_arrow_rounded,
                color: null,
                size: 48);
          } else if (processingState != ProcessingState.completed) {
            return MediaButtonControl(
                function: () {
                  _animcontroler.stop();
                  _currentAnimation=_animcontroler.value;
                  _audioPlayerManager.player.pause();
                },
                icon: Icons.pause,
                color: null,
                size: 48);
          } else {
            if (processingState==ProcessingState.completed){
              _animcontroler.stop();
              _currentAnimation=0.0;

            }
            return MediaButtonControl(
                function: () {
                  _currentAnimation=0.0;
                  _animcontroler.forward(from: _currentAnimation);
                  _animcontroler.repeat();
                  _audioPlayerManager.player.seek(Duration.zero);
                },
                icon: Icons.replay,
                color: null,
                size: 48);
          }
        });
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl(
      {super.key,
      required this.function,
      required this.icon,
      required this.color,
      required this.size});

  final void Function()? function;
  final IconData icon;
  final Color? color;
  final double? size;

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
