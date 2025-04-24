import 'package:expensio/helpers/color.helper.dart';
import 'package:expensio/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback onGetStarted;
  const LandingPage({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Text(
                  "expensio",
                  style: GoogleFonts.montserrat(
                    textStyle: theme.textTheme.headlineLarge!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              FadeInLeft(
                duration: const Duration(milliseconds: 900),
                child: Text(
                  "Easy method to manage your savings",
                  style: GoogleFonts.poppins(
                    textStyle: theme.textTheme.headlineMedium!.copyWith(
                      color: ColorHelper.lighten(theme.colorScheme.primary, 0.1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text("Using our app, manage your finances."),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                duration: const Duration(milliseconds: 1100),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text("Simple expense monitoring for more accurate budgeting"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                duration: const Duration(milliseconds: 1200),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text("Keep track of your spending whenever and wherever you are."),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              FadeIn(
                duration: const Duration(milliseconds: 1300),
                child: const Text("*Since this application is currently in beta, be prepared for UI changes and unexpected behaviours."),
              ),
              const SizedBox(height: 20),
              FadeInRight(
                duration: const Duration(milliseconds: 1400),
                child: Container(
                  alignment: Alignment.bottomRight,
                  child: AppButton(
                    color: theme.colorScheme.inversePrimary,
                    isFullWidth: true,
                    onPressed: onGetStarted,
                    size: AppButtonSize.large,
                    label: "Get Started",
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}