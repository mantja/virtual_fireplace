import 'package:flutter/material.dart';
import 'dart:math';
import 'package:virtual_fireplace/microphone_listener.dart';


class FireWidget extends StatefulWidget {
  @override
  _FireWidgetState createState() => _FireWidgetState();
}

class _FireWidgetState extends State<FireWidget> with SingleTickerProviderStateMixin {
  double _flameSize = 2.0;
  double _fuelLevel = 1.0;
  bool _isBurning = true;
  late AnimationController _animationController;
  final MicrophoneListener _micListener = MicrophoneListener();

  void _addWood() {
    setState(() {
      _fuelLevel += 0.3;
      if (_fuelLevel > 1.0) _fuelLevel = 1.0;
      _isBurning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _addWood,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/fireplace_background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: Container(
              width: 220,
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                color: Colors.black,
              ),
              child: FractionallySizedBox(
                widthFactor: _fuelLevel > 0 ? _fuelLevel : 0.01,
                alignment: Alignment.centerLeft,
                child: Container(
                  color: Colors.orange,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                painter: FirePainter(_flameSize, _isBurning, _fuelLevel),
                size: Size(400, 300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
void initState() {
  super.initState();

  _micListener.onVolumeChange = (volume) {
    if (volume > 30.0) { // 🔥 Jos äänenvoimakkuus on korkea, kasvatetaan hetkellisesti liekkiä
      _increaseFlame();
    }
  };

  _micListener.initializeRecorder(); // Käynnistetään mikrofoni

  _animationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 1300),
    lowerBound: 0.9,
    upperBound: 1.1,
  )..addListener(() {
      setState(() {
        _flameSize = 2.0 * _animationController.value;
      });
    });

  _animationController.repeat(reverse: true);
  _startFuelConsumption();
}

// ✅ Siirretty initState:n ulkopuolelle
void _increaseFlame() {
  setState(() {
    _flameSize += 1.0; // Liekin kasvu
    if (_flameSize > 5.0) _flameSize = 5.0; // Maksimikoko
  });

  Future.delayed(Duration(seconds: 1), () {
    setState(() {
      _flameSize = 2.0; // Palautetaan alkuperäiseen kokoon
    });
  });
}

  



  @override
  void dispose() {
    _micListener.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startFuelConsumption() {
    Future.delayed(Duration(seconds: 1), () {
      if (_fuelLevel > 0) {
        setState(() {
          _fuelLevel -= 0.02;
          if (_fuelLevel <= 0) {
            _fuelLevel = 0;
            _isBurning = false;
          }
        });
        _startFuelConsumption();
      }
    });
  }
}

class FirePainter extends CustomPainter {
  final double flameSize;
  final bool isBurning;
  final double fuelLevel;
  final Random _random = Random();

  FirePainter(this.flameSize, this.isBurning, this.fuelLevel);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isBurning) return;

    canvas.save();
    canvas.translate(size.width / 2, size.height - 40); // liekin sijainti korkeussuunnassa

    final Paint paint = Paint()..style = PaintingStyle.fill;

    int flames = 18; // 🔥 Määrä liekkejä vierekkäin
    double flameWidth = 12; // Jokaisen liekin leveys
    double baseHeight = 0.1 + (fuelLevel * 0.45); // 🔥 Liekki muuttuu korkeammaksi polttoaineen mukaan

    for (int i = 0; i < flames; i++) {
      double flameOffset = (i - flames / 2) * flameWidth; // 🔥 Jakaa liekit vaakasuunnassa

      // 🔥 Reunaliekit ovat matalampia, keskellä korkeampia
      double heightModifier = baseHeight * (1 - pow((i / (flames - 1) - 0.5).abs() * 2, 2));

      canvas.save();
      canvas.translate(flameOffset, 0);
      canvas.scale(flameSize * 0.4, flameSize * heightModifier);

      for (int j = 0; j < 60; j++) { // 🔥 Jokainen liekki koostuu omista partikkeleistaan
        double x = _random.nextDouble() * 10 - 5; // 🔥 Kapeampi leviäminen
        double y = -_random.nextDouble() * 120 - (sin(DateTime.now().millisecondsSinceEpoch / 1000.0 * 2 + j) * 8);
        double width = _random.nextDouble() * 5.0 + 2.0; // 🔥 Liekin paksuus
        double height = width * 2.5; // 🔥 Soikio venyy pystysuunnassa

        // 🔥 Väri haalistuu polttoaineen laskiessa
        Color baseColor = fuelLevel > 0.2 ? Colors.deepOrange : Colors.red.withOpacity(0.5);
        Color fadeColor = fuelLevel > 0.2 ? Colors.yellow : Colors.orange.withOpacity(0.4);

        paint.color = Color.lerp(
          baseColor,
          fadeColor,
          _random.nextDouble(),
        )!.withOpacity(0.75);

        // 🔥 Piirretään soikio liekille
        Rect ovalRect = Rect.fromCenter(
          center: Offset(x, y),
          width: width,
          height: height,
        );

        canvas.drawOval(ovalRect, paint);
      }

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}