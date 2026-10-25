import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/app_routes/app_rout_name.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/date_layer/datesourse/notes_remote_date_source.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/date_layer/repositoryimp/notes_repository_impl.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/domain/usecases/get_notes_use_case.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/maneger/notes_bloc.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/presentation/maneger/notes_event.dart';
import 'core/modules/lay_out_view_feature/domain/usecases/VerifyPasswordUseCase.dart';
import 'core/modules/lay_out_view_feature/domain/usecases/​UpdatePasswordUseCase.dart';
import 'firebase_options.dart';

import 'package:notes_app/core/Services/notification_service.dart';

import 'package:notes_app/core/app_routes/app_rout_config.dart';

import 'package:notes_app/core/modules/lay_out_view_feature/domain/usecases/add_notes_use_case.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/domain/usecases/delete_notes_use_case.dart';
import 'package:notes_app/core/modules/lay_out_view_feature/domain/usecases/update_note_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // 1. إنشاء الـ DataSource والـ Repository
    final dataSource = NotesRemoteDataSourceImpl();
    final repository = NotesRepositoryImpl(remoteDataSource: dataSource);

    // 2. إنشاء الـ Use Cases الستة
    final getNotesUseCase = GetNotesUseCase(repository);
    final addNoteUseCase = AddNotesUseCase(repository);
    final updateNoteUseCase = UpdateNoteUseCase(repository);
    final deleteNoteUseCase = DeleteNotesUseCase(repository);
    final verifyPasswordUseCase = Verifypasswordusecase(repository);
    final updatePasswordUseCase = updatepasswordusecase(repository);

    return BlocProvider(
      create: (context) => NotesBloc(
        getNotesUseCase: getNotesUseCase,
        addNoteUseCase: addNoteUseCase,
        updateNoteUseCase: updateNoteUseCase,
        deleteNoteUseCase: deleteNoteUseCase,
        verifyPasswordUseCase: verifyPasswordUseCase,
        updatePasswordUseCase: updatePasswordUseCase,
      )..add(FetchNotesEvent()),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutName.home,
        onGenerateRoute: AppRoutConfig.generateRoute,
      ),
    );
  }
}