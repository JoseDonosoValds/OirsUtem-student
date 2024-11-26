import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/mis_solicitudes.dart'; // Import the new Solicitudes screen
// Import additional screens as needed.

class Navbar extends StatelessWidget {
  final int currentIndex;

  const Navbar({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    // Si el índice seleccionado es el mismo que el índice actual, no hacer nada
    if (index == currentIndex) {
      return;
    }

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeScreen();
        break;
      case 1:
        nextScreen = const MisSolicitudesScreen();
        break;
      case 2:
        // Placeholder for Settings or Profile Screen
        nextScreen = const HomeScreen(); // Temporalmente redirige a Home
        break;
      default:
        return;
    }

    // Navegar con animación de barrido de derecha a izquierda
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Empieza desde la derecha (1.0 en el eje X)
          const end = Offset.zero; // Termina en su posición original
          const curve = Curves.easeInOut; // Curva de animación suave

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300), // Duración de la animación
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.request_page),
              label: 'Solicitudes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
