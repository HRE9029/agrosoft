import 'package:flutter/material.dart';
import '../../theme.dart';

import 'home_page.dart';
import 'plagues_page.dart';
import 'crops/my_crops_page.dart';
import 'menu_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // 🔹 Paginas de cada tab
    _pages = [
      HomePage(key: UniqueKey()),
      PlaguesPage(key: UniqueKey()),
      MyCropsPage(key: UniqueKey()),
      MenuPage(key: UniqueKey()),
    ];
  }

  void _changeTab(int newIndex) {
    setState(() {
      _index = newIndex;
      // 🔹 Reconstruir solo la página que se abre
      _pages[_index] = _rebuildPage(_index);
    });
  }

  Widget _rebuildPage(int index) {
    switch (index) {
      case 0:
        return HomePage(key: UniqueKey());
      case 1:
        return PlaguesPage(key: UniqueKey());
      case 2:
        return MyCropsPage(key: UniqueKey());
      case 3:
        return MenuPage(key: UniqueKey());
      default:
        return HomePage(key: UniqueKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 110,
        color: AppColors.headerFooter,
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _NavItem(
                selected: _index == 0,
                icon: Icons.grass,
                label: 'Cultivos',
                onTap: () => _changeTab(0),
              ),
              _NavItem(
                selected: _index == 1,
                icon: Icons.bug_report,
                label: 'Plagas',
                onTap: () => _changeTab(1),
              ),
              _NavItem(
                selected: _index == 2,
                icon: Icons.agriculture,
                label: 'Mis cultivos',
                onTap: () => _changeTab(2),
              ),
              _NavItem(
                selected: _index == 3,
                icon: Icons.menu,
                label: 'Menú',
                onTap: () => _changeTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = selected ? Colors.black : Colors.black87;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
