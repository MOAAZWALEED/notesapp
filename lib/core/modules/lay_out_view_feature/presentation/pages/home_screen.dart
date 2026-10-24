
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  // حفظ النوتات محلياً لمنع اختفائها أثناء عمليات التحقق
  List<NoteEntity> _cachedNotes = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<NotesBloc>(context).add(FetchNotesEvent());
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hello,\nMy Notes',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 36,
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
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
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

                    final notesList = _cachedNotes;

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
                                  'isPrivate': note.isPrivate,
                                  'password': note.password,
                                },
                                imagePath: note.imagePath,
                                filePath: note.filePath,
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
                              if (note.isPrivate && note.id != null) {
                                _showPasswordDialog(context, note.id!, openNoteScreen);
                              } else {
                                openNoteScreen();
                              }
                            },
                            child: Container(
                              height: note.isPrivate ? 140 : null,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        note.date,
                                        style: const TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 13,
                                        ),
                                      ),
                                      // قائمة الـ 3 نقط بخيارات التعديل والحذف
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: AppColors.secondaryText, size: 20),
                                        color: AppColors.cardColor,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            if (note.isPrivate && note.id != null) {
                                              _showPasswordDialog(context, note.id!, openNoteScreen);
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
                                          if (note.isPrivate)
                                            const PopupMenuItem(
                                              value: 'edit_password',
                                              child: Text('Edit Password', style: TextStyle(color: AppColors.primaryText)),
                                            ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (note.isPrivate)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Icon(Icons.lock, color: AppColors.greenButton, size: 30),
                                      ),
                                    )
                                  else ...[
                                    Text(
                                      note.title,
                                      style: const TextStyle(
                                        color: AppColors.primaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (note.content.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        note.content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
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