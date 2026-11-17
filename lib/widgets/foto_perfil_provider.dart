import 'dart:convert';
import 'package:flutter/material.dart';

ImageProvider? fotoPerfilProvider(String? fotoPerfil) {
  if (fotoPerfil == null || fotoPerfil.isEmpty) return null;
  if (fotoPerfil.startsWith('data:image')) {
    final base64Str = fotoPerfil.split(',').last;
    try {
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(fotoPerfil);
}
