import 'package:flutter/material.dart';
import 'package:flutter_alquran_app/core/constants/colors.dart';

import '../../../core/components/spaces.dart';

class NavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isTablet;

  const NavItem({
    required this.iconPath,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return isTablet
        ? InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: ColoredBox(
                color:
                    isActive
                        ? AppColors.disabled.withOpacity(0.25)
                        : Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 25.0,
                        height: 25.0,
                        child: Image.asset(
                          iconPath,
                          color:
                              isActive ? AppColors.white : AppColors.disabled,
                        ),
                      ),
                      // ColorFilter: ColorFilter.mode(isActive ? AppColors.white : AppColors.disabled,
                      //  BlendMode.srcIn)),)
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        : InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32.0,
                height: 32.0,
                child: Image.asset(
                  iconPath,
                  color: isActive ? AppColors.secondary : AppColors.white,
                ),
              ),
              const SpaceHeight(4.0),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isActive ? AppColors.secondary : AppColors.white,
                ),
              ),
            ],
          ),
        );
  }
}
