import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/subject_model.dart';

class SubjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSubject(SubjectModel subject) async {
    await _firestore.collection('subjects').add(subject.toMap());
  }

  Future<void> updateSubject(SubjectModel subject) async {
    await _firestore
        .collection('subjects')
        .doc(subject.id)
        .update(subject.toMap());
  }

  Future<void> deleteSubject(String subjectId) async {
    await _firestore.collection('subjects').doc(subjectId).delete();
  }

  Stream<List<SubjectModel>> getSubjects(String userId) {
    return _firestore
        .collection('subjects')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SubjectModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}