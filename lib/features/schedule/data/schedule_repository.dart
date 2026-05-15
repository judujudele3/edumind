import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/schedule_model.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSlot(ScheduleModel slot) async {
    await _firestore.collection('schedule').add(slot.toMap());
  }

  Future<void> deleteSlot(String slotId) async {
    await _firestore.collection('schedule').doc(slotId).delete();
  }

  Stream<List<ScheduleModel>> getSchedule(String userId) {
    return _firestore
        .collection('schedule')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ScheduleModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}