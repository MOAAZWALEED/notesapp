import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/core/app_them_maneger/app_colors.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/domain/entity/note_entity.dart';
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

  List<NoteEntity> _cachedNotes = [];
  final Set<String> _unlockedNotesIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    BlocProvider.of<NotesBloc>(context).add(FetchNotesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPasswordDialog(BuildContext context, String noteId, VoidCallback onSuccess) {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<NotesBloc>(context),
          child: AlertDialog(
            backgroundColor: AppColors.cardColor,
            title: const Text('Enter Password', style: TextStyle(color: AppColors.primaryText)),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: const InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
              ),
              BlocConsumer<NotesBloc, NotesState>(
                listener: (ctx, state) {
                  if (state is VerifyPasswordSuccessState) {
                    Navigator.pop(dialogContext);
                    if (state.isValid) {
                      onSuccess();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incorrect Password'), backgroundColor: Colors.red),
                      );
                    }
                  } else if (state is VerifyPasswordFailureState) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is VerifyPasswordLoadingState) {
                    return const CircularProgressIndicator(color: AppColors.greenButton);
                  }
                  return TextButton(
                    onPressed: () {
                      BlocProvider.of<NotesBloc>(context).add(
                        VerifyNotePasswordEvent(
                          noteId: noteId,
                          password: passwordController.text.trim(),
                        ),
                      );
                    },
                    child: const Text('Verify', style: TextStyle(color: AppColors.greenButton)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello,\nMy Notes',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    style: const TextStyle(color: AppColors.primaryText),
                    decoration: const InputDecoration(
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
                    if (state is NoteLoadingState && _cachedNotes.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.greenButton,
                        ),
                      );
                    } else if (state is NoteSuccessState) {
                      _cachedNotes = state.notes;
                    } else if (state is NoteErrorState && _cachedNotes.isEmpty) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final notesList = _cachedNotes.where((note) {
                      final query = _searchQuery.toLowerCase();
                      final titleLower = note.title.toLowerCase();
                      final contentLower = note.content.toLowerCase();
                      return titleLower.contains(query) || contentLower.contains(query);
                    }).toList();

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
                        final bool isUnlockedInHome = note.id != null && _unlockedNotesIds.contains(note.id);

                        void openNoteScreen() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotesScreen(
                                existingNote: {
                                  'id': note.id,
                                  'title': note.title,
                                  'content': note.content,
                                  'reminderDateTime': note.reminderDateTime,
                                  'imagePath': note.imagePath,
                                  'filePath': note.filePath,
                                  'audioPath': note.audioPath,
                                  'isPrivate': note.isPrivate,
                                  'password': note.password,
                                },
                                imagePath: note.imagePath,
                                filePath: note.filePath,
                                audioPath: note.audioPath,
                                isPrivate: note.isPrivate,
                              ),
                            ),
                          ).then((_) {
                            BlocProvider.of<NotesBloc>(context).add(FetchNotesEvent());
                          });
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: GestureDetector(
                            onTap: () {
                              if (note.isPrivate && note.id != null && !isUnlockedInHome) {
                                _showPasswordDialog(context, note.id!, () {
                                  setState(() {
                                    _unlockedNotesIds.add(note.id!);
                                  });
                                });
                              } else {
                                openNoteScreen();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            note.reminderDateTime != null
                                                ? DateFormat('d MMM, yyyy').format(note.reminderDateTime!)
                                                : note.date,
                                            style: const TextStyle(
                                              color: AppColors.secondaryText,
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (note.reminderDateTime != null) ...[
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.notifications_active,
                                              color: Color(0xFF8AC53E),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat('h:mm a').format(note.reminderDateTime!),
                                              style: const TextStyle(
                                                color: Color(0xFF8AC53E),
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      note.isPrivate
                                          ? PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: AppColors.secondaryText, size: 20),
                                        color: AppColors.cardColor,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            if (note.isPrivate && note.id != null && !isUnlockedInHome) {
                                              _showPasswordDialog(context, note.id!, () {
                                                setState(() {
                                                  _unlockedNotesIds.add(note.id!);
                                                });
                                              });
                                            } else {
                                              openNoteScreen();
                                            }
                                          } else if (value == 'edit_password') {
                                            if (note.isPrivate && note.id != null) {
                                              _showPasswordDialog(context, note.id!, openNoteScreen);
                                            }
                                          } else if (value == 'delete') {
                                            if (note.id != null) {
                                              final bloc = BlocProvider.of<NotesBloc>(context);
                                              bloc.add(DeleteNoteEvent(note.id!));
                                              bloc.add(FetchNotesEvent());
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit Note', style: TextStyle(color: AppColors.primaryText)),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit_password',
                                            child: Text('Edit Password', style: TextStyle(color: AppColors.primaryText)),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                          ),
                                        ],
                                      )
                                          : IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                        onPressed: () {
                                          if (note.id != null) {
                                            final bloc = BlocProvider.of<NotesBloc>(context);
                                            bloc.add(DeleteNoteEvent(note.id!));
                                            bloc.add(FetchNotesEvent());
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  if (note.isPrivate && !isUnlockedInHome)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Icon(Icons.lock, color: AppColors.greenButton, size: 30),
                                      ),
                                    )
                                  else ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                note.title,
                                                style: const TextStyle(
                                                  color: AppColors.primaryText,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (note.content.isNotEmpty) ...[
                                                const SizedBox(height: 10),
                                                ...note.content.split('\n').map((line) {
                                                  final trimmed = line.trim();
                                                  bool isChecked = false;
                                                  String itemText = trimmed;

                                                  if (trimmed.startsWith('[x]') || trimmed.startsWith('[X]')) {
                                                    isChecked = true;
                                                    itemText = trimmed.substring(3).trim();
                                                  } else if (trimmed.startsWith('[ ]')) {
                                                    isChecked = false;
                                                    itemText = trimmed.substring(3).trim();
                                                  }

                                                  if (trimmed.startsWith('[x]') || trimmed.startsWith('[X]') || trimmed.startsWith('[ ]')) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(bottom: 10.0),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 16,
                                                            height: 16,
                                                            decoration: BoxDecoration(
                                                              color: isChecked ? const Color(0xFF8AC53E) : Colors.transparent,
                                                              borderRadius: BorderRadius.circular(5),
                                                              border: Border.all(
                                                                color: isChecked ? const Color(0xFF8AC53E) : AppColors.secondaryText,
                                                                width: 1.5,
                                                              ),
                                                            ),
                                                            child: isChecked
                                                                ? const Icon(
                                                              Icons.check,
                                                              size: 15,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            )
                                                                : null,
                                                          ),
                                                          const SizedBox(width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              itemText,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: const TextStyle(
                                                                color: AppColors.secondaryText,
                                                                fontSize: 17,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(bottom: 4.0),
                                                      child: Text(
                                                        line,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          color: AppColors.secondaryText,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (note.imagePath != null && note.imagePath!.isNotEmpty) ...[
                                          const SizedBox(width: 12),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(
                                              File(note.imagePath!),
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (note.audioPath != null && note.audioPath!.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.mic,
                                              color: Color(0xFF8AC53E),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                note.audioPath!.split('/').last,
                                                style: const TextStyle(
                                                  color: AppColors.primaryText,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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