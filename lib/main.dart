import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<Gif> gifs = [];
  Timer? timeOut;

  void searchGifs(String searchTerm) {
    if (timeOut?.isActive == true) {
      timeOut?.cancel();
    }

    timeOut = Timer(const Duration(milliseconds: 300), () {
      fetchGifs(searchTerm);
    });
  }

  Future fetchGifs(String searchTerm) async {
    final List data = await GiphyApi.search(searchTerm);

    setState(() {
      gifs = data.map((gif) => Gif.fromJson(gif)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for GIF images'),
        backgroundColor: const Color.fromARGB(255, 91, 91, 91),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  hintText: 'funny cat',
                ),
                onChanged: searchGifs,
              ),
            ),
            Expanded(
              child: GifList(gifs: gifs),
            ),
          ],
        ),
      ),
    );
  }
}

class GiphyApi {
  static const String baseUrl = 'https://api.giphy.com/v1/gifs';
  static const String apiKey = 'beSTWcEblG2EV3TCwtAJ0NN97hguS8bg';

  static Future<List> search(String searchTerm) async {
    final url = '$baseUrl/search?api_key=$apiKey&q=$searchTerm';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else {
      throw Exception('Failed to load GIFs');
    }
  }
}

class Gif {
  final String id;
  final String url;
  final String title;

  Gif({
    required this.id, 
    required this.url, 
    required this.title
  });

  factory Gif.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final url = json['images']['downsized_medium']['url'];
    final title = json['title'];

    return Gif(id: id, url: url, title: title);
  }
}

class GifList extends StatelessWidget {
  final List<Gif> gifs;

  const GifList({super.key, required this.gifs});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: gifs.length,
      itemBuilder: (BuildContext context, int index) {
        final gif = gifs[index];
        return GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(gif.title),
          ),
          child: CachedNetworkImage(
            imageUrl: gif.url,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      },
    );
  }
}

// Unfortunately, I didn't implement request pagination.