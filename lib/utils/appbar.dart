import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/user_data.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          // Mostrar píldora temporal con el nombre del usuario
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userModel.displayName ?? 'Usuario',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black87,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: userModel.photoUrl != null
                ? NetworkImage(userModel.photoUrl!)
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
