import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/app_them_maneger/app_colors.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/maneger/notes_bloc.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/maneger/notes_event.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/maneger/notes_state.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/pages/notes_screen.dart';
import 'plus_tap_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<NotesBloc>(context).add(FetchNotesEvent());
  }

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
                    'Hello\nMy Notes',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
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
                  child: const TextField(
                    style: TextStyle(color: AppColors.primaryText),
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.search,
                        color: AppColors.secondaryText,
                      ),
                      hintText: 'Search Here',
                      hintStyle: TextStyle(color: AppColors.secondaryText),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    if (state is NoteLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.greenButton,
                        ),
                      );
                    } else if (state is NoteSuccessState) {
                      final notesList = state.notes;

                      if (notesList.isEmpty) {
                        return const Center(
                          child: Text(
                            'No notes yet.\nTap + to create one!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: notesList.length,
                        itemBuilder: (context, index) {
                          final note = notesList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotesScreen(
                                      existingNote: {
                                        'id': note.id,
                                        'title': note.title,
                                        'content': note.content,
                                      },
                                      imagePath: note.imagePath,
                                    ),
                                  ),
                                ).then((_) {
                                  BlocProvider.of<NotesBloc>(context).add(FetchNotesEvent());
                                });
                              },
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
                                    if (note.imagePath != null &&
                                        note.imagePath!.isNotEmpty) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(note.imagePath!),
                                          height: 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          note.date,
                                          style: const TextStyle(
                                            color: AppColors.secondaryText,
                                            fontSize: 15,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (note.id != null) {
                                              final bloc = BlocProvider.of<NotesBloc>(context);
                                              bloc.add(DeleteNoteEvent(note.id!));
                                              bloc.add(FetchNotesEvent());
                                            }
                                          },
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: AppColors.secondaryText,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      note.title,
                                      style: const TextStyle(
                                        color: AppColors.primaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (note.content.isNotEmpty) ...[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: note.content.split('\n').map((line) {
                                          final trimmed = line.trim();
                                          if (trimmed.startsWith('[x]') || trimmed.startsWith('[X]')) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 4.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.check_box_outlined, color: AppColors.greenButton, size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      trimmed.substring(3).trim(),
                                                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else if (trimmed.startsWith('[ ]')) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 4.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.check_box_outline_blank, color: AppColors.secondaryText, size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      trimmed.substring(3).trim(),
                                                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return Text(
                                            line,
                                            style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is NoteErrorState) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    return const Center(
                      child: Text(
                        'No notes yet.\nTap + to create one!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 88,
        color: AppColors.bottomBar,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
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
                  ).then((_) {
                    BlocProvider.of<NotesBloc>(context).add(FetchNotesEvent());
                  });
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
                    ],
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
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
}