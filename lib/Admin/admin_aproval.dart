import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recylce_app/services/database.dart';
import 'package:recylce_app/services/widget_support.dart';

class AdminAproval extends StatefulWidget {
  const AdminAproval({super.key});

  @override
  State<AdminAproval> createState() => _AdminAprovalState();
}

class _AdminAprovalState extends State<AdminAproval> {
  Stream<QuerySnapshot>? approvalStream;

  getonntheload() async {
    approvalStream = await Databasemethods().getAdminApproval();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getonntheload();
  }

  Future<String?> getUserPoints(String docId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();
      if (docSnapshot.exists) return docSnapshot.get('Points');
      return null;
    } catch (e) {
      return null;
    }
  }

  // ---------------- LIST UI ----------------
  Widget allAprovals() {
    return StreamBuilder<QuerySnapshot>(
      stream: approvalStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No pending approval requests",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];

            final imageUrl = (ds["Image"] ?? "").toString();
            final name = (ds["Name"] ?? "").toString();
            final address = (ds["Address"] ?? "").toString();
            final quantity = (ds["Quantity"] ?? "").toString();
            final userId = (ds["UserId"] ?? "").toString();

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              child: Material(
                elevation: 5,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 90,
                          width: 90,
                          child: (imageUrl.startsWith("http"))
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NAME + STATUS
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700, // BOLDER
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    "Pending",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // ADDRESS
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500, // Stronger
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // QUANTITY
                            Row(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_rounded,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Quantity: $quantity",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600, // BOLDER
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // APPROVE BUTTON
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () async {
                                  try {
                                    String? p = await getUserPoints(userId);
                                    int updated =
                                        (int.tryParse(p ?? "0") ?? 0) + 100;

                                    await Databasemethods().updateUserPoints(
                                      userId,
                                      "$updated",
                                    );

                                    await Databasemethods().updateAdminRequest(
                                      ds.id,
                                    );

                                    await Databasemethods().updateUserRequest(
                                      userId,
                                      ds.id,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                          "Request approved",
                                          style: AppWidget.whiteTextStyle(16),
                                        ),
                                      ),
                                    );
                                  } catch (_) {}
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 26,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF43A047),
                                        Color(0xFF2E7D32),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "Approve",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700, // BOLDER
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- MAIN PAGE ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Column(
          children: [
            // ---- TOP BAR ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  // Back button
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(60),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(60),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Titles
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Admin Approval",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800, // BOLDER
                          letterSpacing: 0.3,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Review waste submissions",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ---- WHITE CONTENT AREA ----
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: allAprovals(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
