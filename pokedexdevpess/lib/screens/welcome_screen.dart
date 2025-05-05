import 'dart:math';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _topLeftSlide;
  late Animation<Offset> _bottomRightSlide;
  late Animation<double> _rotationAnimation; // Animación de rotación de 360 grados

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _topLeftSlide = Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, -1))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _bottomRightSlide = Tween<Offset>(begin: Offset(0, 0), end: Offset(1, 1))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Animación de rotación de 360 grados desde 90 grados inicial
    _rotationAnimation = Tween<double>(begin: pi / 2, end: 2 * pi + pi / 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              CustomPaint(
                size: Size(double.infinity, double.infinity),
                painter: DiagonalCurtainPainter(
                  topLeftSlide: _topLeftSlide,
                  bottomRightSlide: _bottomRightSlide,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        // Iniciar la animación de giro de 360 grados
                        _controller.forward().then((_) {
                          Future.delayed(const Duration(milliseconds: 200), () {
                            Navigator.pushReplacementNamed(context, '/regions');
                          });
                        });
                      },
                      child: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (_, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value, // Rotar desde 90 grados hasta 450 grados
                            child: child, // La imagen del botón
                          );
                        },
                        child: ClipOval(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              image: const DecorationImage(
                                image: AssetImage('assets/pokeball.png'), // Asegúrate de tener esta imagen
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(2, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DiagonalCurtainPainter extends CustomPainter {
  final Animation<Offset> topLeftSlide;
  final Animation<Offset> bottomRightSlide;

  DiagonalCurtainPainter({
    required this.topLeftSlide,
    required this.bottomRightSlide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dx1 = size.width * topLeftSlide.value.dx;
    final dy1 = size.height * topLeftSlide.value.dy;

    final dx2 = size.width * bottomRightSlide.value.dx;
    final dy2 = size.height * bottomRightSlide.value.dy;

    // Parte superior izquierda con degradado de amarillo a rojo
    final Rect leftRect = Rect.fromLTWH(0 + dx1, 0 + dy1, size.width, size.height);
    final Gradient yellowToRed = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.center,
      colors: [const Color.fromARGB(255, 194, 130, 66), const Color.fromARGB(255, 249, 241, 35)],
    );
    final Paint paintLeft = Paint()..shader = yellowToRed.createShader(leftRect);

    final Path pathLeft = Path()
      ..moveTo(0 + dx1, 0 + dy1)
      ..lineTo(size.width + dx1, 0 + dy1)
      ..lineTo(0 + dx1, size.height + dy1)
      ..close();

    // Parte inferior derecha con degradado de naranja a blanco
    final Rect rightRect = Rect.fromLTWH(0 + dx2, 0 + dy2, size.width, size.height);
    final Gradient orangeToWhite = LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.center,
      colors: [const Color.fromARGB(255, 255, 249, 64), const Color.fromARGB(255, 249, 160, 35)],
    );
    final Paint paintRight = Paint()..shader = orangeToWhite.createShader(rightRect);

    final Path pathRight = Path()
      ..moveTo(size.width + dx2, size.height + dy2)
      ..lineTo(size.width + dx2, 0 + dy2)
      ..lineTo(0 + dx2, size.height + dy2)
      ..close();

    canvas.drawPath(pathLeft, paintLeft);
    canvas.drawPath(pathRight, paintRight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
