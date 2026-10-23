import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/core/app_them_maneger/app_colors.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/pages/notes_screen.dart';

class PlusTabScreen extends StatefulWidget {
  const PlusTabScreen({super.key});

  @override
  State<PlusTabScreen> createState() => PlusTabScreenState();
}

class PlusTabScreenState extends State<PlusTabScreen> {
  Future<void> openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotesScreen(imagePath: image.path),
        ),
      );
      if (mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  Future<void> pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final String selectedFilePath = result.files.single.path!;

      final resultNote = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotesScreen(filePath: selectedFilePath),
        ),
      );

      if (mounted) {
        Navigator.pop(context, resultNote);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  width: 350,
                  height: 130,
                  child: const Text(
                    'What Notes \n Do you Want?',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Center(
                  child: Container(
                    width: 388,
                    height: 500,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildOptionItem(
                          icon: Icons.camera_alt_outlined,
                          title: 'Camara',
                          width: 118,
                          height: 26,
                          onTap: openCamera,
                        ),
                        _buildDivider(),
                        _buildOptionItem(
                          icon: Icons.attach_file,
                          title: 'Attach File',
                          width: 141,
                          height: 30,
                          onTap: pickFile,
                        ),
                        _buildDivider(),
                        _buildOptionItem(
                          icon: Icons.mic_none,
                          title: 'Audio File',
                          width: 136,
                          height: 34,
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildOptionItem(
                          icon: Icons.lock_outline,
                          title: 'Private Notes',
                          width: 163,
                          height: 25,
                          onTap: () {},
                        ),

                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotesScreen(),
                              ),
                            );

                            if (mounted) {
                              Navigator.pop(context, result);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 62,
                            decoration: BoxDecoration(
                              color: AppColors.greenButton,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.note_alt_outlined, color: Colors.black, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Notes',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6, bottom: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 80,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            color: AppColors.primaryText,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.secondaryText, size: 24),
                const SizedBox(width: 15),
                SizedBox(
                  width: width,
                  height: height,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 33,
              height: 33,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.secondaryText,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Center(
      child: SizedBox(
        width: 386,
        child: const Divider(
          color: Colors.white10,
          height: 1,
        ),
      ),
    );
  }
}