import 'dart:convert';
import 'package:flutter/material.dart';

/// Converte o campo `fotoPerfil` guardado no Firestore num ImageProvider —
/// sem Firebase Storage (que exige o plano pago Blaze), a foto é salva como
/// base64 direto no documento do usuário. Esse helper decide sozinho se o
/// valor é uma imagem embutida (`data:image/...;base64,...`) ou uma URL de
/// verdade (compatibilidade com qualquer foto antiga que ainda use Storage).
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
