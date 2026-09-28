import 'package:flutter/material.dart';

// 5. InheritedWidget
class MyInheritedData extends InheritedWidget {
  final String secretMessage;

  const MyInheritedData({
    super.key,
    required this.secretMessage,
    required super.child,
  });

  static MyInheritedData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedData>();
  }

  @override
  bool updateShouldNotify(MyInheritedData oldWidget) {
    return oldWidget.secretMessage != secretMessage;
  }
}

// 2. StatefulWidget
class AsyncStatePage extends StatefulWidget {
  const AsyncStatePage({super.key});

  @override
  State<AsyncStatePage> createState() => _AsyncStatePageState();
}

class _AsyncStatePageState extends State<AsyncStatePage> {
  // Setup for StreamBuilder
  Stream<int> _generateStream() async* {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      yield i;
    }
  }

  // Setup for ValueListenableBuilder
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyInheritedData(
      secretMessage: 'Halo dari InheritedWidget!',
      child: Scaffold(
        appBar: AppBar(title: const Text('Async & State Widgets')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('1 & 2. StatelessWidget & StatefulWidget', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Halaman ini adalah StatefulWidget, dan beberapa komponen di bawahnya adalah StatelessWidget.'),
              const Divider(height: 32),

              const Text('3. StreamBuilder (Hitung 1-10)', style: TextStyle(fontWeight: FontWeight.bold)),
              StreamBuilder<int>(
                stream: _generateStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return const Text('Stream Selesai!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text(
                      'Nilai Stream: ${snapshot.data}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),
              const Divider(height: 32),

              const Text('4. InheritedWidget', style: TextStyle(fontWeight: FontWeight.bold)),
              const InheritedWidgetDemo(), // This is a StatelessWidget
              const Divider(height: 32),

              const Text('5. ValueListenableBuilder', style: TextStyle(fontWeight: FontWeight.bold)),
              ValueListenableBuilder<int>(
                valueListenable: _counter,
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nilai ValueNotifier: $value', style: const TextStyle(fontSize: 18)),
                      ElevatedButton(
                        onPressed: () => _counter.value += 1,
                        child: const Text('Tambah'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. StatelessWidget that consumes InheritedWidget
class InheritedWidgetDemo extends StatelessWidget {
  const InheritedWidgetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final inheritedData = MyInheritedData.of(context);
    return Card(
      color: Colors.purple.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          inheritedData?.secretMessage ?? 'Tidak ada data InheritedWidget',
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
