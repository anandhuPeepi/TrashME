import 'package:cloud_firestore/cloud_firestore.dart';

class Databasemethods {
  // ---------------- USERS ----------------

  Future addUserInfo(Map<String, dynamic> userInfoMap, String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap, SetOptions(merge: true));
  }

  Future addUserUploadItem(
    Map<String, dynamic> map,
    String userId,
    String itemId,
  ) async {
    map["Status"] = map["Status"] ?? "Pending";

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("items")
        .doc(itemId)
        .set(map);
  }

  // ---------------- ADMIN – ITEMS REQUEST ----------------

  Future addAdminItem(Map<String, dynamic> map, String id) async {
    map["Status"] = map["Status"] ?? "Pending";

    return FirebaseFirestore.instance.collection("Request").doc(id).set(map);
  }

  Future<Stream<QuerySnapshot>> getAdminApproval() async {
    return FirebaseFirestore.instance
        .collection("Request")
        .where("Status", isEqualTo: "Pending")
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getUserPendingRequests(String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("items")
        .where("Status", isEqualTo: "Pending")
        .snapshots();
  }

  Future updateAdminRequest(String id) async {
    return FirebaseFirestore.instance.collection("Request").doc(id).update({
      "Status": "Approved",
    });
  }

  Future updateUserRequest(String userId, String itemId) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("items")
        .doc(itemId)
        .update({"Status": "Approved"});
  }

  // ---------------- REDEEM SECTION ----------------

  Future<Stream<QuerySnapshot>> getAdminRedeemApproval() async {
    return FirebaseFirestore.instance
        .collection("Redeem")
        .where("Status", isEqualTo: "Pending")
        .snapshots();
  }

  Future updateAdminRedeemRequest(String redeemId) async {
    return FirebaseFirestore.instance.collection("Redeem").doc(redeemId).update(
      {"Status": "Approved"},
    );
  }

  Future updateUserRedeemRequest(String userId, String redeemId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Redeem")
        .doc(redeemId)
        .update({"Status": "Approved"});
  }

  // ---------------- POINTS ----------------

  Future updateUserPoints(String userId, String points) async {
    return FirebaseFirestore.instance.collection("users").doc(userId).update({
      "Points": points,
    });
  }

  Future<Stream<QuerySnapshot>> getUserTransaction(String userId) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Redeem")
        .orderBy("Date", descending: true)
        .snapshots();
  }

  Future addUserRedeemPoints(
    Map<String, dynamic> map,
    String userId,
    String redeemId,
  ) async {
    map["Status"] = map["Status"] ?? "Pending";

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Redeem")
        .doc(redeemId)
        .set(map);
  }

  Future addAdminRedeemRequests(
    Map<String, dynamic> map,
    String redeemId,
  ) async {
    map["Status"] = map["Status"] ?? "Pending";

    return FirebaseFirestore.instance
        .collection("Redeem")
        .doc(redeemId)
        .set(map);
  }

  // ---------------- LOGIN-SAFE USER CREATION ----------------
  //
  // Use this during Google login so that:
  // - New user  -> created with Points = "0"
  // - Existing  -> only updates Name/Email/Image, DOES NOT reset Points

  Future<void> createOrUpdateUserOnLogin({
    required String userId,
    required String name,
    required String email,
    String? imageUrl,
  }) async {
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    final doc = await userRef.get();

    if (!doc.exists) {
      // New user -> create with 0 points
      Map<String, dynamic> userInfo = {
        "Name": name,
        "Email": email,
        "Points": "0",
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        userInfo["Image"] = imageUrl;
      }

      await userRef.set(userInfo);
    } else {
      // Existing user -> DON'T touch Points
      Map<String, dynamic> updateInfo = {"Name": name, "Email": email};

      if (imageUrl != null && imageUrl.isNotEmpty) {
        updateInfo["Image"] = imageUrl;
      }

      await userRef.set(updateInfo, SetOptions(merge: true));
    }
  }
}
