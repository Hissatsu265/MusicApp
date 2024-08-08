import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  AudioPlayerManager({
    required this.songurl

  });

  String songurl;
  final player = AudioPlayer();
  Stream<DurationState>? durationState;

  void init() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>
      (player.positionStream,
        player.playbackEventStream,
            (position, playbackEvent) =>
            DurationState(progress: position,
                buffered: playbackEvent.bufferedPosition,
                total: playbackEvent.duration)

    );
    player.setUrl(songurl);
  }
  void dispose(){
    player.dispose();
  }
  void updateSongUrl(String url){
    songurl=url;
    init();
  }
}

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, this.total});

  final Duration progress;
  final Duration buffered;
  final Duration? total;

}
