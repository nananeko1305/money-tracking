import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';

/// First-launch mini guide: a few swipeable pages explaining the app. Also
/// reachable later from the drawer. Localized via [AppScope].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;
  const _OnboardingPage(this.icon, this.title, this.body);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);

    final pages = [
      _OnboardingPage(Icons.savings, t.onbWelcomeTitle, t.onbWelcomeBody),
      _OnboardingPage(Icons.account_balance_wallet, t.onbCategoriesTitle,
          t.onbCategoriesBody),
      _OnboardingPage(Icons.payments, t.onbExpensesTitle, t.onbExpensesBody),
      _OnboardingPage(Icons.bar_chart, t.onbReportsTitle, t.onbReportsBody),
    ];
    final isLast = _index == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(t.onbSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _PageBody(page: pages[i], pal: pal),
              ),
            ),
            _Dots(count: pages.length, index: _index, pal: pal),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: pal.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(isLast ? t.onbStart : t.onbNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  final _OnboardingPage page;
  final AppPalette pal;
  const _PageBody({required this.page, required this.pal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration:
                BoxDecoration(color: pal.subtleFill, shape: BoxShape.circle),
            child: Icon(page.icon, size: 58, color: pal.green),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  final AppPalette pal;
  const _Dots({required this.count, required this.index, required this.pal});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? pal.green : pal.cardBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
