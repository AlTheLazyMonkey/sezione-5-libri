import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'libro.dart';
import 'libroScreen.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LibriScreen(),
    );
  }
}

class LibriScreen extends StatefulWidget {
  const LibriScreen({super.key});

  @override
  State<LibriScreen> createState() => _LibriScreenState();
}

class _LibriScreenState extends State<LibriScreen> {
  Icon icona = const Icon(Icons.search);
  Widget widgetRicerca = const Text('Libri');

  String risultato = '';
  List<Libro> libri = [];

  @override
  void initState() {
    cercaLibri('Oceano Mare');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widgetRicerca,
        actions: [
          IconButton(
              icon: icona,
              onPressed: (() {
                setState(() {
                  if (icona.icon == Icons.search) {
                    icona = const Icon(Icons.cancel);
                    widgetRicerca = TextField(
                        textInputAction: TextInputAction.search,
                        onSubmitted: (testoRicerca) => cercaLibri(testoRicerca),
                        style: TextStyle(color: Colors.white, fontSize: 20));
                  } else {
                    setState(() {
                      icona = const Icon(Icons.search);
                      widgetRicerca = const Text('Libri');
                    });
                  }
                });
              }))
        ],
      ),
      body: ListView.builder(
        itemCount: libri
            .length, // ListView.builder ha bisogno di sapere quanti elementi ci sono nella lista
        itemBuilder: (BuildContext context, int posizione) {
          // Costruiamo l'interfaccia della ListView, ed è una funzione che prendere il contesto corrente e la posizione all'interno della lista (tipo un ciclo)
          return Card(
            elevation: 2,
            child: ListTile(
              onTap: () {
                MaterialPageRoute route = MaterialPageRoute(
                    builder: (_) => LibroScreen(libri[posizione]));
                Navigator.push(context, route);
              },
              leading: (libri[posizione].immagineCopertirna != ''
                  ? Image.network(libri[posizione].immagineCopertirna)
                  : const FlutterLogo()),
              title: Text(libri[posizione].titolo),
              subtitle: Text(libri[posizione].autori),
            ),
          );
        },
      ),
    );
  }

  Future cercaLibri(String ricerca) async {
    const dominio = 'www.googleapis.com';
    const percorso = '/books/v1/volumes';
    Map<String, dynamic> parametri = {'q': ricerca};
    final Uri url = Uri.https(dominio, percorso, parametri);

    try {
      http.get(url).then((res) {
        final resJson = json.decode(res.body); // Decodifico il body in json
        final libriMap = resJson['items']; // il body contiene un campo Items
        libri = libriMap
            .map<Libro>((mappa) => Libro.fromMap(mappa))
            .toList(); // Per ogni elemento dell'array prendo mappa e costruisco un Libro e alla fine trasformo tutto in una List.
        setState(() {
          risultato = res.body;
        });
      });
      setState(() {
        risultato = 'Richiesta in corso';
      });
    } catch (e) {
      setState(() {
        risultato = '';
      });
    }
  }
}
