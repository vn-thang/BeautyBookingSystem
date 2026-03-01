import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection/service_locator.dart';
import '../bloc/home_bloc.dart';
import 'home_view.dart';
import '../bloc/home_event.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(LoadHomeEvent()),
      child: HomeView(),
    );
  }
}