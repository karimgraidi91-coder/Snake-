// Smoke test: ensure app boots without crashing.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snake_battle/main.dart';

void main() {
  testWidgets('Arabic-capable Noto font is bundled for the app', (
    WidgetTester tester,
  ) async {
    await (FontLoader('NotoSansArabic')
          ..addFont(
            rootBundle.load('assets/fonts/NotoSansArabic[wdth,wght].ttf'),
          ))
        .load();
    await tester.pumpWidget(const SnakeProGame());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      app.theme!.textTheme.bodyMedium!.fontFamily,
      'NotoSansArabic',
    );
    final font = await rootBundle.load(
      'assets/fonts/NotoSansArabic[wdth,wght].ttf',
    );
    expect(font.lengthInBytes, greaterThan(100000));

    final arabicAndLatinText = TextPainter(
      text: TextSpan(
        text: 'Snake Battle العربية ١٢٣',
        style: app.theme!.textTheme.bodyMedium,
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    expect(arabicAndLatinText.width, greaterThan(0));
    expect(arabicAndLatinText.height, greaterThan(0));
  });

  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SnakeProGame());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Game board fills the viewport and player advances', (
    WidgetTester tester,
  ) async {
    final soundWasEnabled = GameSettings.soundEnabled;
    GameSettings.soundEnabled = false;
    addTearDown(() => GameSettings.soundEnabled = soundWasEnabled);

    await tester.pumpWidget(const MaterialApp(home: GamePlayScreen()));

    final gameCanvas = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is GamePainter,
    );
    final initialPainter =
        tester.widget<CustomPaint>(gameCanvas).painter as GamePainter;
    final initialHead =
        initialPainter.snakes.firstWhere((snake) => snake.isPlayer).head;
    final canvasSize = tester.getSize(gameCanvas);
    expect(canvasSize.width, 800);
    expect(canvasSize.height, greaterThan(300));
    expect(canvasSize.height, lessThan(canvasSize.width));

    await tester.pump(const Duration(milliseconds: 32));

    final interpolatedPainter =
        tester.widget<CustomPaint>(gameCanvas).painter as GamePainter;
    final interpolatingSnake = interpolatedPainter.snakes.firstWhere(
      (snake) => snake.isPlayer,
    );
    expect(interpolatingSnake.movementProgress, greaterThan(0));
    expect(interpolatingSnake.movementProgress, lessThan(20));

    await tester.pump(const Duration(milliseconds: 218));

    final updatedPainter =
        tester.widget<CustomPaint>(gameCanvas).painter as GamePainter;
    final updatedHead =
        updatedPainter.snakes.firstWhere((snake) => snake.isPlayer).head;
    expect(updatedHead, isNot(initialHead));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Game board adapts to portrait and wide layouts', (
    WidgetTester tester,
  ) async {
    final soundWasEnabled = GameSettings.soundEnabled;
    GameSettings.soundEnabled = false;
    addTearDown(() => GameSettings.soundEnabled = soundWasEnabled);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: GamePlayScreen()));

    Finder gameCanvas() => find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.painter is GamePainter,
        );

    var size = tester.getSize(gameCanvas());
    expect(size.width, 390);
    expect(size.height, greaterThan(size.width));
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(844, 390);
    await tester.pump();

    size = tester.getSize(gameCanvas());
    expect(size.width, 844);
    expect(size.height, greaterThan(200));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Player collects food and grows at the next cell', (
    WidgetTester tester,
  ) async {
    final soundWasEnabled = GameSettings.soundEnabled;
    final vibrationWasEnabled = GameSettings.vibrationEnabled;
    GameSettings.soundEnabled = false;
    GameSettings.vibrationEnabled = false;
    addTearDown(() {
      GameSettings.soundEnabled = soundWasEnabled;
      GameSettings.vibrationEnabled = vibrationWasEnabled;
    });

    await tester.pumpWidget(const MaterialApp(home: GamePlayScreen()));
    final gameCanvas = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is GamePainter,
    );
    final painter =
        tester.widget<CustomPaint>(gameCanvas).painter as GamePainter;
    final player = painter.snakes.firstWhere((snake) => snake.isPlayer);
    final originalLength = player.length;
    final originalPoints = GameSettings.totalPoints;

    for (final food in painter.foods) {
      food.pos = const Offset(100, 100);
    }
    painter.foods.first.pos = player.head + const Offset(20, 0);

    await tester.pump(const Duration(milliseconds: 150));

    expect(GameSettings.totalPoints, originalPoints + 10);
    expect(player.length, originalLength + 1);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Player collision reduces health after invincibility ends', (
    WidgetTester tester,
  ) async {
    final soundWasEnabled = GameSettings.soundEnabled;
    final vibrationWasEnabled = GameSettings.vibrationEnabled;
    GameSettings.soundEnabled = false;
    GameSettings.vibrationEnabled = false;
    addTearDown(() {
      GameSettings.soundEnabled = soundWasEnabled;
      GameSettings.vibrationEnabled = vibrationWasEnabled;
    });

    await tester.pumpWidget(const MaterialApp(home: GamePlayScreen()));
    var gameCanvas = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is GamePainter,
    );
    var painter = tester.widget<CustomPaint>(gameCanvas).painter as GamePainter;
    final player = painter.snakes.firstWhere((snake) => snake.isPlayer);
    final enemies = painter.snakes.where((snake) => !snake.isPlayer).toList();
    for (final enemy in enemies) {
      enemy.alive = false;
    }
    for (final food in painter.foods) {
      food.pos = const Offset(100, 100);
    }

    await tester.pump(const Duration(seconds: 3, milliseconds: 100));

    gameCanvas = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is GamePainter,
    );
    painter = tester.widget<CustomPaint>(gameCanvas).painter as GamePainter;
    final collisionTarget = player.head + const Offset(20, 0);
    final enemy = enemies.first;
    enemy.alive = true;
    enemy.body
      ..clear()
      ..addAll(List<Offset>.filled(5, collisionTarget));

    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Health: 2 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Direction buttons turn without allowing an immediate reverse', (
    WidgetTester tester,
  ) async {
    final soundWasEnabled = GameSettings.soundEnabled;
    GameSettings.soundEnabled = false;
    addTearDown(() => GameSettings.soundEnabled = soundWasEnabled);

    await tester.pumpWidget(const MaterialApp(home: GamePlayScreen()));

    Future<double> playerAngle() async {
      final gameCanvas = find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter is GamePainter,
      );
      final painter =
          tester.widget<CustomPaint>(gameCanvas).painter as GamePainter;
      return painter.snakes.firstWhere((snake) => snake.isPlayer).angle;
    }

    Future<void> tapDirection(IconData icon, double expectedAngle) async {
      await tester.tap(find.byIcon(icon));
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        if ((await playerAngle() - expectedAngle).abs() < 0.01) return;
      }
      expect(await playerAngle(), closeTo(expectedAngle, 0.01));
    }

    await tapDirection(Icons.arrow_back, 0);
    expect(await playerAngle(), closeTo(0, 0.01));

    await tapDirection(Icons.arrow_upward, -math.pi / 2);
    expect(await playerAngle(), closeTo(-math.pi / 2, 0.01));

    await tapDirection(Icons.arrow_back, math.pi);
    expect(await playerAngle(), closeTo(math.pi, 0.01));

    await tapDirection(Icons.arrow_downward, math.pi / 2);
    expect(await playerAngle(), closeTo(math.pi / 2, 0.01));

    await tapDirection(Icons.arrow_forward, 0);
    expect(await playerAngle(), closeTo(0, 0.01));

    await tapDirection(Icons.arrow_back, 0);
    expect(await playerAngle(), closeTo(0, 0.01));

    final turboLabel = find.text('TURBO');
    final turboGesture = await tester.startGesture(
      tester.getCenter(turboLabel),
    );
    await tester.pump(const Duration(milliseconds: 600));
    final turboContainer =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    final turboGradient = (turboContainer.decoration! as BoxDecoration)
        .gradient! as RadialGradient;
    expect(turboGradient.colors.first, Colors.red);
    await turboGesture.up();
    await tester.pump();
    final releasedTurboContainer =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    final releasedGradient =
        (releasedTurboContainer.decoration! as BoxDecoration).gradient!
            as RadialGradient;
    expect(releasedGradient.colors.first, Colors.orange);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Direction changes move the player and turbo increases speed', (
    WidgetTester tester,
  ) async {
    final soundWasEnabled = GameSettings.soundEnabled;
    final vibrationWasEnabled = GameSettings.vibrationEnabled;
    GameSettings.soundEnabled = false;
    GameSettings.vibrationEnabled = false;
    addTearDown(() {
      GameSettings.soundEnabled = soundWasEnabled;
      GameSettings.vibrationEnabled = vibrationWasEnabled;
    });

    await tester.pumpWidget(const MaterialApp(home: GamePlayScreen()));

    Finder gameCanvas() => find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.painter is GamePainter,
        );
    SnakeEntity player() =>
        (tester.widget<CustomPaint>(gameCanvas()).painter! as GamePainter)
            .snakes
            .firstWhere((snake) => snake.isPlayer);

    Future<void> turnAndMove(
      IconData button,
      double expectedAngle, {
      double? dxDirection,
      double? dyDirection,
    }) async {
      await tester.tap(find.byIcon(button));
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        if ((player().angle - expectedAngle).abs() < 0.01) break;
      }
      expect(player().angle, closeTo(expectedAngle, 0.01));

      final start = player().head;
      await tester.pump(const Duration(milliseconds: 220));
      final end = player().head;
      if (dxDirection != null) {
        expect((end.dx - start.dx) * dxDirection, greaterThan(10));
      }
      if (dyDirection != null) {
        expect((end.dy - start.dy) * dyDirection, greaterThan(10));
      }
    }

    await turnAndMove(
      Icons.arrow_upward,
      -math.pi / 2,
      dyDirection: -1,
    );
    await turnAndMove(
      Icons.arrow_back,
      math.pi,
      dxDirection: -1,
    );
    await turnAndMove(
      Icons.arrow_downward,
      math.pi / 2,
      dyDirection: 1,
    );
    await turnAndMove(Icons.arrow_forward, 0, dxDirection: 1);

    await tester.pump(const Duration(milliseconds: 250));
    final normalHead = player().head;
    final normalProgress = player().movementProgress;
    await tester.pump(const Duration(milliseconds: 250));
    final normalDistance = player().head.dx -
        normalHead.dx +
        player().movementProgress -
        normalProgress;

    final turboGesture = await tester.startGesture(
      tester.getCenter(find.text('TURBO')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    final turboHead = player().head;
    final turboProgress = player().movementProgress;
    await tester.pump(const Duration(milliseconds: 250));
    final turboDistance = player().head.dx -
        turboHead.dx +
        player().movementProgress -
        turboProgress;
    await turboGesture.up();
    await tester.pump();

    expect(turboDistance, greaterThan(normalDistance * 1.5));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
