import 'package:expensio/app.dart';
import 'package:expensio/bloc/cubit/app_cubit.dart';
import 'package:expensio/helpers/db.helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ FFI init only for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await getDBInstance();
  AppState appState = await AppState.getState();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppCubit(appState)),
      ],
      child: const App(),
    ),
  );
}
