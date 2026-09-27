import 'package:flutter/material.dart';

class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isVisible = true;
  bool _isFirstIcon = true;
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animasi Widgets')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero
            const Center(
              child: Hero(
                tag: 'animation_hero_tag',
                child: Icon(Icons.animation, size: 80, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Hero Animation', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 32),

            // 2. AnimatedContainer
            ListTile(
              title: const Text('AnimatedContainer'),
              trailing: Switch(
                value: _isExpanded,
                onChanged: (val) => setState(() => _isExpanded = val),
              ),
            ),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: _isExpanded ? 200 : 100,
                height: _isExpanded ? 100 : 50,
                decoration: BoxDecoration(
                  color: _isExpanded ? Colors.blue : Colors.red,
                  borderRadius: BorderRadius.circular(_isExpanded ? 20 : 8),
                ),
                child: const Center(child: Text('Tap Switch!', style: TextStyle(color: Colors.white))),
              ),
            ),
            const Divider(height: 32),

            // 3. AnimatedOpacity
            ListTile(
              title: const Text('AnimatedOpacity'),
              trailing: Switch(
                value: _isVisible,
                onChanged: (val) => setState(() => _isVisible = val),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const FlutterLogo(size: 80),
              ),
            ),
            const Divider(height: 32),

            // 4. AnimatedSwitcher
            ListTile(
              title: const Text('AnimatedSwitcher'),
              trailing: ElevatedButton(
                onPressed: () => setState(() => _isFirstIcon = !_isFirstIcon),
                child: const Text('Toggle'),
              ),
            ),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(turns: animation, child: child);
                },
                child: Icon(
                  _isFirstIcon ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey<bool>(_isFirstIcon),
                  size: 80,
                  color: Colors.pink,
                ),
              ),
            ),
            const Divider(height: 32),

            // 5 & 6. FadeTransition & ScaleTransition
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'FadeTransition & ScaleTransition\n(Berjalan Otomatis via Controller)',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Card(
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.lightbulb, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Card(
                    color: Colors.green,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.zoom_out_map, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
