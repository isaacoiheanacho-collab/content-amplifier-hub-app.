import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;

  const ProfileAvatar({super.key, this.radius = 20, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null ? const Icon(Icons.person) : null,
    );
  }
}