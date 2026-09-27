import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking_rest_api/data/models/post.dart';
import 'package:networking_rest_api/data/providers.dart';
import 'package:networking_rest_api/main.dart';

void main() {
  testWidgets('App smoke test - verifies initial render', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postListProvider.overrideWith(
            () => _MockPostListNotifier(),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Initial pump untuk memproses future di AsyncNotifier
    await tester.pump();

    // Verifikasi bahwa judul 'Posts API' muncul di AppBar
    expect(find.text('Posts API'), findsOneWidget);
    // Verifikasi bahwa data mock tampil setelah data resolved
    expect(find.text('Mock Post Title'), findsOneWidget);
  });
}

class _MockPostListNotifier extends PostListNotifier {
  @override
  Future<List<Post>> build() async {
    return const [
      Post(
        userId: 1,
        id: 1,
        title: 'Mock Post Title',
        body: 'Mock Post Body',
      ),
    ];
  }
}
