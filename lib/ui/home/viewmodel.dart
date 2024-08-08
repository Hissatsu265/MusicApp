import 'dart:async';

import 'package:flutter_1/data/model/song.dart';
import 'package:flutter_1/data/repository/repository.dart';

class MusicAppViewModel{
  StreamController<List<Song>> songsStream=StreamController();
  void loadSong(){
    final repository=DefaultRepository();
    repository.loadData().then((value)=>songsStream.add(value!));
    //tai sao phai dung steam
  }
}