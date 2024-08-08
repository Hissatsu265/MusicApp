import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_1/data/model/song.dart';
import 'package:http/http.dart' as http;

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class RemoteData implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    final url = 'https://thantrieu.com/resources/braniumapis/songs.json';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final bodyContent = utf8.decode(response.bodyBytes);// chuyen doi bytecode de giu tieng viet
      var songWrap = jsonDecode(bodyContent) as Map;
      // var songList = songWrap['songs'] as List;// ep kieu
      // List<Song> songs = songList.map((index) => Song.fromJson(index)).toList();
      if (songWrap.containsKey('songs') && songWrap['songs'] != null) {
        var songList = songWrap['songs'] as List;
        List<Song> songs = songList.map((index) => Song.fromJson(index)).toList();
        return songs;
      } else {
        return null;
      }
    }
    else{
      return null;
    }
  }
}

class LocalData implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    final String response=await rootBundle.loadString('assets/songs.json');
    final jsonBody=jsonDecode(response) as Map;
    final songList=jsonBody['songs'] as List;
    List<Song> songs = songList.map((index) => Song.fromJson(index)).toList();
    return songs;

  }
}
