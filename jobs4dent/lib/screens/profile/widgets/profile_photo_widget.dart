import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../services/profile_photo_upload_service.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final UserModel user;

  const ProfilePhotoWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.profilePhotoUrl != null
              ? NetworkImage(user.profilePhotoUrl!)
              : null,
          child: user.profilePhotoUrl == null
              ? const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => ProfilePhotoUploadService.showPhotoSelectionModal(context),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 