import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_page.dart';
import 'members_expenses_screen.dart';
import 'profile_page.dart';

class MainNavigation extends ConsumerStatefulWidget {
  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> with SingleTickerProviderStateMixin {
  int _currentIndex = 1; // Start with Home (Family Finance) as the initial page
  late AnimationController _fabController;

  final List<Widget> _pages = [
    MembersExpensesScreen(), // 0: Member Expenses (left)
    HomePage(),             // 1: Home (center/FAB)
    ProfilePage(),          // 2: Profile (right)
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  IconData _getFabIcon() {
    return Icons.home;
  }

  @override
  Widget build(BuildContext context) {
    final Color fabPink = Color(0xFFE1A4D8);
    final Color bgPurple = Color(0xFF5B2065); // still used for icons
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 350),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTapDown: (_) => _fabController.forward(),
        onTapUp: (_) => _fabController.reverse(),
        onTapCancel: () => _fabController.reverse(),
        child: AnimatedBuilder(
          animation: _fabController,
          builder: (context, child) {
            double scale = 1 + _fabController.value;
            return Transform.scale(
              scale: scale,
              child: Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [fabPink, fabPink.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: fabPink.withOpacity(0.3),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  fillColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () {
                    setState(() => _currentIndex = 1); // Center tab (Home)
                  },
                  child: Icon(_getFabIcon(), color: Colors.white, size: 32),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _CustomBottomBar(
        bgColor: bgPurple,
        onTab: (index) => setState(() => _currentIndex = index),
        currentIndex: _currentIndex,
      ),
    );
  }
}

class _CustomBottomBar extends StatelessWidget {
  final Color bgColor;
  final int currentIndex;
  final ValueChanged<int> onTab;
  const _CustomBottomBar({required this.bgColor, required this.currentIndex, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          color: Colors.grey.withOpacity(0.15),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // The pill-shaped white bar with shadow
              ClipPath(
                clipper: _NotchedBarClipper(),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              // The icons
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AnimatedNavIcon(
                      icon: Icons.group,
                      selected: currentIndex == 0,
                      onTap: () => onTab(0),
                      color: bgColor,
                    ),
                    SizedBox(width: 72), // Space for the FAB
                    _AnimatedNavIcon(
                      icon: Icons.person,
                      selected: currentIndex == 2,
                      onTap: () => onTab(2),
                      color: bgColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const _AnimatedNavIcon({required this.icon, required this.selected, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(selected ? 10 : 0),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.18),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: selected ? color : color.withOpacity(0.5),
          size: 28,
        ),
      ),
    );
  }
}

class _NotchedBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double fabRadius = 36;
    final double notchWidth = fabRadius * 2;
    final double notchHeight = 18;
    final double center = size.width / 2;
    final double barHeight = size.height;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(center - notchWidth / 2 - 12, 0);
    path.cubicTo(
      center - notchWidth / 2,
      0,
      center - notchWidth / 2,
      notchHeight,
      center,
      notchHeight,
    );
    path.cubicTo(
      center + notchWidth / 2,
      notchHeight,
      center + notchWidth / 2,
      0,
      center + notchWidth / 2 + 12,
      0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, barHeight);
    path.lineTo(0, barHeight);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
} 