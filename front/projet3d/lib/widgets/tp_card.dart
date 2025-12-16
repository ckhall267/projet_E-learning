import 'package:flutter/material.dart';
import '../models/practical_work.dart';

class TPCard extends StatelessWidget {
  final PracticalWork tp;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TPCard({
    super.key,
    required this.tp,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec statut et catégorie
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tp.status == TPStatus.published
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: tp.status == TPStatus.published
                        ? Colors.green
                        : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Text(
                  tp.statusText,
                  style: TextStyle(
                    color: tp.status == TPStatus.published
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Catégorie
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF23B8C0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF23B8C0),
                    width: 1,
                  ),
                ),
                child: Text(
                  tp.categoryText,
                  style: const TextStyle(
                    color: Color(0xFF23B8C0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Titre
          Text(
            tp.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            tp.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Informations (Durée et Étudiants)
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF23B8C0),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Durée: ${tp.duration}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    color: Color(0xFF23B8C0),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Étudiants: ${tp.studentCount}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Bouton Voir
              ElevatedButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Voir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF23B8C0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // Bouton Modifier
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF23B8C0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ],
              // Bouton Supprimer
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

