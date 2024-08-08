import 'package:flutter_1/data/model/song.dart';
import 'package:flutter_1/data/source/source.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
}

class DefaultRepository implements Repository {
  final _remoteDatasource = RemoteData();
  final _localDatasource = LocalData();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    await _remoteDatasource.loadData().then((remotesong) {
      if (remotesong == null) {
        _localDatasource.loadData().then((index) {
          if (index != null) {
            songs.addAll(index);
          }
        });
      } else {
        songs.addAll(remotesong);
      }
    });
    return songs;
  }
}
