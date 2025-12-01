import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:recylce_app/services/database.dart';
import 'package:recylce_app/services/shared_pref.dart';
import 'package:recylce_app/services/widget_support.dart';

class UploadItem extends StatefulWidget {
  final String category;
  final String id;

  UploadItem({required this.category, required this.id});

  @override
  State<UploadItem> createState() => _UploadItemState();
}

class _UploadItemState extends State<UploadItem> {
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String? id, name;

  Future<void> getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    name = await SharedPreferenceHelper().getUserName();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getthesharedpref();
  }

  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<String> uploadImageAndGetUrl(String itemId) async {
    if (selectedImage == null) {
      throw Exception("No image selected");
    }

    final String fileName =
        '$itemId-${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = FirebaseStorage.instance
        .ref()
        .child('requestImages')
        .child(fileName);

    final uploadTask = ref.putFile(selectedImage!);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

    if (snapshot.state != TaskState.success) {
      throw Exception('Upload failed with state: ${snapshot.state}');
    }

    final String url = await ref.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            // ---------------- TOP BAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(60),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(60),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                  Text('Upload Item', style: AppWidget.normalTextStyle(24)),
                  const Spacer(),
                  // small category chip on the right
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.category_rounded,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- GREEN BODY ----------------
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color(0xFFe8f5e9), // 💚 light green background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --------- MAIN WHITE CARD (premium look) ---------
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // title inside card
                              Text(
                                "Pickup details",
                                style: AppWidget.headlineTextStyle(20),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Add a photo, address and quantity so we can collect your waste.",
                                style: AppWidget.normalTextStyle(
                                  13,
                                ).copyWith(color: Colors.grey[600]),
                              ),

                              const SizedBox(height: 20),

                              // ---------- IMAGE PICKER ----------
                              Center(
                                child: GestureDetector(
                                  onTap: getImage,
                                  child: Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Colors.green.shade400,
                                        width: 1.6,
                                      ),
                                    ),
                                    child: selectedImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Image.file(
                                              selectedImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.camera_alt_outlined,
                                                size: 34,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Tap to add photo",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ---------- ADDRESS ----------
                              const Text(
                                'Pickup address',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: TextField(
                                    controller: addresscontroller,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: const Icon(
                                        Icons.location_on,
                                        color: Colors.green,
                                        size: 25,
                                      ),
                                      hintText: "Enter the place to pick up",
                                      hintStyle: AppWidget.normalTextStyle(
                                        14,
                                      ).copyWith(color: Colors.grey[500]),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ---------- QUANTITY ----------
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: TextField(
                                    controller: quantitycontroller,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: const Icon(
                                        Icons.inventory_2,
                                        color: Colors.green,
                                        size: 25,
                                      ),
                                      hintText: "Enter quantity",
                                      hintStyle: AppWidget.normalTextStyle(
                                        14,
                                      ).copyWith(color: Colors.grey[500]),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ---------- UPLOAD BUTTON ----------
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    // 🔥 SAME BACKEND LOGIC AS BEFORE 🔥
                                    if (addresscontroller.text.trim().isEmpty ||
                                        quantitycontroller.text
                                            .trim()
                                            .isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "Please fill all fields",
                                            style: AppWidget.whiteTextStyle(16),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (selectedImage == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "Please select an image",
                                            style: AppWidget.whiteTextStyle(16),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    String itemid = randomAlphaNumeric(10);

                                    try {
                                      String downloadUrl =
                                          await uploadImageAndGetUrl(itemid);

                                      Map<String, dynamic> addItem = {
                                        "Image": downloadUrl,
                                        "Address": addresscontroller.text
                                            .trim(),
                                        "Quantity": quantitycontroller.text
                                            .trim(),
                                        "UserId": id,
                                        "Name": name,
                                        "Status": "Pending",
                                        "Category": widget.category,
                                      };

                                      await Databasemethods().addUserUploadItem(
                                        addItem,
                                        id!,
                                        itemid,
                                      );

                                      await Databasemethods().addAdminItem(
                                        addItem,
                                        itemid,
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                            "Item uploaded successfully",
                                            style: AppWidget.whiteTextStyle(18),
                                          ),
                                        ),
                                      );

                                      setState(() {
                                        addresscontroller.clear();
                                        quantitycontroller.clear();
                                        selectedImage = null;
                                      });
                                    } catch (e) {
                                      print("❌ Error in upload flow: $e");
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "Error uploading image",
                                            style: AppWidget.whiteTextStyle(16),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 52,
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(26),
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
                                        "Upload request",
                                        style: AppWidget.whiteTextStyle(18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
