import 'package:flutter/material.dart';
import 'package:flutter_alquran_app/core/components/spaces.dart';
import 'package:flutter_alquran_app/core/extensions/build_context_ext.dart';

import '../constants/colors.dart';

class MenuButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final bool isImage;
  final bool isIconImage;
  final double size;

  const MenuButton({
    super.key,
    required this.iconPath,
    required this.label,
    this.isActive = false,
    required this.onPressed,
    this.isImage = false,
    this.size = 120,
    this.isIconImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      child: Container(
        width: context.deviceWidth,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 20.0,
              blurStyle: BlurStyle.outer,
              spreadRadius: 0,
              color: AppColors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Column(
          children: [
            isIconImage
                ? Image.network(
                    iconPath,
                    width: 120,
                    height: 30,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    iconPath,
                    width: 120,
                    height: size,
                    fit: BoxFit.contain,
                  ),
            const SpaceHeight(10.0),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.white : AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
