import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:recylce_app/services/database.dart';
import 'package:recylce_app/services/shared_pref.dart';
import 'package:recylce_app/services/widget_support.dart';

class Points extends StatefulWidget {
  const Points({super.key});

  @override
  State<Points> createState() => _PointsState();
}

class _PointsState extends State<Points> {
  String? id, mypoints, name;
  Stream<QuerySnapshot>? pointsStream;

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    name = await SharedPreferenceHelper().getUserName();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    mypoints = await getUserPoints(id!);

    pointsStream = await Databasemethods().getUserTransaction(id!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Future<String?> getUserPoints(String docId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        String userPoints = docSnapshot.get('Points');
        return userPoints;
      } else {
        print('No such document!');
        return null;
      }
    } catch (e) {
      print('Error fetching userpoints: $e');
      return null;
    }
  }

  // ---------------- TRANSACTION LIST ----------------
  Widget allAprovals() {
    return StreamBuilder<QuerySnapshot>(
      stream: pointsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No transactions yet",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];

            final String date = ds["Date"] ?? "";
            final String pts = ds["Points"] ?? "0";
            final String status = ds["Status"] ?? "";

            final bool approved = status == "Approved";

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // Date badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          date,
                          textAlign: TextAlign.center,
                          style: AppWidget.whiteTextStyle(14),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Redeem points",
                            style: AppWidget.normalTextStyle(16),
                          ),
                          const SizedBox(height: 2),
                          Text("$pts pts", style: AppWidget.greenTextStyle(20)),
                        ],
                      ),

                      const Spacer(),

                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: approved
                              ? Colors.green
                              : const Color.fromARGB(159, 254, 78, 78),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe8f5e9), // 💚 soft green
      body: mypoints == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ---------- TOP TITLE ----------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Text("Rewards", style: AppWidget.headlineTextStyle(24)),
                        const Spacer(),
                        const Icon(
                          Icons.stars_rounded,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------- MAIN POINTS CARD ----------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                "asset/images/point.png",
                                height: 80,
                                width: 70,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Points available",
                                  style: AppWidget.normalTextStyle(
                                    16,
                                  ).copyWith(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mypoints.toString(),
                                  style: AppWidget.greenTextStyle(36),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Collect more by recycling with TrashME",
                                  style: AppWidget.normalTextStyle(
                                    11,
                                  ).copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---------- REDEEM BUTTON ----------
                  GestureDetector(
                    onTap: () => openBox(context),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 52,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Redeem points",
                            style: AppWidget.whiteTextStyle(18),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---------- TRANSACTION HISTORY ----------
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "History",
                                  style: AppWidget.normalTextStyle(20),
                                ),
                                Text(
                                  "Recent transactions",
                                  style: AppWidget.normalTextStyle(
                                    12,
                                  ).copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(child: allAprovals()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ----------------- REDEEM DIALOG -----------------
  Future<void> openBox(BuildContext context) async {
    final TextEditingController pointsController = TextEditingController();
    final TextEditingController upiController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: size.width * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          height: 28,
                          width: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDEDED),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Redeem Points",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    "Add Points",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),

                  _inputBox(
                    pointsController,
                    "Enter points to redeem",
                    keyboard: TextInputType.number,
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "Add IBAN",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),

                  _inputBox(upiController, "Enter your IBAN"),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () async {
                        final points = pointsController.text.trim();
                        final upi = upiController.text.trim();

                        if (points.isNotEmpty &&
                            upi.isNotEmpty &&
                            mypoints != null &&
                            int.parse(mypoints!) >= int.parse(points)) {
                          DateTime now = DateTime.now();
                          String formattedDate = DateFormat(
                            'd MMM',
                          ).format(now);

                          int updatedPoints =
                              int.parse(mypoints!) - int.parse(points);

                          await Databasemethods().updateUserPoints(
                            id!,
                            updatedPoints.toString(),
                          );

                          Map<String, dynamic> redeemMap = {
                            "Name": name,
                            "Points": points,
                            "UPI": upi,
                            "Status": "Pending",
                            "Date": formattedDate,
                            "UserId": id,
                          };

                          String redeemId = randomAlphaNumeric(10);

                          await Databasemethods().addUserRedeemPoints(
                            redeemMap,
                            id!,
                            redeemId,
                          );

                          await Databasemethods().addAdminRedeemRequests(
                            redeemMap,
                            redeemId,
                          );

                          mypoints = await getUserPoints(id!);
                          setState(() {});
                        }

                        Navigator.of(ctx).pop();
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _inputBox(
    TextEditingController controller,
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
