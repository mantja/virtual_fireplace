import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

// Tämä piirtää yksinkertaisen nousevan liekkiefektin.
//
//

class FireWidget extends StatefulWidget {
  @override
  _FireWidgetState createState() => _FireWidgetState();
}

//class _FireWidgetState extends State<FireWidget> {
//  double _flameSize = 1.0;
class _FireWidgetState extends State<FireWidget> with SingleTickerProviderStateMixin {
  double _flameSize = 2.0;
  late AnimationController _animationController;

  

  void _increaseFlame() {
  setState(() {
    _flameSize += 1.0; // Suurempi kasvu
    if (_flameSize > 5.0) _flameSize = 5.0; // Maksimikoko
  });

  Future.delayed(Duration(seconds: 1), () {
    setState(() {
      _flameSize = 2.0; // Palautetaan alkuperäiseen kokoon
    });
  });
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _increaseFlame,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/fireplace_background.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: CustomPaint(
              painter: FirePainter(_flameSize),
              size: Size(600, 500),
            ),
          ),
        ],
      ),
    );
  }

  @override
void initState() {
  super.initState();
  
  _animationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 1300),
    lowerBound: 0.9, // Liekki ei kutistu liian pieneksi
    upperBound: 1.1, // Liekki kasvaa ja kutistuu
  )..addListener(() {
      setState(() {
        _flameSize = 2.0 * _animationController.value; // Liekki elää
      });
    });

  _animationController.repeat(reverse: true); // Käynnistä jatkuva animaatio edestakaisin
}

  @override
  void dispose() {
    _animationController.dispose(); // Vapauta resursseja
    super.dispose();
  }

}

class FirePainter extends CustomPainter {
  final double flameSize;
  final Random _random = Random();
  final double time = DateTime.now().millisecondsSinceEpoch / 1000.0; // Aika-animaatio

  FirePainter(this.flameSize);

  @override
void paint(Canvas canvas, Size size) {
    canvas.save();

    int flames = 18; // 🔥 18 vierekkäistä liekkikomponenttia
    double flameWidth = 12; // **Kapeampi yksittäinen liekki**
    double baseHeight = 0.1; // 🔥 **Liekki kokonaisuudessaan matalampi**

    for (int i = 0; i < flames; i++) {
      double flameOffset = (i - flames / 2) * flameWidth; // Jakaa liekit tasaisesti vaakasuunnassa
      
      // **Reunaliekit lähes olemattomia, keskellä korkeimmat**
      double edgeFactor = (i / (flames - 1) - 0.5).abs(); // 0 keskellä, ~0.5 reunoilla
      double heightModifier = baseHeight + (1 - edgeFactor) * 1.2; // Reunoilla matalampi
      
      if (edgeFactor > 0.45) { 
        heightModifier *= 0.4; // **Häivytetään lähes kokonaan reunoilta**
      } else if (edgeFactor > 0.3) {
        heightModifier *= 0.7; // **Vähennetään korkeutta asteittain**
      }
      
      canvas.save();
      canvas.translate(size.width / 2 + flameOffset, size.height - 100); // Keskitetään korkeussuunnassa. Miinus nostaa ylöspäin
      canvas.scale(flameSize * 0.9, flameSize * heightModifier); // **Skaalaus uusilla arvoilla**

      final Paint paint = Paint()..style = PaintingStyle.fill;

      for (int j = 0; j < 80; j++) { // Jokainen liekki sisältää omat partikkelinsa
        double x = _random.nextDouble() * 16 - 8; // **Kapeampi jakautuminen**
        double y = -_random.nextDouble() * 100 - (sin(time * 2 + j) * 6);
        double radius = _random.nextDouble() * 1.5 + 0.4; // 🔥 **Vielä pienemmät partikkelit**

        paint.color = Color.lerp(
            _random.nextBool() ? Colors.deepOrange : Colors.red,
            Colors.yellow,
            _random.nextDouble()
          )!.withOpacity(0.7 + _random.nextDouble() * 0.2); // **Pieni vaihtelu läpinäkyvyydessä**

        canvas.drawCircle(Offset(x, y), radius, paint);
      }

      canvas.restore();
    }

    canvas.restore();
}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
  