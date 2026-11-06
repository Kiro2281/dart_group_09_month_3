import 'package:flutter/material.dart';

import '../services/onboarding_preferences.dart';
import 'home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  static const _pages = [
    _OnboardingContent(
      title: 'Все важное\nпо дням',
      description:
          'Записывайте задачи и напоминания, чтобы важные дела всегда были под рукой.',
      icon: Icons.calendar_month_rounded,
    ),
    _OnboardingContent(
      title: 'Планы становятся\nделами',
      description:
          'Отмечайте выполненное и двигайтесь к своим целям шаг за шагом.',
      icon: Icons.checklist_rounded,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _openHomePage();
    }
  }

  Future<void> _openHomePage() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    try {
      await OnboardingPreferences.markAsViewed();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isFinishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить настройки: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_box_rounded, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Мои задачи',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _OnboardingIllustration(icon: page.icon),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _currentPage ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? colors.primary
                          : colors.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isFinishing ? null : _nextPage,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Начать' : 'Далее',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 220,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 112,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          Icon(icon, size: 78, color: colors.primary),
          Positioned(
            top: 12,
            right: 22,
            child: _IllustrationDot(color: colors.tertiaryContainer),
          ),
          Positioned(
            bottom: 14,
            left: 18,
            child: _IllustrationDot(color: colors.secondaryContainer),
          ),
          Positioned(
            right: 12,
            bottom: 30,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: colors.primary.withValues(alpha: 0.7),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationDot extends StatelessWidget {
  const _IllustrationDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
