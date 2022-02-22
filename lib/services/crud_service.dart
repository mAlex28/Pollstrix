import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class CrudService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  _post(
      {required String title,
      required List<String> choices,
      required Timestamp createdTime}) async {
    try {
      final currentUser = await AuthenticationService().getCurrentUID();

      await _firebaseFirestore.collection('polls').doc().set({
        'uid': currentUser,
        'title': title,
        'choices': choices,
        'createdAt': createdTime
      });
    } catch (e) {
      return e;
    }
  }

  _delete() {}
}
