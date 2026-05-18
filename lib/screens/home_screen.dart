import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dialogs/auth_prompt_dialog.dart';
import '../logic/auth_provider.dart';
import '../services/auth_prompt_service.dart';
import '../services/diagnostic_service.dart';
import '../services/tutorial_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import 'diagnostic/diagnostic_intro_screen.dart';
import 'home/home_grid_view.dart';
import 'lessons_screen.dart';
import 'practice/practice_hub_screen.dart';
import 'settings_screen.dart';
import 'tutorial/interactive_tutorial.dart';
import 'tutorial/tutorial_keys.dart';

class HomeScreen extends StatefulWidget {
  final bool showTutorial;

  const HomeScreen({
    super.key,
    this.showTutorial = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _authPromptChecked = false;
  bool _diagnosticChecked = false;
  bool _isNavigating = false;
  bool _showInteractiveTutorial = false;

  final List<Widget> _screens = [
    const HomeGridView(),
    const LessonsScreen(),
    const PracticeHubScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkTutorialRequest();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndDiagnostic();
    });
  }

  Future<void> _checkTutorialRequest() async {
    final requested = await TutorialService.wasInteractiveTutorialRequested();
    if (requested && mounted) {
      await TutorialService.clearInteractiveTutorialRequest();
      setState(() {
        _showInteractiveTutorial = true;
      });
    }
  }

  Future<void> _checkAuthAndDiagnostic() async {
    if (_authPromptChecked && _diagnosticChecked) return;
    if (_isNavigating) return;

    final authProvider = context.read<AuthProvider>();

    if (!_authPromptChecked) {
      final shouldShow = await AuthPromptService.shouldShowAuthPrompt(
        isAuthenticated: authProvider.isAuthenticated,
        isGuest: authProvider.isGuest,
      );

      if (shouldShow && mounted && !_isNavigating) {
        await AuthPromptDialog.show(context);
      }
      _authPromptChecked = true;
    }

    if (!_diagnosticChecked && authProvider.isAuthenticated && !_isNavigating) {
      final diagnosticCompleted =
          await DiagnosticService.isDiagnosticCompleted();

      if (!diagnosticCompleted && mounted && !_isNavigating) {
        _isNavigating = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DiagnosticIntroScreen(),
          ),
        );
      }
      _diagnosticChecked = true;
    } else {
      _diagnosticChecked = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        key: TutorialKeys.bottomNav,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0 ? AppIcons.home : Icons.home_outlined,
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1 ? AppIcons.book : Icons.menu_book_outlined,
              ),
              label: 'Lecciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2
                    ? AppIcons.game
                    : Icons.sports_esports_outlined,
              ),
              label: 'Práctica',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3
                    ? AppIcons.settings
                    : Icons.settings_outlined,
              ),
              label: 'Configuración',
            ),
          ],
        ),
      ),
    );

    // Mostramos el tour interactivo si fue solicitado (primera vez o desde tutorial).
    if ((widget.showTutorial || _showInteractiveTutorial) && _currentIndex == 0) {
      screen = InteractiveTutorial(
        child: screen,
        onComplete: () {},
      );
    }

    return screen;
  }
}
