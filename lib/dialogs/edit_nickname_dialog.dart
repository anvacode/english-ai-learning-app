import 'package:flutter/material.dart';

/// Diálogo para editar el nickname del usuario.
/// 
/// Muestra un TextField con el nickname actual y botones
/// para guardar o cancelar. Incluye validación.
class EditNicknameDialog extends StatefulWidget {
  final String currentNickname;

  const EditNicknameDialog({
    super.key,
    required this.currentNickname,
  });

  @override
  State<EditNicknameDialog> createState() => _EditNicknameDialogState();

  /// Muestra el diálogo y retorna el nuevo nickname si se guardó.
  static Future<String?> show(BuildContext context, String currentNickname) {
    return showDialog<String>(
      context: context,
      builder: (context) => EditNicknameDialog(
        currentNickname: currentNickname,
      ),
    );
  }
}

class _EditNicknameDialogState extends State<EditNicknameDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    final nickname = _controller.text.trim();

    // Validación: no vacío
    if (nickname.isEmpty) {
      setState(() {
        _errorText = 'El nickname no puede estar vacío';
      });
      return;
    }

    // Validación: máximo 20 caracteres
    if (nickname.length > 20) {
      setState(() {
        _errorText = 'El nickname no puede tener más de 20 caracteres';
      });
      return;
    }

    // Si es válido, cerrar el diálogo y retornar el nuevo nickname
    Navigator.of(context).pop(nickname);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Nickname'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 20,
            decoration: InputDecoration(
              labelText: 'Nickname',
              hintText: 'Ingresa tu nickname',
              errorText: _errorText,
              border: const OutlineInputBorder(),
              counterText: '${_controller.text.length}/20',
            ),
            onChanged: (value) {
              // Limpiar error cuando el usuario empiece a escribir
              if (_errorText != null) {
                setState(() {
                  _errorText = null;
                });
              }
            },
            onSubmitted: (_) => _validateAndSave(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _validateAndSave,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
