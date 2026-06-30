import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

enum AuthTypes {
  email(PoraColors.dark),
  phone(PoraColors.primaryTint),
  apple(PoraColors.inkInverse),
  google(PoraColors.primary),
  expansible(PoraColors.danger);
  
  // Final fields
  final Color themeColor;

  // Constant constructor
  const AuthTypes( this.themeColor);

}
