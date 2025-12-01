import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recylce_app/pages/upload_item.dart';
import 'package:recylce_app/services/database.dart';
import 'package:recylce_app/services/shared_pref.dart';
import 'package:recylce_app/services/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? id, name, imageUrl;
  Stream<QuerySnapshot>? pendingStream;

  Future<void> getthesharedPef() async {
    id = await SharedPreferenceHelper().getUserId();
    name = await SharedPreferenceHelper().getUserName();
    imageUrl = await SharedPreferenceHelper().getUserImage(); // ✅ load image
    setState(() {});
  }

  Future<void> ontheload() async {
    await getthesharedPef();
    if (id != null) {
      pendingStream = await Databasemethods().getUserPendingRequests(id!);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  // same helper you used in admin page
  Future<String?> getUserPoints(String docId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.get('Points').toString();
      } else {
        print('No such document!');
        return null;
      }
    } catch (e) {
      print('Error fetching userpoints: $e');
      return null;
    }
  }

  // ---------- PENDING REQUESTS LIST ----------
  Widget allAprovals() {
    return StreamBuilder<QuerySnapshot>(
      stream: pendingStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No pending requests",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];

            final String? imageUrl = ds["Image"];
            final String name = (ds["Name"] ?? "").toString();
            final String address = (ds["Address"] ?? "").toString();
            final String quantity = (ds["Quantity"] ?? "").toString();
            final String userId = (ds["UserId"] ?? "").toString();
            final String category = (ds["Category"] ?? "").toString();

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFF1F6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: 85,
                            width: 85,
                            child:
                                (imageUrl != null &&
                                    imageUrl.toString().startsWith("http"))
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // TEXT + BUTTON
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // NAME + PENDING CHIP
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: AppWidget.headlineTextStyle(16),
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
                                        color: Colors.orange.shade400,
                                        width: 0.9,
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 14,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Pending",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // ADDRESS
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      address,
                                      style: AppWidget.normalTextStyle(14),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // QUANTITY + CATEGORY
                              Row(
                                children: [
                                  const Icon(
                                    Icons.inventory_2,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "${quantity} pcs • $category",
                                      style: AppWidget.normalTextStyle(14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // APPROVE BUTTON (same logic)
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () async {
                                    try {
                                      String? userpoints = await getUserPoints(
                                        userId,
                                      );
                                      int currentPoints =
                                          int.tryParse(userpoints ?? "0") ?? 0;

                                      int updatedpoints = currentPoints + 100;

                                      await Databasemethods().updateUserPoints(
                                        userId,
                                        updatedpoints.toString(),
                                      );

                                      await Databasemethods()
                                          .updateAdminRequest(ds.id);

                                      try {
                                        await Databasemethods()
                                            .updateUserRequest(userId, ds.id);
                                      } catch (e) {
                                        print(
                                          "Warning: failed to update user item status: $e",
                                        );
                                      }

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                            "Request approved",
                                            style: AppWidget.whiteTextStyle(16),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print(
                                        "Fatal error approving request: $e",
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "Something went wrong",
                                            style: AppWidget.whiteTextStyle(16),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 26,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF43A047),
                                          Color(0xFF2E7D32),
                                        ],
                                      ),
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
              ),
            );
          },
        );
      },
    );
  }

  // ---------- COMING SOON DIALOG ----------
  void _showComingSoonDialog(BuildContext context, String label) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Coming soon",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            "$label collection will be available in a future update.\n\nFor now, you can upload Plastic waste. 🚮",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFececf8),
      body: name == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // -------- TOP GREETING CARD --------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Hello,",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      name ?? "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "Thanks for keeping the city clean 🌍",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ✅ Google profile image or fallback
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child:
                                    (imageUrl != null &&
                                        imageUrl!.startsWith("http"))
                                    ? Image.network(
                                        imageUrl!,
                                        height: 54,
                                        width: 54,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) {
                                          return Image.asset(
                                            'asset/images/boy.png',
                                            height: 54,
                                            width: 54,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'asset/images/boy.png',
                                        height: 54,
                                        width: 54,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // -------- HERO IMAGE --------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'asset/images/home1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // -------- CATEGORIES TITLE --------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categories',
                            style: AppWidget.headlineTextStyle(22),
                          ),
                          Text(
                            'Select waste type',
                            style: AppWidget.normalTextStyle(
                              12,
                            ).copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // -------- CATEGORIES SCROLLER --------
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20, right: 10),
                        children: [
                          // ✅ Plastic → UploadItem
                          _buildCategoryCard(
                            context: context,
                            label: "Plastic",
                            asset: 'asset/images/plastic.png',
                            onTap: () {
                              if (id == null) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UploadItem(category: "Plastic", id: id!),
                                ),
                              );
                            },
                          ),

                          // ✅ Paper → coming soon dialog
                          _buildCategoryCard(
                            context: context,
                            label: "Paper",
                            asset: 'asset/images/paper.png',
                            onTap: () =>
                                _showComingSoonDialog(context, "Paper"),
                          ),

                          // ✅ Battery → coming soon dialog
                          _buildCategoryCard(
                            context: context,
                            label: "Battery",
                            asset: 'asset/images/battery.png',
                            onTap: () =>
                                _showComingSoonDialog(context, "Battery"),
                          ),

                          // ✅ Glass → coming soon dialog
                          _buildCategoryCard(
                            context: context,
                            label: "Glass",
                            asset: 'asset/images/glass.png',
                            onTap: () =>
                                _showComingSoonDialog(context, "Glass"),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // -------- PENDING REQUESTS HEADER --------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pending requests',
                            style: AppWidget.headlineTextStyle(22),
                          ),
                          Text(
                            'Live status',
                            style: AppWidget.normalTextStyle(
                              12,
                            ).copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // -------- PENDING LIST --------
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: allAprovals(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String label,
    required String asset,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 90,
              width: 90,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.6),
                  width: 1.2,
                ),
              ),
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppWidget.normalTextStyle(14)),
          ],
        ),
      ),
    );
  }
}
