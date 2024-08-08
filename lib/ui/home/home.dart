import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_1/data/model/song.dart';
import 'package:flutter_1/ui/home/viewmodel.dart';
import 'package:flutter_1/ui/discovery/discovery.dart';
import 'package:flutter_1/ui/now_playing/now_playing.dart';
import 'package:flutter_1/ui/setting/setting.dart';
import 'package:flutter_1/ui/user/user.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tab = [
    const HomeTab(),
    const DiscoveryTab(),
    const SettingTab(),
    const AccoutTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Music App'),
        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.album), label: 'Discovery'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Accout'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Setting'),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            return _tab[index];
          },
        ));
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewmodel;

  @override
  void initState() {
    _viewmodel = MusicAppViewModel();
    _viewmodel.loadSong();
    obserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _viewmodel.songsStream.close();
  }

  // -------------------------------------------------
  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  //---------------------------------------------------
  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, inx) {
        return const Divider(
          color: Colors.black45,
          thickness: 1, //do day
          indent: 24, // cach trai
          endIndent: 24, //cach phai
        );
      },
      itemCount: songs.length,
      shrinkWrap: true, // cho phep cuon va co duong phan cach
    );
  }

  Widget getRow(int idx) {
    // return Center(child: Text(songs[idx].title));
    return _SongItemSection(
      paernt: this,
      song: songs[idx],
    );
  }

//----------------------------------------------------------------------
  void obserData() {
    _viewmodel.songsStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

//================================================
  void showbottomsheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular((16))),
            child: Container(
              height: 400,
              color: Colors.lightGreenAccent,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Modal Bottom Sheet'),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(context),// dong bottom sheet
                        child: Text('Close')),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // mo sang man hinh khac
  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        song: song,
      );
    }));
  }
//=========Homepagestate========================================
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.paernt,
    required this.song,
  });

  final _HomeTabPageState paernt;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 9,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/Music_icon.png',
          image: song.image,
          height: 48,
          width: 48,
          imageErrorBuilder: (context, error, r) {
            return Image.asset(
              'assets/Music_icon.png',
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          paernt.showbottomsheet();
        },
      ),
      onTap: () {
        paernt.navigate(song);
      },
    );
  }
}
