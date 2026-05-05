import 'package:flutter/material.dart';
import '../../../models/genre.dart';

class GenreChip extends StatelessWidget {
  final Genre genre;
  final bool selected;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.genre,
    this.selected = false,
    this.onTap,
  });

  Color get _color {
    if (genre.color != null) {
      try {
        return Color(int.parse(genre.color!.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return const Color(0xFF9B72CF);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? _color.withValues(alpha: 0.3)
              : _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _color.withValues(alpha: 0.7)
                : _color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          genre.name,
          style: TextStyle(
            color: _color,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
