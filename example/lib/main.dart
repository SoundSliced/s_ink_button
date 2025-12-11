import 'package:flutter/material.dart';
import 'package:s_ink_button/s_ink_button.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 's_ink_button example',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _increment() => setState(() => _counter++);

  // Show a SnackBar and make sure any active ones are removed immediately to
  // avoid queuing/delayed display when multiple snackbars are triggered.
  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('s_ink_button examples')),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Basic example', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              SInkButton(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Tap me'),
                ),
                onTap: (pos) {
                  _increment();
                },
              ),
              const SizedBox(height: 16),
              Text('Counter: $_counter'),
              const SizedBox(height: 76),
              const Text('Advanced example', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              SInkButton(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
                color: Colors.red.withValues(alpha: 0.9),
                scaleFactor: 0.975,
                initialSplashRadius: 6,
                hapticFeedbackType: HapticFeedbackType.mediumImpact,
                isCircleButton: true,
                hoverAndSplashBorderRadius: BorderRadius.circular(80),
                enableHapticFeedback: true,
                onTap: (p0) => _showSnackBar('Single Tapped'),
                onDoubleTap: (pos) {
                  _showSnackBar('Double Tapped');
                },
                onLongPressStart: (details) {
                  _showSnackBar('Long press start');
                },
                onLongPressEnd: (details) {
                  _showSnackBar('Long press end');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
