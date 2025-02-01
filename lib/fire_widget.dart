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
              size: Size(600, 700),
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
    canvas.save(); // Tallenna nykyinen tila

    // **Tarkempi sijainti:** Säädetään liekkiä sopimaan takan sisään
    canvas.translate(size.width / 2, size.height - 200); // Siirretään ylemmäs
    canvas.scale(flameSize * 0.9, flameSize * 0.6); // Tasapainotetaan liekin kokoa

    final Paint paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 550; i++) { 
  double x = _random.nextDouble() * 60 - 30; 
  double y = -_random.nextDouble() * 200 - (sin(time + i) * 15); 
  double radius = _random.nextDouble() * 1.5 + 0.6; // **Pienemmät partikkelit**

  paint.color = Color.lerp(
      _random.nextBool() ? Colors.deepOrange : Colors.red,
      Colors.yellow,
      _random.nextDouble()
    )!.withOpacity(0.75);

  canvas.drawCircle(Offset(x, y), radius, paint);
}

    canvas.restore(); // Palauta alkuperäinen tila
}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
  