import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recylce_app/pages/login.dart';
import 'package:recylce_app/services/shared_pref.dart';
import 'package:recylce_app/services/widget_support.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? id;
  String? name;
  String? email;
  String? imageUrl;
  String? points;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      id = await SharedPreferenceHelper().getUserId();
      name = await SharedPreferenceHelper().getUserName();
      email = await SharedPreferenceHelper().getUserEmail();
      imageUrl = await SharedPreferenceHelper().getUserImage();

      if (id != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .get();
        if (snap.exists) {
          points = snap.data()?['Points']?.toString();
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const logIn()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to logout",
            style: AppWidget.whiteTextStyle(14),
          ),
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Delete account?",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text(
            "This will permanently remove your account, points and history. "
            "This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop(); // close dialog

                try {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // Delete Firestore user document
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .delete();

                    // Delete auth user
                    await user.delete();
                  }

                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const logIn()),
                    (route) => false,
                  );
                } catch (e) {
                  print("Error deleting account: $e");
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        "Could not delete account. You may need to login again.",
                        style: AppWidget.whiteTextStyle(14),
                      ),
                    ),
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // -------- TOP BAR --------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            "Profile",
                            style: AppWidget.headlineTextStyle(24),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.person_outline_rounded,
                            color: Colors.green[700],
                            size: 28,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // -------- HEADER CARD --------
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
                              // Avatar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child:
                                    imageUrl != null &&
                                        imageUrl!.startsWith("http")
                                    ? Image.network(
                                        imageUrl!,
                                        height: 62,
                                        width: 62,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "asset/images/boy.png",
                                        height: 62,
                                        width: 62,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Name, email, points
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name ?? "User",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email ?? "",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.stars_rounded,
                                            color: Colors.yellow,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${points ?? "0"} pts",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
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

                    const SizedBox(height: 24),

                    // -------- INFO CARD --------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Account details",
                                style: AppWidget.normalTextStyle(
                                  18,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                icon: Icons.person_outline,
                                label: "Name",
                                value: name ?? "-",
                              ),
                              const Divider(height: 20),
                              _buildInfoRow(
                                icon: Icons.email_outlined,
                                label: "Email",
                                value: email ?? "-",
                              ),
                              const Divider(height: 20),
                              _buildInfoRow(
                                icon: Icons.badge_outlined,
                                label: "User ID",
                                value: id ?? "-",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // -------- ACTIONS CARD --------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              // Logout
                              ListTile(
                                leading: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.green,
                                ),
                                title: const Text(
                                  "Log out",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Sign out from this device",
                                  style: TextStyle(fontSize: 12),
                                ),
                                onTap: _logout,
                              ),
                              const Divider(height: 12),
                              // Delete account
                              ListTile(
                                leading: const Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  "Delete account",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Permanently remove your data",
                                  style: TextStyle(fontSize: 12),
                                ),
                                onTap: _deleteAccount,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
