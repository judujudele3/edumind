import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/subject_provider.dart';
import '../../../shared/models/subject_model.dart';
import '../../auth/providers/auth_provider.dart';

class AddSubjectScreen extends ConsumerStatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  ConsumerState<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends ConsumerState<AddSubjectScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#6C63FF';

  final List<Map<String, String>> _colors = [
    {'name': 'Violet', 'hex': '#6C63FF'},
    {'name': 'Bleu', 'hex': '#2196F3'},
    {'name': 'Vert', 'hex': '#4CAF50'},
    {'name': 'Orange', 'hex': '#FF9800'},
    {'name': 'Rouge', 'hex': '#F44336'},
    {'name': 'Rose', 'hex': '#E91E63'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _colorFromHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom est obligatoire')),
      );
      return;
    }

    final userId = ref.read(firebaseAuthProvider).currentUser?.uid ?? '';
    final subject = SubjectModel(
      id: '',
      userId: userId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _selectedColor,
    );

    await ref.read(subjectNotifierProvider.notifier).addSubject(subject);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(subjectNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Matière')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la matière',
                prefixIcon: Icon(Icons.book_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Couleur',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _colors.map((c) {
                final isSelected = _selectedColor == c['hex'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c['hex']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _colorFromHex(c['hex']!),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _save,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}