import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
      
class MyHomePage extends StatefulWidget {
  const 
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   final List<String> _imageUrls = [
    'https://images.unsplash.com/photo-1531804055935-76742b86da38?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyNjA3fDB8MXxzZWFyY2h8M3x8YWJzdHJhY3R8ZW58MHx8fHwxNjE5NzU4NjEx&ixlib=rb-1.2.1&q=80&w=1080',
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyNjA3fDB8MXxzZWFyY2h8MXx8bGFuZHNjYXBlfGVufDB8fHx8MTYxOTc1ODc3Mw&ixlib=rb-1.2.1&q=80&w=1080',
    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyNjA3fDB8MXxzZWFyY2h8MTF8fG5hdHVyZXxlbnwwfHx8fDE2MTk3NTg4MDg&ixlib=rb-1.2.1&q=80&w=1080',
    'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyNjA3fDB8MXxzZWFyY2h8MXx8Zm9yZXN0fGVufDB8fHx8MTYxOTc1ODgzMg&ixlib=rb-1.2.1&q=80&w=1080',
  ];

  late ImageProvider currentImageProvider;

  @override
  void initState(){
    super.initState();
    currentImageProvider = NetworkImage(_imageUrls[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                
              )
              ),
          ],
        ),
      ),
    );
  }
}


class TopWeatherImageWidget extends StatelessWidget{
  final ImageProvider imageProvider;

  const TopWeatherImageWidget({Key? key, required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
