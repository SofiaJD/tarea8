import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class Evento {
  String titulo;
  String fecha;
  String descripcion;
  String fotoUrl;
  String audioUrl;

  Evento({
    required this.titulo,
    required this.fecha,
    required this.descripcion,
    required this.fotoUrl,
    required this.audioUrl,
  });
}

class Delegado {
  String nombre;
  String apellido;
  String matricula;
  String fotoUrl;

  Delegado({
    required this.nombre,
    required this.apellido,
    required this.matricula,
    required this.fotoUrl,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Eventos',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Evento> eventos = [
    Evento(
      titulo: "Evento 1",
      fecha: "2024-04-05",
      descripcion: "Descripción del evento 1",
      fotoUrl: "url de la foto 1",
      audioUrl: "url del audio 1",
    ),
  ];

  final Delegado delegado = Delegado(
    nombre: "Sofía",
    apellido: "Jiménez Durán",
    matricula: "2022-0905",
    fotoUrl: "url de la foto del delegado",
  );

  void borrarRegistros(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registros borrados')));
    });
  }

  void agregarEvento(Evento evento) {
    setState(() {
      eventos.add(evento);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Eventos'),
      ),
      body: ListView.builder(
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(eventos[index].titulo),
            subtitle: Text(eventos[index].fecha),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleEventoPage(evento: eventos[index]),
                ),
              );
            },
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('assets/Foto.png'),
                  ),
                  Text(delegado.nombre),
                  Text(delegado.apellido),
                  Text(delegado.matricula),
                ],
              ),
            ),
            ListTile(
              title: Text('Borrar Registros'),
              onTap: () {
                borrarRegistros(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroEventoPage(
                onEventoAdded: agregarEvento,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class DetalleEventoPage extends StatefulWidget {
  final Evento evento;

  DetalleEventoPage({required this.evento});

  @override
  _DetalleEventoPageState createState() => _DetalleEventoPageState();
}

class _DetalleEventoPageState extends State<DetalleEventoPage> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        // isPlaying = audioPlayer.state == AudioPlayerState.PLAYING;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void playAudio(String url) async {
    await audioPlayer.play(url as Source);
  }

  void pauseAudio() async {
    await audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evento.titulo),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fecha: ${widget.evento.fecha}'),
          Text('Descripción: ${widget.evento.descripcion}'),
          Image.network(widget.evento.fotoUrl),
          SizedBox(height: 20),
          if (widget.evento.audioUrl != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (isPlaying) {
                      pauseAudio();
                    } else {
                      playAudio(widget.evento.audioUrl);
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class RegistroEventoPage extends StatefulWidget {
  final Function(Evento) onEventoAdded;

  RegistroEventoPage({required this.onEventoAdded});

  @override
  _RegistroEventoPageState createState() => _RegistroEventoPageState();
}

class _RegistroEventoPageState extends State<RegistroEventoPage> {
  TextEditingController tituloController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController fotoUrlController = TextEditingController();
  TextEditingController audioUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: fechaController,
              decoration: InputDecoration(labelText: 'Fecha'),
            ),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: fotoUrlController,
              decoration: InputDecoration(labelText: 'URL de la foto'),
            ),
            TextField(
              controller: audioUrlController,
              decoration: InputDecoration(labelText: 'URL del audio'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes guardar el nuevo evento utilizando los valores de los controladores
                Evento nuevoEvento = Evento(
                  titulo: tituloController.text,
                  fecha: fechaController.text,
                  descripcion: descripcionController.text,
                  fotoUrl: fotoUrlController.text,
                  audioUrl: audioUrlController.text,
                );
                // Llama a la función callback para notificar al HomePage sobre el nuevo evento
                widget.onEventoAdded(nuevoEvento);
                // Cierra la página de registro
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
