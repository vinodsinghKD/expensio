import 'package:expensio/bloc/cubit/app_cubit.dart';
import 'package:expensio/screens/accounts/accounts.screen.dart';
import 'package:expensio/screens/categories/categories.screen.dart';
import 'package:expensio/screens/home/home.screen.dart';
import 'package:expensio/screens/onboard/onboard_screen.dart';
import 'package:expensio/screens/settings/settings.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{
  final PageController _controller = PageController(keepPage: true);
  int _selected = 0;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state){
        AppCubit cubit = context.read<AppCubit>();
        if(cubit.state.currency == null || cubit.state.username == null){
          return OnboardScreen();
        }
        return  Scaffold(
          body: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children:  [
              HomeScreen(
                onSettingsTap: () => _controller.jumpToPage(3),
              ),
              AccountsScreen(),
              CategoriesScreen(),
              SettingsScreen()
            ],
            onPageChanged: (int index){
              setState(() {
                _selected = index;
              });
            },
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selected,
            destinations: const [
              NavigationDestination(icon: Icon(Symbols.home, fill: 1,), label: "Home"),
              NavigationDestination(icon: Icon(Symbols.wallet, fill: 1,), label: "Accounts"),
              NavigationDestination(icon: Icon(Symbols.category, fill: 1,), label: "Categories"),
              NavigationDestination(icon: Icon(Symbols.settings, fill: 1,), label: "Settings"),
            ],
            onDestinationSelected: (int selected){
                _controller.jumpToPage(selected);
            },
          ),
        );
      },
    );

  }
}