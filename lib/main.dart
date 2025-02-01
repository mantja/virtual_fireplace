import 'package:flutter/material.dart';
import 'fire_widget.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(FireplaceApp());
}

class FireplaceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FireplaceScreen(),
    );
  }
}

class FireplaceScreen extends StatefulWidget {
  @override
  _FireplaceScreenState createState() => _FireplaceScreenState();
}

class _FireplaceScreenState extends State<FireplaceScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playFireSound();
  }

  void _playFireSound() async {
    await _audioPlayer.play(AssetSource('fire_sound.mp3')); // Lisää tämä assets-kansioon
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Toistetaan ääni jatkuvasti
  }

  void _onTap() {
    // Esimerkkinä: liekin voimakkuuden muuttaminen (laajennettavissa)
    setState(() {
      print("Tuli voimistuu!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTap, // Kosketus tapahtuma
        child: Stack(
          children: [
            FireWidget(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Koske näyttöä lisätäksesi puuta!",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}