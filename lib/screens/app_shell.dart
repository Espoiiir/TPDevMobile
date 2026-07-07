import 'package:flutter/material.dart';

import 'character_search_screen.dart';
import 'guilds_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [GuildsScreen(), CharacterSearchScreen()];

  @override
  Widget build(BuildContext context) {
    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.shield_outlined),
        selectedIcon: Icon(Icons.shield),
        label: 'Guildes',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_search_outlined),
        selectedIcon: Icon(Icons.person_search),
        label: 'Recherche',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 720;
        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectIndex,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: item.icon,
                          selectedIcon: item.selectedIcon,
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          );
        }

        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectIndex,
            destinations: destinations,
          ),
        );
      },
    );
  }

  void _selectIndex(int index) {
    setState(() => _selectedIndex = index);
  }
}
