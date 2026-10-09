import 'package:flutter/material.dart';
import 'package:notes_app/core/app_them_maneger/app_colors.dart';

import 'plus_tap_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Helo\n'
                        'My Notes',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: AppColors.primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:  const TextField(
                    style: TextStyle(color: AppColors.primaryText),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: AppColors.secondaryText,),
                      hintText: 'Search Here',
                      hintStyle: TextStyle(color: AppColors.secondaryText),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [

                    SizedBox(
                      height: 188,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '28 May',
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 15,
                                  ),
                                ),
                                Icon(
                                  Icons.delete_outline,
                                  color: AppColors.secondaryText,
                                  size: 18,
                                ),
                              ],
                            ),
                            const Text(
                              'Task Management App Ui Design',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'In publishing and graphic design',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                '. Just Now ',
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 219,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '12 May',
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 15,
                                  ),
                                ),
                                Icon(
                                  Icons.delete_outline,
                                  color: AppColors.secondaryText,
                                  size: 18,
                                ),
                              ],
                            ),
                            const Text(
                              'Shopping List',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              children: [
                                _buildCheckBoxItem('Apple'),
                                _buildCheckBoxItem('Mango'),
                                _buildCheckBoxItem('Note'),
                                _buildCheckBoxItem('Work'),
                              ],
                            ),
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                '1h ago',
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ]
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 88,
        color: AppColors.bottomBar,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 90,
                height: 90,
                child: Icon(
                  Icons.menu,
                  color: AppColors.secondaryText,
                  size: 32,
                ),
              ),
            ),
            Positioned(
              top: -32,
              right: 6,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlusTabScreen(),
                    ),
                  );
                },
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
                    ]
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.add,
                        color: AppColors.primaryText,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCheckBoxItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_box_outline_blank,
            size: 15,
            color: AppColors.secondaryText,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}