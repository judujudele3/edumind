import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/schedule_provider.dart';
import '../../../shared/models/schedule_model.dart';
import '../../auth/providers/auth_provider.dart';

class AddSlotScreen extends ConsumerStatefulWidget {
  const AddSlotScreen({super.key});

  @override
  ConsumerState<AddSlotScreen> createState() => _AddSlotScreenState();
}

class _AddSlotScreenState extends ConsumerState<AddSlotScreen> {
  final _subjectController = TextEditingController();
  String _selectedDay = 'Lundi';
  String _startTime = '08:00';
  String _endTime = '10:00';
  String _selectedColor = '#6C63FF';

  final List<String> _days = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'
  ];

  final List<Map<String, String>> _colors = [
    {'name': 'Violet', 'hex': '#6C63FF'},
    {'name': 'Bleu', 'hex': '#2196F3'},
    {'name': 'Vert', 'hex': '#4CAF50'},
    {'name': 'Orange', 'hex': '#FF9800'},
    {'name': 'Rouge', 'hex': '#F44336'},
    {'name': 'Rose', 'hex': '#E91E63'},
  ];

  Color _colorFromHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = TimeOfDay(
      hour: int.parse(isStart
          ? _startTime.split(':')[0]
          : _endTime.split(':')[0]),
      minute: int.parse(isStart
          ? _startTime.split(':')[1]
          : _endTime.split(':')[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _startTime = formatted;
        } else {
          _endTime = formatted;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom du cours est obligatoire')),
      );
      return;
    }

    final userId = ref.read(firebaseAuthProvider).currentUser?.uid ?? '';
    final slot = ScheduleModel(
      id: '',
      userId: userId,
      subject: _subjectController.text.trim(),
      day: _selectedDay,
      startTime: _startTime,
      endTime: _endTime,
      color: _selectedColor,
    );

    await ref.read(scheduleNotifierProvider.notifier).addSlot(slot);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(scheduleNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Créneau')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Nom du cours',
                prefixIcon: Icon(Icons.book_outlined),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Jour',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              items: _days
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDay = v!),
            ),
            const SizedBox(height: 24),
            const Text('Horaires',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Color(0xFF4CAF50)),
                          const SizedBox(width: 8),
                          Text(_startTime,
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('→',
                      style: TextStyle(fontSize: 20, color: Colors.grey)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(_endTime,
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Couleur',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _colors.map((c) {
                final isSelected = _selectedColor == c['hex'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedColor = c['hex']!),
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
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
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