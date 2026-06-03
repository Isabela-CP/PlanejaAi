import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/logo.dart';

class _Destination {
  final String label;
  final String route;
  final IconData icon;

  const _Destination(this.label, this.route, this.icon);
}

final List<_Destination> _destinations = const [
  _Destination('Painel', '/dashboard', LucideIcons.layoutDashboard),
  _Destination('Transações', '/transactions', LucideIcons.creditCard),
  _Destination('Orçamentos', '/budgets', LucideIcons.piggyBank),
  _Destination('Metas', '/goals', LucideIcons.target),
  _Destination('Relatórios', '/reports', LucideIcons.fileText),
  _Destination('Perfil', '/profile', LucideIcons.user),
];

class LayoutScreen extends StatelessWidget {
  final Widget child;
  const LayoutScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/budgets')) return 2;
    if (location.startsWith('/goals')) return 3;
    if (location.startsWith('/reports')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0; // dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 768;
    final currentIndex = _calculateSelectedIndex(context);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 256, // Fixed width like w-64 in tailwind
              color: Theme.of(context).cardTheme.color,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Logo(size: 32, showText: true),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _destinations.length,
                      itemBuilder: (context, index) {
                        final dest = _destinations[index];
                        final isSelected = currentIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            selected: isSelected,
                            leading: Icon(
                              dest.icon,
                              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            title: Text(
                              dest.label,
                              style: TextStyle(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            onTap: () => _onItemTapped(index, context),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      leading: const Icon(LucideIcons.logOut, color: Colors.red),
                      title: const Text('Sair', style: TextStyle(color: Colors.red)),
                      onTap: () {
                        context.read<AuthProvider>().logout();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: child,
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => _onItemTapped(index, context),
          destinations: _destinations.map((dest) {
            return NavigationDestination(
              icon: Icon(dest.icon),
              label: dest.label,
            );
          }).toList(),
        ),
      );
    }
  }
}
