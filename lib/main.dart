import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibration/vibration.dart';

import 'ad_service.dart';

class GameAssets {
  static const loading = 'assets/images/loading.png';
  static const snakeHead = 'assets/images/head.png';
  static const snakeBody1 = 'assets/images/body1.png';
  static const snakeBody2 = 'assets/images/body2.png';
  static const snakeTail = 'assets/images/tail.png';

  static const snakeSprites = [snakeHead, snakeBody1, snakeBody2, snakeTail];
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (const String.fromEnvironment('AD_PROVIDER') == 'admob') {
    unawaited(_initializeMobileAds());
  }
  unawaited(_initializeAdService());
  runApp(const SnakeProGame());
}

Future<void> _initializeMobileAds() async {
  if (kIsWeb) return;

  try {
    await MobileAds.instance.initialize();
  } catch (error, stackTrace) {
    debugPrint(
      'Google Mobile Ads initialization failed; continuing without ads: '
      '$error\n$stackTrace',
    );
  }
}

Future<void> _initializeAdService() async {
  try {
    await AdService.instance.initialize();
  } catch (error, stackTrace) {
    debugPrint(
      'Ad service initialization failed; continuing without ads: '
      '$error\n$stackTrace',
    );
  }
}

class SnakeProGame extends StatelessWidget {
  const SnakeProGame({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.dark();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Battle',
      theme: darkTheme.copyWith(
        textTheme: darkTheme.textTheme.apply(fontFamily: 'NotoSansArabic'),
        primaryTextTheme:
            darkTheme.primaryTextTheme.apply(fontFamily: 'NotoSansArabic'),
      ),
      home: const SplashScreen(),
    );
  }
}

// شاشة البداية مع تحميل الأصول
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  double _loadingProgress = 0.0;
  bool _assetsLoaded = false;
  String? _assetLoadError;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final assets = <String>{
      GameAssets.loading,
      ...GameAssets.snakeSprites,
      ...GameSettings.backgrounds.map((background) => background.asset),
    }.toList(growable: false);
    setState(() {
      _loadingProgress = 0;
      _assetsLoaded = false;
      _assetLoadError = null;
    });

    try {
      for (var index = 0; index < assets.length; index++) {
        await rootBundle.load(assets[index]);
        if (mounted) {
          setState(() => _loadingProgress = (index + 1) / assets.length);
        }
      }
    } catch (error) {
      debugPrint('Asset initialization failed: $error');
      if (mounted) {
        setState(() => _assetLoadError = error.toString());
      }
      return;
    }

    if (mounted) {
      setState(() => _assetsLoaded = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StartScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            GameAssets.loading,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Loading image failed: $error');
              return const ColoredBox(color: Color(0xFF004D40));
            },
          ),
          const ColoredBox(color: Color(0x99000000)),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade400,
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.catching_pokemon,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'SNAKE BATTLE',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Loading... ${(_loadingProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: _loadingProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_assetsLoaded)
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Assets loaded!',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ),
                    if (_assetLoadError != null) ...[
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Could not load game assets: $_assetLoadError',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadAssets,
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Retry'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SnakeSkin {
  final String id;
  final String name;
  final Color color;
  final int price;
  final int bodyStyle;

  const SnakeSkin({
    required this.id,
    required this.name,
    required this.color,
    required this.price,
    required this.bodyStyle,
  });
}

class BackgroundPack {
  final String id;
  final String asset;
  final String name;
  final int price;

  const BackgroundPack({
    required this.id,
    required this.asset,
    required this.name,
    required this.price,
  });
}

class GameSettings {
  static int totalPoints = 0;
  static int coins = 0;
  static int highScore = 0;
  static int level = 1;
  static bool soundEnabled = true;
  static bool vibrationEnabled = true;
  static String currentBackground = 'forest';
  static String currentSkinId = 'default';
  static final Map<String, bool> unlockedSkins = {'default': true};
  static final Map<String, bool> unlockedBackgrounds = {'forest': true};

  static void spendCoins(int amount) {
    coins = math.max(0, coins - amount);
  }

  static void addCoins(int amount) {
    coins += amount;
  }

  static final List<SnakeSkin> skins = [
    const SnakeSkin(
      id: 'default',
      name: 'Emerald',
      color: Color(0xFF4CAF50),
      price: 0,
      bodyStyle: 1,
    ),
    const SnakeSkin(
      id: 'ocean',
      name: 'Ocean',
      color: Color(0xFF2196F3),
      price: 100,
      bodyStyle: 1,
    ),
    const SnakeSkin(
      id: 'sunset',
      name: 'Sunset',
      color: Color(0xFFFF5722),
      price: 200,
      bodyStyle: 2,
    ),
    const SnakeSkin(
      id: 'neon',
      name: 'Neon',
      color: Color(0xFF9C27B0),
      price: 300,
      bodyStyle: 2,
    ),
    const SnakeSkin(
      id: 'gold',
      name: 'Gold',
      color: Color(0xFFFFC107),
      price: 500,
      bodyStyle: 1,
    ),
    const SnakeSkin(
      id: 'ice',
      name: 'Ice',
      color: Color(0xFF00BCD4),
      price: 400,
      bodyStyle: 2,
    ),
  ];

  static final List<BackgroundPack> backgrounds = [
    const BackgroundPack(
      id: 'forest',
      asset: 'assets/background/1.jpg',
      name: 'Forest',
      price: 0,
    ),
    const BackgroundPack(
      id: 'desert',
      asset: 'assets/background/2.jpg',
      name: 'Desert',
      price: 50,
    ),
    const BackgroundPack(
      id: 'city',
      asset: 'assets/background/1.jpg',
      name: 'City',
      price: 100,
    ),
    const BackgroundPack(
      id: 'night',
      asset: 'assets/background/4.jpg',
      name: 'Night City',
      price: 150,
    ),
    const BackgroundPack(
      id: 'space',
      asset: 'assets/background/5.jpg',
      name: 'Space',
      price: 200,
    ),
    const BackgroundPack(
      id: 'ocean',
      asset: 'assets/background/6.jpg',
      name: 'Deep Ocean',
      price: 250,
    ),
    const BackgroundPack(
      id: 'volcano',
      asset: 'assets/background/6.jpg',
      name: 'Volcano',
      price: 300,
    ),
    const BackgroundPack(
      id: 'iceworld',
      asset: 'assets/background/5.jpg',
      name: 'Ice World',
      price: 350,
    ),
  ];

  static SnakeSkin get currentSkin => skins.firstWhere(
        (skin) => skin.id == currentSkinId,
        orElse: () => skins.first,
      );
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade900, Colors.teal.shade900],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.catching_pokemon,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'SNAKE BATTLE',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Classic Snake Game with Modern Twist',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
                _btn(
                  context,
                  'START GAME',
                  Colors.green,
                  Icons.play_arrow,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const GamePlayScreen()),
                  ),
                ),
                const SizedBox(height: 15),
                _btn(
                  context,
                  'SHOP',
                  Colors.orange,
                  Icons.store,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const StoreScreen()),
                  ),
                ),
                const SizedBox(height: 15),
                _btn(
                  context,
                  'SETTINGS',
                  Colors.blue,
                  Icons.settings,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const SettingsScreen()),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'High Score: ${GameSettings.highScore}',
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Coins: ${GameSettings.coins}',
                          style: const TextStyle(
                            color: Colors.lightGreenAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(250, 55),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
}

class SnakeEntity {
  final List<Offset> body;
  final Color color;
  final String skinId;
  final int bodyStyle;
  double angle;
  double movementProgress = 0;
  bool isPlayer;
  bool alive;

  SnakeEntity({
    required this.body,
    required this.color,
    required this.skinId,
    this.bodyStyle = 1,
    this.angle = 0,
    this.isPlayer = false,
    this.alive = true,
  });

  Offset get head => body.last;
  int get length => body.length;
}

class FoodItem {
  Offset pos;
  final Color color;

  FoodItem({required this.pos, required this.color});
}

const List<Color> _fruitColors = [
  Colors.red,
  Colors.orange,
  Colors.purple,
  Colors.green,
  Colors.yellow,
  Colors.pink,
  Colors.blue,
];

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen>
    with TickerProviderStateMixin {
  final math.Random _rnd = math.Random();
  late List<SnakeEntity> snakes;
  late List<FoodItem> foods;
  bool _gameInitialized = false;
  double angle = 0;
  bool isTurbo = false;
  bool isDanger = false;
  DateTime? gameStartTime;
  Timer? gameTimer;
  Ticker? _movementTicker;
  Timer? _invincibilityTimer;
  Duration _lastMovementElapsed = Duration.zero;

  static const Size _worldSize = Size(3000, 3000);
  static const double _worldCellSize = 20;
  int _playerHealth = 3;
  bool _isInvincible = true;
  DateTime? _lastDamageTime;

  double _baseSpeed = 3.5;
  double _currentSpeed = 3.5;

  double _shakeOffset = 0;
  DateTime? _shakeEndTime;

  AudioPlayer? backgroundMusic;
  bool _musicInitializationAttempted = false;
  ui.Image? backgroundImage;
  ui.Image? snakeHeadImage;
  ui.Image? snakeBody1Image;
  ui.Image? snakeBody2Image;
  ui.Image? snakeTailImage;
  @override
  void initState() {
    super.initState();

    _resetGame();
    _startGameLoop();
    _loadBackgroundImage(_currentBackgroundAsset);
    _loadSnakeImages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AdService.instance.showBannerAd(context);
    });
  }

  void _startMusic() {
    if (!GameSettings.soundEnabled || _musicInitializationAttempted) return;
    _musicInitializationAttempted = true;

    try {
      final player = AudioPlayer();
      backgroundMusic = player;
      unawaited(_initializeBackgroundMusic(player));
    } catch (error, stackTrace) {
      debugPrint('Background music initialization failed: $error\n$stackTrace');
    }
  }

  Future<void> _initializeBackgroundMusic(AudioPlayer player) async {
    var operation = 'configuring loop mode';
    try {
      await player
          .setReleaseMode(ReleaseMode.loop)
          .timeout(const Duration(seconds: 5));
      operation = 'loading assets/audio/music.mp3';
      await player
          .play(AssetSource('audio/music.mp3'))
          .timeout(const Duration(seconds: 5));
    } on TimeoutException catch (error) {
      debugPrint(
        'Background music $operation timed out; gameplay will continue '
        'without music. Verify the bundled asset path and audio platform '
        'plugin: $error',
      );
      await _disposeBackgroundMusic(player);
    } catch (error, stackTrace) {
      debugPrint(
        'Background music $operation failed; gameplay will continue without '
        'music. Verify the bundled asset path and audio platform plugin: '
        '$error\n$stackTrace',
      );
      await _disposeBackgroundMusic(player);
    }
  }

  Future<void> _disposeBackgroundMusic(AudioPlayer player) async {
    if (identical(backgroundMusic, player)) backgroundMusic = null;
    try {
      await player.dispose();
    } catch (error, stackTrace) {
      debugPrint('Background music cleanup failed: $error\n$stackTrace');
    }
  }

  Future<void> _playSound(String asset) async {
    AudioPlayer? player;
    try {
      if (!GameSettings.soundEnabled) return;
      player = AudioPlayer();
      final completion = player.onPlayerComplete.first;
      await player.play(AssetSource(asset)).timeout(const Duration(seconds: 5));
      await completion.timeout(const Duration(seconds: 15));
    } catch (error, stackTrace) {
      debugPrint(
        'Sound effect initialization failed ($asset): $error\n$stackTrace',
      );
    } finally {
      try {
        await player?.dispose();
      } catch (disposeError, disposeStackTrace) {
        debugPrint(
          'Sound effect cleanup failed: $disposeError\n$disposeStackTrace',
        );
      }
    }
  }

  Future<void> _safeVibrate(int duration) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    try {
      if (!await Vibration.hasVibrator()) return;
      await Vibration.vibrate(duration: duration);
    } on MissingPluginException {
      debugPrint('Vibration is unavailable on this platform; skipping.');
    } catch (error, stackTrace) {
      debugPrint('Vibration failed: $error\n$stackTrace');
    }
  }

  Future<ui.Image> _loadAssetImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _loadSnakeImages() async {
    try {
      final images = await Future.wait([
        _loadAssetImage(GameAssets.snakeHead),
        _loadAssetImage(GameAssets.snakeBody1),
        _loadAssetImage(GameAssets.snakeBody2),
        _loadAssetImage(GameAssets.snakeTail),
      ]);
      if (!mounted) {
        for (final image in images) {
          image.dispose();
        }
        return;
      }
      snakeHeadImage = images[0];
      snakeBody1Image = images[1];
      snakeBody2Image = images[2];
      snakeTailImage = images[3];
      setState(() {});
    } catch (error) {
      debugPrint('Snake sprite initialization failed: $error');
    }
  }

  Future<void> _loadBackgroundImage(String asset) async {
    try {
      final image = await _loadAssetImage(asset);
      if (!mounted) {
        image.dispose();
        return;
      }
      backgroundImage?.dispose();
      backgroundImage = image;
      setState(() {});
    } catch (error) {
      debugPrint('Background image initialization failed: $error');
    }
  }

  String get _currentBackgroundAsset => GameSettings.backgrounds
      .firstWhere(
        (background) => background.id == GameSettings.currentBackground,
        orElse: () => GameSettings.backgrounds.first,
      )
      .asset;

  void _startGameLoop() {
    gameTimer?.cancel();
    _movementTicker?.stop();

    if (!mounted || !_gameInitialized) return;

    for (final snake in snakes) {
      snake.movementProgress = 0;
    }
    _lastMovementElapsed = Duration.zero;
    _updateGame();

    gameTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted && _gameInitialized) _updateGame();
    });

    _movementTicker ??= createTicker((elapsed) {
      if (!mounted || !_gameInitialized) return;

      final frameDuration = elapsed - _lastMovementElapsed;
      _lastMovementElapsed = elapsed;
      final elapsedFrames = (frameDuration.inMicroseconds /
              const Duration(milliseconds: 16).inMicroseconds)
          .clamp(0.0, 8.0)
          .toDouble();
      if (elapsedFrames > 0) _updateMovement(elapsedFrames);
    });
    _movementTicker!.start();
  }

  void _resetGame() {
    _invincibilityTimer?.cancel();
    gameStartTime = DateTime.now();
    GameSettings.totalPoints = 0;
    GameSettings.level = 1;
    _playerHealth = 3;
    _currentSpeed = _baseSpeed;
    _shakeOffset = 0;
    _isInvincible = true; // ✅ Set invincibility flag when resetting
    angle = 0;

    final center = Offset(_worldSize.width / 2, _worldSize.height / 2);

    final playerBody = <Offset>[
      Offset(center.dx - _worldCellSize * 4, center.dy),
      Offset(center.dx - _worldCellSize * 3, center.dy),
      Offset(center.dx - _worldCellSize * 2, center.dy),
      Offset(center.dx - _worldCellSize, center.dy),
      Offset(center.dx, center.dy),
    ];

    final List<Offset> enemyPositions = [
      center + const Offset(-240, -240),
      center + const Offset(240, -240),
      center + const Offset(-240, 240),
      center + const Offset(240, 240),
      center + const Offset(0, -300),
      center + const Offset(0, 300),
    ];

    final List<Color> enemyColors = [
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.tealAccent,
    ];

    final List<String> enemySkins = [
      'ocean',
      'sunset',
      'gold',
      'neon',
      'ice',
      'ocean',
    ];
    final List<double> enemyAngles = [
      math.pi / 2,
      -math.pi / 2,
      math.pi,
      0,
      math.pi / 3,
      -math.pi / 3,
    ];

    snakes = [
      SnakeEntity(
        body: playerBody,
        color: GameSettings.currentSkin.color,
        skinId: GameSettings.currentSkin.id,
        bodyStyle: GameSettings.currentSkin.bodyStyle,
        angle: 0,
        isPlayer: true,
        alive: true,
      ),
    ];

    for (int i = 0; i < 6; i++) {
      final startPos = enemyPositions[i % enemyPositions.length];
      final body = <Offset>[];
      for (int j = 0; j < 5; j++) {
        body.add(
          Offset(
            startPos.dx + (j * _worldCellSize) * math.cos(enemyAngles[i]),
            startPos.dy + (j * _worldCellSize) * math.sin(enemyAngles[i]),
          ),
        );
      }
      snakes.add(
        SnakeEntity(
          body: body,
          color: enemyColors[i % enemyColors.length],
          skinId: enemySkins[i % enemySkins.length],
          bodyStyle: GameSettings.skins
              .firstWhere(
                (skin) => skin.id == enemySkins[i % enemySkins.length],
                orElse: () => GameSettings.skins.first,
              )
              .bodyStyle,
          angle: enemyAngles[i],
          isPlayer: false,
          alive: true,
        ),
      );
    }

    foods = List.generate(15, (_) => _randomFood());
    isDanger = false;
    _gameInitialized = true;

    // ✅ Extend invincibility period to 3 seconds
    _invincibilityTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isInvincible = false);
    });
  }

  FoodItem _randomFood() {
    return FoodItem(
      pos: Offset(
        _rnd.nextDouble() * (_worldSize.width - 80) + 40,
        _rnd.nextDouble() * (_worldSize.height - 80) + 40,
      ),
      color: _fruitColors[_rnd.nextInt(_fruitColors.length)],
    );
  }

  void _updateGame() {
    if (!mounted) return;

    _currentSpeed = _baseSpeed + (GameSettings.totalPoints / 150) * 0.4;
    if (_currentSpeed > 8.5) _currentSpeed = 8.5;

    final int newLevel = (GameSettings.totalPoints ~/ 100) + 1;
    if (newLevel > GameSettings.level) {
      GameSettings.level = newLevel;
      foods.addAll(List.generate(2, (_) => _randomFood()));

      if (GameSettings.soundEnabled) {
        unawaited(_playSound('audio/eat.mp3'));
      }
    }

    final playerSnake = snakes.firstWhere((s) => s.isPlayer);

    isDanger = snakes.where((s) => !s.isPlayer && s.alive).any((enemy) =>
        _wrappedDistance(
          _currentHeadPosition(playerSnake),
          _currentHeadPosition(enemy),
        ) <
        150);

    if (_shakeEndTime != null && DateTime.now().isAfter(_shakeEndTime!)) {
      _shakeOffset = 0;
      _shakeEndTime = null;
    } else if (_shakeEndTime != null) {
      _shakeOffset = (_rnd.nextDouble() - 0.5) * 4;
    }

    setState(() {});
  }

  void _setDirection(double requestedAngle) {
    _startMusic();
    final currentDirection = snakes.firstWhere((snake) => snake.isPlayer).angle;
    if (math.cos(requestedAngle - currentDirection) < -1e-6) return;
    if (requestedAngle == angle) return;
    setState(() => angle = requestedAngle);
  }

  void _updateMovement(double elapsedFrames) {
    if (!mounted || !_gameInitialized) return;

    if (snakes.isEmpty) return;

    final playerSnake = snakes.firstWhere(
      (s) => s.isPlayer,
      orElse: () => snakes.first,
    );

    var moved = false;
    for (final snake in snakes) {
      if (!snake.alive) continue;

      final double speedMultiplier = snake.isPlayer ? 1.0 : 0.55;
      final double turboMultiplier = (isTurbo && snake.isPlayer) ? 1.9 : 1.0;
      final double speed = _currentSpeed * speedMultiplier * turboMultiplier;
      snake.movementProgress += speed * elapsedFrames;

      while (snake.movementProgress >= _worldCellSize) {
        snake.movementProgress -= _worldCellSize;
        final head = snake.head;
        final nextHead = Offset(
          _wrapCoordinate(
            head.dx + math.cos(snake.angle) * _worldCellSize,
            _worldSize.width,
          ),
          _wrapCoordinate(
            head.dy + math.sin(snake.angle) * _worldCellSize,
            _worldSize.height,
          ),
        );
        snake.body.add(nextHead);
        moved = true;

        var ate = false;
        for (int i = 0; i < foods.length; i++) {
          if (_wrappedDistance(nextHead, foods[i].pos) < _worldCellSize * 1.4) {
            foods.removeAt(i);
            foods.add(_randomFood());

            if (snake.isPlayer) {
              GameSettings.totalPoints += 10;
              GameSettings.addCoins(5);
              if (GameSettings.totalPoints > GameSettings.highScore) {
                GameSettings.highScore = GameSettings.totalPoints;
              }

              if (GameSettings.soundEnabled) {
                unawaited(_playSound('audio/eat.mp3'));
              }
              if (GameSettings.vibrationEnabled) {
                unawaited(_safeVibrate(50));
              }

              _shakeEndTime = DateTime.now().add(
                const Duration(milliseconds: 100),
              );
            }

            ate = true;
            break;
          }
        }

        if (!ate && snake.body.length > 3) {
          snake.body.removeAt(0);
        }

        if (snake.isPlayer) {
          snake.angle = angle;
        } else {
          _updateEnemyAngle(snake);
        }
      }
    }

    if (moved) {
      _checkCollisionsByLength();

      if (_playerLost(playerSnake)) {
        _gameOver();
      }
    }

    setState(() {});
  }

  double _wrapCoordinate(double coordinate, double extent) =>
      (coordinate % extent + extent) % extent;

  double _wrappedDistance(Offset first, Offset second) {
    final dx = _wrappedDelta(first.dx - second.dx, _worldSize.width);
    final dy = _wrappedDelta(first.dy - second.dy, _worldSize.height);
    return Offset(dx, dy).distance;
  }

  Offset _currentHeadPosition(SnakeEntity snake) => Offset(
        _wrapCoordinate(
          snake.head.dx + math.cos(snake.angle) * snake.movementProgress,
          _worldSize.width,
        ),
        _wrapCoordinate(
          snake.head.dy + math.sin(snake.angle) * snake.movementProgress,
          _worldSize.height,
        ),
      );

  Offset _wrappedDirection(Offset from, Offset to) => Offset(
        _wrappedDelta(to.dx - from.dx, _worldSize.width),
        _wrappedDelta(to.dy - from.dy, _worldSize.height),
      );

  double _wrappedDelta(double delta, double extent) =>
      ((delta + extent / 2) % extent + extent) % extent - extent / 2;

  void _checkCollisionsByLength() {
    if (_isInvincible) return;

    final activeSnakes = snakes.where((s) => s.alive).toList();

    for (int i = 0; i < activeSnakes.length; i++) {
      for (int j = i + 1; j < activeSnakes.length; j++) {
        final snakeA = activeSnakes[i];
        final snakeB = activeSnakes[j];
        final headA = _currentHeadPosition(snakeA);
        final headB = _currentHeadPosition(snakeB);

        if (_wrappedDistance(headA, headB) < 25) {
          if (snakeA.length > snakeB.length + 2) {
            _eatSnake(snakeA, snakeB);
          } else if (snakeB.length > snakeA.length + 2) {
            _eatSnake(snakeB, snakeA);
          } else {
            if (snakeA.isPlayer) _applyDamage();
            if (snakeB.isPlayer) _applyDamage();

            final pushBack = _wrappedDirection(headB, headA) * 0.3;
            if (snakeA.body.length > 2) {
              final newHeadA = Offset(
                _wrapCoordinate(headA.dx + pushBack.dx, _worldSize.width),
                _wrapCoordinate(headA.dy + pushBack.dy, _worldSize.height),
              );
              snakeA.body.add(newHeadA);
              snakeA.body.removeAt(0);
            }
            if (snakeB.body.length > 2) {
              final newHeadB = Offset(
                _wrapCoordinate(headB.dx - pushBack.dx, _worldSize.width),
                _wrapCoordinate(headB.dy - pushBack.dy, _worldSize.height),
              );
              snakeB.body.add(newHeadB);
              snakeB.body.removeAt(0);
            }
          }
        }

        if (_wrappedDistance(snakeA.head, snakeB.body.first) < 25) {
          if (snakeA.length > snakeB.length + 1) {
            _eatSnake(snakeA, snakeB);
          } else {
            if (snakeA.isPlayer) _applyDamage();
            if (snakeB.isPlayer) _applyDamage();
          }
        }

        if (_wrappedDistance(snakeB.head, snakeA.body.first) < 25) {
          if (snakeB.length > snakeA.length + 1) {
            _eatSnake(snakeB, snakeA);
          } else {
            if (snakeA.isPlayer) _applyDamage();
            if (snakeB.isPlayer) _applyDamage();
          }
        }
      }
    }
  }

  void _eatSnake(SnakeEntity winner, SnakeEntity loser) {
    if (!loser.alive) return;

    if (loser.isPlayer) {
      _applyDamage();
      return;
    }

    loser.alive = false;
    final growAmount = math.min(8, loser.body.length ~/ 2);
    for (int i = 0; i < growAmount; i++) {
      winner.body.insert(0, winner.body.first);
    }

    if (winner.isPlayer) {
      GameSettings.totalPoints += loser.body.length * 10;
      GameSettings.addCoins(loser.body.length * 3);

      if (GameSettings.soundEnabled) {
        unawaited(_playSound('audio/eat.mp3'));
      }

      _shakeEndTime = DateTime.now().add(const Duration(milliseconds: 150));
    }
  }

  bool _playerLost(SnakeEntity player) {
    if (!player.alive) return true;

    // ✅ Don't check collision if invincible
    if (_isInvincible) return false;

    final head = _currentHeadPosition(player);

    // ✅ Only check self-collision for segments far from head (at least 5 segments back)
    for (int i = 0; i < player.body.length - 5; i++) {
      if (_wrappedDistance(head, player.body[i]) < 15) {
        _applyDamage();
        return false;
      }
    }

    // ✅ Less strict collision with enemies (distance 25 instead of 22)
    for (final enemy in snakes.where((s) => !s.isPlayer && s.alive)) {
      if (_wrappedDistance(head, _currentHeadPosition(enemy)) < 25) {
        _applyDamage();
        return false;
      }
      for (final segment in enemy.body) {
        if (_wrappedDistance(head, segment) < 25) {
          _applyDamage();
          return false;
        }
      }
    }

    return false;
  }

  void _applyDamage() {
    if (_lastDamageTime != null &&
        DateTime.now().difference(_lastDamageTime!).inMilliseconds < 800) {
      return;
    }

    _lastDamageTime = DateTime.now();
    _playerHealth--;

    if (GameSettings.vibrationEnabled) {
      unawaited(_safeVibrate(200));
    }

    if (GameSettings.soundEnabled) {
      unawaited(_playSound('audio/die.mp3'));
    }

    _shakeEndTime = DateTime.now().add(const Duration(milliseconds: 200));

    if (_playerHealth <= 0) {
      final playerSnake = snakes.firstWhere((s) => s.isPlayer);
      playerSnake.alive = false;
      _gameOver();
    } else {
      final playerSnake = snakes.firstWhere((s) => s.isPlayer);
      final knockbackDirection = Offset(
        -math.cos(playerSnake.angle) * 35,
        -math.sin(playerSnake.angle) * 35,
      );

      for (var index = 0; index < playerSnake.body.length; index++) {
        final point = playerSnake.body[index] + knockbackDirection;
        playerSnake.body[index] = Offset(
          _wrapCoordinate(point.dx, _worldSize.width),
          _wrapCoordinate(point.dy, _worldSize.height),
        );
      }
      playerSnake.movementProgress = 0;

      setState(() => _isInvincible = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isInvincible = false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Health: $_playerHealth / 3',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _updateEnemyAngle(SnakeEntity enemy) {
    if (foods.isEmpty) return;

    final player = snakes.firstWhere((s) => s.isPlayer);
    final playerHead = _currentHeadPosition(player);
    final enemyHead = _currentHeadPosition(enemy);
    final playerDistance = _wrappedDistance(playerHead, enemyHead);

    final nearestFood = foods.reduce((a, b) {
      final da = _wrappedDistance(a.pos, enemyHead);
      final db = _wrappedDistance(b.pos, enemyHead);
      return da < db ? a : b;
    });

    if (playerDistance < 200 && enemy.length >= player.length - 2) {
      final direction = _wrappedDirection(enemyHead, playerHead).direction;
      enemy.angle = direction + (_rnd.nextDouble() - 0.5) * 0.3;
    } else {
      final direction = _wrappedDirection(enemyHead, nearestFood.pos).direction;
      enemy.angle = direction + (_rnd.nextDouble() - 0.5) * 0.2;
    }

    for (final other in snakes) {
      if (other != enemy && other.alive) {
        final otherHead = _currentHeadPosition(other);
        if (_wrappedDistance(enemyHead, otherHead) < 80) {
          final avoidDirection =
              _wrappedDirection(otherHead, enemyHead).direction;
          enemy.angle = avoidDirection + (_rnd.nextDouble() - 0.5);
        }
      }
    }
  }

  void _gameOver() {
    gameTimer?.cancel();
    _movementTicker?.stop();
    _invincibilityTimer?.cancel();

    if (GameSettings.soundEnabled) {
      unawaited(_playSound('audio/die.mp3'));
    }
    if (GameSettings.vibrationEnabled) {
      unawaited(_safeVibrate(500));
    }

    // Show interstitial ad on game over
    AdService.instance.showInterstitialAd();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('GAME OVER', style: TextStyle(color: Colors.red)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Points: ${GameSettings.totalPoints}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Level: ${GameSettings.level}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'High Score: ${GameSettings.highScore}',
                  style: const TextStyle(color: Colors.yellow),
                ),
              ),
              const SizedBox(height: 10),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Try again to beat your best score!',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
                _startGameLoop();
              },
              style: TextButton.styleFrom(backgroundColor: Colors.green),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('RESTART', style: TextStyle(color: Colors.white)),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('MAIN MENU'),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    final player = backgroundMusic;
    if (player != null) unawaited(_disposeBackgroundMusic(player));
    gameTimer?.cancel();
    _movementTicker?.dispose();
    _invincibilityTimer?.cancel();
    snakeHeadImage?.dispose();
    snakeBody1Image?.dispose();
    snakeBody2Image?.dispose();
    snakeTailImage?.dispose();
    backgroundImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerSnake = snakes.firstWhere((s) => s.isPlayer);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final adHeight = math.min(50.0, constraints.maxHeight * 0.12);
          final gameAreaHeight =
              math.max(0.0, constraints.maxHeight - adHeight);
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final reservedControlsHeight = math.min(
            140.0,
            gameAreaHeight * (isLandscape ? 0.18 : 0.16),
          );
          final boardWidth = constraints.maxWidth;
          final boardHeight = math.max(
            0.0,
            gameAreaHeight - reservedControlsHeight,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final controlsHeight = reservedControlsHeight;
                        return Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Center(
                                    child: SizedBox(
                                      width: boardWidth,
                                      height: boardHeight,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final viewportSize =
                                              constraints.biggest;
                                          final viewportScale =
                                              viewportSize.shortestSide / 400;
                                          final controlScale = viewportScale
                                              .clamp(0.55, 1.0)
                                              .toDouble();
                                          return Stack(
                                            children: [
                                              Positioned.fill(
                                                child: CustomPaint(
                                                  painter: GamePainter(
                                                    snakes,
                                                    foods,
                                                    worldSize: _worldSize,
                                                    worldCellSize:
                                                        _worldCellSize,
                                                    backgroundImage:
                                                        backgroundImage,
                                                    backgroundColor:
                                                        _getBackgroundColor(),
                                                    headImage: snakeHeadImage,
                                                    body1Image: snakeBody1Image,
                                                    body2Image: snakeBody2Image,
                                                    tailImage: snakeTailImage,
                                                    shakeOffset: _shakeOffset *
                                                        viewportScale,
                                                  ),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: GestureDetector(
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                  onPanUpdate: (details) {
                                                    if (details.delta.distance >
                                                        0.5) {
                                                      _setDirection(
                                                        details.delta.direction,
                                                      );
                                                    }
                                                  },
                                                  child:
                                                      const SizedBox.expand(),
                                                ),
                                              ),
                                              Positioned(
                                                top: 50 * controlScale,
                                                left: 20 * controlScale,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      20,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      ...List.generate(
                                                        _playerHealth,
                                                        (index) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 2,
                                                          ),
                                                          child: Icon(
                                                            Icons.favorite,
                                                            color: Colors.red,
                                                            size: 24 *
                                                                controlScale,
                                                          ),
                                                        ),
                                                      ),
                                                      ...List.generate(
                                                        3 - _playerHealth,
                                                        (index) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 2,
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .favorite_border,
                                                            color: Colors.grey,
                                                            size: 24 *
                                                                controlScale,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 50 * controlScale,
                                                right: 20 * controlScale,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        16 * controlScale,
                                                    vertical: 8 * controlScale,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      20,
                                                    ),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          'Score: ${GameSettings.totalPoints}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Level ${GameSettings.level}',
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.yellow,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Length: ${playerSnake.body.length}',
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 120 * controlScale,
                                                right: 20 * controlScale,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        12 * controlScale,
                                                    vertical: 6 * controlScale,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Enemies: ${snakes.where((s) => !s.isPlayer && s.alive).length}',
                                                      style: const TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 20 * controlScale,
                                                left: 20 * controlScale,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        12 * controlScale,
                                                    vertical: 6 * controlScale,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Speed: ${(_currentSpeed / _baseSpeed).toStringAsFixed(1)}x',
                                                      style: const TextStyle(
                                                        color: Colors.cyan,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 120 * controlScale,
                                                left: 0,
                                                right: 0,
                                                child: IgnorePointer(
                                                  ignoring: !_isInvincible,
                                                  child: AnimatedOpacity(
                                                    opacity:
                                                        _isInvincible ? 1 : 0,
                                                    duration: const Duration(
                                                      milliseconds: 200,
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              20 * controlScale,
                                                          vertical:
                                                              8 * controlScale,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .yellow.shade800,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20,
                                                          ),
                                                        ),
                                                        child: const FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            'INVINCIBLE',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 120 * controlScale,
                                                left: 20 * controlScale,
                                                right: 20 * controlScale,
                                                child: IgnorePointer(
                                                  ignoring: !isDanger ||
                                                      _isInvincible,
                                                  child: AnimatedOpacity(
                                                    opacity: isDanger &&
                                                            !_isInvincible
                                                        ? 1
                                                        : 0,
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            20 * controlScale,
                                                        vertical:
                                                            10 * controlScale,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .red.shade700
                                                            .withAlpha(220),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          12,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.red,
                                                            blurRadius: 10,
                                                            spreadRadius: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Icons.warning,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(
                                                            width: 10 *
                                                                controlScale,
                                                          ),
                                                          const Expanded(
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                'DANGER: ENEMY NEARBY!',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 120 * controlScale,
                                                left: 20 * controlScale,
                                                child: Container(
                                                  width: 90 * controlScale,
                                                  height: 90 * controlScale,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black38,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ),
                                                    border: Border.all(
                                                      color: Colors.white24,
                                                    ),
                                                  ),
                                                  child: CustomPaint(
                                                    painter: RadarPainter(
                                                      playerSnake.head,
                                                      foods,
                                                      _worldSize,
                                                      snakes,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: controlsHeight,
                              width: double.infinity,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final controlScale = math
                                      .min(
                                        boardHeight / 400,
                                        constraints.maxWidth / 430,
                                      )
                                      .clamp(0.4, 1.0)
                                      .toDouble();
                                  return Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      runAlignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8 * controlScale,
                                      runSpacing: 4 * controlScale,
                                      children: [
                                        _controlButton(
                                          Icons.arrow_upward,
                                          -math.pi / 2,
                                          controlScale,
                                        ),
                                        _controlButton(
                                          Icons.arrow_back,
                                          math.pi,
                                          controlScale,
                                        ),
                                        _controlButton(
                                          Icons.arrow_forward,
                                          0,
                                          controlScale,
                                        ),
                                        _controlButton(
                                          Icons.arrow_downward,
                                          math.pi / 2,
                                          controlScale,
                                        ),
                                        _turboButton(controlScale),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: adHeight,
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF101010),
                      child: const Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Advertisement',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: _gameInitialized,
                  child: AnimatedOpacity(
                    opacity: _gameInitialized ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.green.shade900, Colors.teal.shade900],
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 20),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Initializing Game...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _controlButton(IconData icon, double a, double scale) =>
      GestureDetector(
        onTap: () => _setDirection(a),
        child: Container(
          margin: EdgeInsets.all(6 * scale),
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black87, Colors.black54],
            ),
            borderRadius: BorderRadius.circular(15 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 30 * scale, color: Colors.white),
        ),
      );

  Widget _turboButton(double scale) => GestureDetector(
        onLongPressStart: (_) => setState(() => isTurbo = true),
        onLongPressEnd: (_) => setState(() => isTurbo = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: (isTurbo ? 90 : 75) * scale,
          height: (isTurbo ? 90 : 75) * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isTurbo
                  ? [Colors.red, Colors.red.shade800]
                  : [Colors.orange, Colors.orange.shade800],
            ),
            boxShadow: [
              BoxShadow(
                color: isTurbo ? Colors.red : Colors.orange,
                blurRadius: isTurbo ? 20 : 10,
                spreadRadius: isTurbo ? 3 : 1,
              ),
            ],
          ),
          child: const Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on, color: Colors.white, size: 28),
                  Text(
                    'TURBO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Color _getBackgroundColor() {
    switch (GameSettings.currentBackground) {
      case 'forest':
        return Colors.green.shade900;
      case 'desert':
        return Colors.orange.shade900;
      case 'city':
        return Colors.blueGrey.shade900;
      case 'night':
        return Colors.indigo.shade900;
      case 'space':
        return Colors.purple.shade900;
      case 'ocean':
        return Colors.blue.shade900;
      case 'volcano':
        return Colors.red.shade900;
      case 'iceworld':
        return Colors.cyan.shade900;
      default:
        return Colors.teal.shade900;
    }
  }
}

class GamePainter extends CustomPainter {
  final List<SnakeEntity> snakes;
  final List<FoodItem> foods;
  final Size worldSize;
  final double worldCellSize;
  final ui.Image? backgroundImage;
  final Color backgroundColor;
  final ui.Image? headImage;
  final ui.Image? body1Image;
  final ui.Image? body2Image;
  final ui.Image? tailImage;
  final double shakeOffset;

  GamePainter(
    this.snakes,
    this.foods, {
    required this.worldSize,
    required this.worldCellSize,
    required this.backgroundImage,
    required this.backgroundColor,
    this.headImage,
    this.body1Image,
    this.body2Image,
    this.tailImage,
    required this.shakeOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cameraZoom = size.shortestSide / 400;
    final double cellSize = worldCellSize * cameraZoom;
    final playableRect = Offset.zero & size;
    final viewportCenter = Offset(size.width / 2, size.height / 2);
    final playerSnake = snakes.firstWhere((snake) => snake.isPlayer);
    final playerHead = _renderedHeadPosition(playerSnake);

    Offset toCanvas(Offset worldPosition) => Offset(
          viewportCenter.dx +
              _wrappedDelta(worldPosition.dx - playerHead.dx, worldSize.width) *
                  cameraZoom +
              shakeOffset,
          viewportCenter.dy +
              _wrappedDelta(
                      worldPosition.dy - playerHead.dy, worldSize.height) *
                  cameraZoom +
              shakeOffset,
        );

    canvas.save();
    canvas.clipRect(playableRect);
    canvas.drawRect(playableRect, Paint()..color = backgroundColor);

    final patternPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    const gridSpacing = 100.0;
    final visibleWorldWidth = size.width / cameraZoom;
    final visibleWorldHeight = size.height / cameraZoom;
    final image = backgroundImage;
    if (image != null) {
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final worldPixelSize = Size(worldSize.width, worldSize.height);
      final fittedSizes = applyBoxFit(BoxFit.cover, imageSize, worldPixelSize);
      final sourceRect = Alignment.center.inscribe(
        fittedSizes.source,
        Offset.zero & imageSize,
      );
      final worldOrigin = Offset(
        viewportCenter.dx +
            _wrappedDelta(-playerHead.dx, worldSize.width) * cameraZoom +
            shakeOffset,
        viewportCenter.dy +
            _wrappedDelta(-playerHead.dy, worldSize.height) * cameraZoom +
            shakeOffset,
      );
      final destinationSize = Size(
        worldSize.width * cameraZoom,
        worldSize.height * cameraZoom,
      );
      for (var tileX = -1; tileX <= 1; tileX++) {
        for (var tileY = -1; tileY <= 1; tileY++) {
          canvas.drawImageRect(
            image,
            sourceRect,
            Rect.fromLTWH(
              worldOrigin.dx + tileX * destinationSize.width,
              worldOrigin.dy + tileY * destinationSize.height,
              destinationSize.width,
              destinationSize.height,
            ),
            Paint(),
          );
        }
      }
    }
    canvas.drawRect(
      playableRect,
      Paint()..color = backgroundColor.withValues(alpha: 0.35),
    );
    final firstGridX =
        ((playerHead.dx - visibleWorldWidth / 2) / gridSpacing).floor();
    final lastGridX =
        ((playerHead.dx + visibleWorldWidth / 2) / gridSpacing).ceil();
    for (var gridX = firstGridX; gridX <= lastGridX; gridX++) {
      final worldX = _wrapCoordinate(gridX * gridSpacing, worldSize.width);
      final x = viewportCenter.dx +
          _wrappedDelta(worldX - playerHead.dx, worldSize.width) * cameraZoom +
          shakeOffset;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), patternPaint);
    }
    final firstGridY =
        ((playerHead.dy - visibleWorldHeight / 2) / gridSpacing).floor();
    final lastGridY =
        ((playerHead.dy + visibleWorldHeight / 2) / gridSpacing).ceil();
    for (var gridY = firstGridY; gridY <= lastGridY; gridY++) {
      final worldY = _wrapCoordinate(gridY * gridSpacing, worldSize.height);
      final y = viewportCenter.dy +
          _wrappedDelta(worldY - playerHead.dy, worldSize.height) * cameraZoom +
          shakeOffset;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), patternPaint);
    }

    for (final food in foods) {
      final pos = toCanvas(food.pos);
      final glowPaint = Paint()
        ..color = food.color.withAlpha(40)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * cameraZoom);
      canvas.drawCircle(pos, 22 * cameraZoom, glowPaint);
      canvas.drawCircle(
        pos,
        10 * cameraZoom,
        Paint()..color = food.color,
      );
      canvas.drawCircle(
        pos + Offset(-3, -3) * cameraZoom,
        2.5 * cameraZoom,
        Paint()..color = Colors.white.withAlpha(150),
      );
      canvas.drawLine(
        pos + Offset(0, -8) * cameraZoom,
        pos + Offset(2, -13) * cameraZoom,
        Paint()
          ..color = Colors.brown
          ..strokeWidth = 2 * cameraZoom
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: pos + Offset(5, -11) * cameraZoom,
          width: 7 * cameraZoom,
          height: 4 * cameraZoom,
        ),
        Paint()..color = Colors.lightGreenAccent,
      );
    }

    for (final snake in snakes) {
      if (!snake.alive) continue;

      final segmentCenters = List<Offset>.generate(
        snake.body.length,
        (index) => toCanvas(_renderedSegmentPosition(snake, index)),
      );
      if (segmentCenters.length > 1) {
        final bodyPath = Path()
          ..moveTo(segmentCenters.first.dx, segmentCenters.first.dy);
        for (final center in segmentCenters.skip(1)) {
          bodyPath.lineTo(center.dx, center.dy);
        }
        canvas.drawPath(
          bodyPath,
          Paint()
            ..color = snake.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = cellSize * 0.66
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }

      for (int i = 0; i < snake.body.length - 1; i++) {
        _drawSegment(canvas, snake, i, false, cellSize, toCanvas);
      }
      if (snake.body.isNotEmpty) {
        _drawSegment(
          canvas,
          snake,
          snake.body.length - 1,
          true,
          cellSize,
          toCanvas,
        );
      }
    }
    canvas.restore();
  }

  double _wrappedDelta(double delta, double extent) =>
      ((delta + extent / 2) % extent + extent) % extent - extent / 2;

  double _wrapCoordinate(double coordinate, double extent) =>
      (coordinate % extent + extent) % extent;

  Offset _wrapPosition(Offset position) => Offset(
        (position.dx % worldSize.width + worldSize.width) % worldSize.width,
        (position.dy % worldSize.height + worldSize.height) % worldSize.height,
      );

  Offset _wrappedPathDelta(Offset from, Offset to) => Offset(
        _wrappedDelta(to.dx - from.dx, worldSize.width),
        _wrappedDelta(to.dy - from.dy, worldSize.height),
      );

  Offset _renderedHeadPosition(SnakeEntity snake) => _wrapPosition(
        snake.head +
            Offset(
              math.cos(snake.angle) * snake.movementProgress,
              math.sin(snake.angle) * snake.movementProgress,
            ),
      );

  Offset _renderedSegmentPosition(SnakeEntity snake, int index) {
    final current = snake.body[index];
    if (index >= snake.body.length - 1) return _renderedHeadPosition(snake);

    final movementFraction =
        (snake.movementProgress / worldCellSize).clamp(0.0, 1.0).toDouble();
    return _wrapPosition(
      current +
          _wrappedPathDelta(current, snake.body[index + 1]) * movementFraction,
    );
  }

  void _drawSegment(
    Canvas canvas,
    SnakeEntity snake,
    int index,
    bool isHead,
    double cellSize,
    Offset Function(Offset) toCanvas,
  ) {
    final isTail = !isHead && index == 0;
    final worldPos = isHead
        ? _renderedHeadPosition(snake)
        : _renderedSegmentPosition(snake, index);
    final pos = toCanvas(worldPos);

    var angle = snake.angle;
    if (index == 0 && snake.body.length > 1) {
      final direction = _wrappedPathDelta(snake.body[0], snake.body[1]);
      angle = direction.direction;
    } else if (index > 0 && index < snake.body.length - 1) {
      final incoming = _wrappedPathDelta(
        snake.body[index - 1],
        snake.body[index],
      );
      final outgoing = _wrappedPathDelta(
        snake.body[index],
        snake.body[index + 1],
      );
      angle = math.atan2(
        math.sin(incoming.direction) + math.sin(outgoing.direction),
        math.cos(incoming.direction) + math.cos(outgoing.direction),
      );
    }

    final ui.Image? image = isHead
        ? headImage
        : isTail
            ? tailImage
            : snake.bodyStyle == 2
                ? (body2Image ?? body1Image)
                : (body1Image ?? body2Image);
    if (image != null) {
      final spriteSize = cellSize * 1.12;
      final sourceSize = math.min(image.width, image.height).toDouble();
      final sourceRect = isHead || isTail
          ? Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble())
          : Rect.fromLTWH(
              (image.width - sourceSize) / 2,
              (image.height - sourceSize) / 2,
              sourceSize,
              sourceSize,
            );
      final spriteWidth = isHead
          ? spriteSize * image.width / image.height
          : isTail
              ? spriteSize * 1.7
              : spriteSize;
      final spriteHeight = isHead
          ? spriteSize
          : isTail
              ? spriteWidth * image.height / image.width
              : spriteSize;
      final destinationRect = Rect.fromCenter(
        center: pos,
        width: spriteWidth,
        height: spriteHeight,
      );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      final spriteAngle = isHead
          ? angle + math.pi
          : isTail
              ? angle + math.pi
              : angle;
      canvas.rotate(spriteAngle);
      if (!isHead && !isTail) {
        canvas.clipRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: spriteSize,
              height: spriteSize,
            ),
            Radius.circular(spriteSize / 2),
          ),
        );
        canvas.translate(-pos.dx, -pos.dy);
      } else {
        canvas.translate(-pos.dx, -pos.dy);
      }
      canvas.drawImageRect(
        image,
        sourceRect,
        destinationRect,
        Paint()
          ..colorFilter = snake.isPlayer
              ? null
              : ColorFilter.mode(
                  snake.color.withAlpha(220),
                  BlendMode.multiply,
                ),
      );
      canvas.restore();
      return;
    }

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    if (isHead) canvas.rotate(angle - math.pi / 2);

    final baseSize = isHead ? 28.0 : 22.0;
    canvas.scale(cellSize / baseSize);
    final shadowPaint = Paint()
      ..color = Colors.black38
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(2, 2),
          width: baseSize,
          height: baseSize,
        ),
        Radius.circular(isHead ? 14 : 11),
      ),
      shadowPaint,
    );

    final paint = Paint()..color = snake.color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: baseSize, height: baseSize),
        Radius.circular(isHead ? 14 : 11),
      ),
      paint,
    );

    if (!isHead) {
      final highlightPaint = Paint()
        ..color = Colors.white.withAlpha(40)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(-3, -3),
            width: baseSize - 6,
            height: baseSize - 6,
          ),
          Radius.circular((baseSize - 6) / 2),
        ),
        highlightPaint,
      );
    }

    if (isHead) {
      final eyePaint = Paint()..color = Colors.white;
      canvas.drawCircle(const Offset(-9, -8), 5, eyePaint);
      canvas.drawCircle(const Offset(9, -8), 5, eyePaint);

      final pupilPaint = Paint()..color = Colors.black;
      canvas.drawCircle(const Offset(-8, -8), 3, pupilPaint);
      canvas.drawCircle(const Offset(10, -8), 3, pupilPaint);

      final tonguePaint = Paint()..color = Colors.red;
      canvas.drawLine(
        const Offset(0, 12),
        const Offset(0, 20),
        tonguePaint..strokeWidth = 3,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RadarPainter extends CustomPainter {
  final Offset player;
  final List<FoodItem> foods;
  final Size boardSize;
  final List<SnakeEntity> snakes;

  RadarPainter(this.player, this.foods, this.boardSize, this.snakes);

  @override
  void paint(Canvas canvas, Size size) {
    final squareSide = size.shortestSide;
    final offsetX = (size.width - squareSide) / 2;
    final offsetY = (size.height - squareSide) / 2;
    final playableSquare = Rect.fromLTWH(
      offsetX,
      offsetY,
      squareSide,
      squareSide,
    );

    canvas.save();
    canvas.clipRect(playableSquare);
    canvas.translate(offsetX, offsetY);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white54;

    canvas.drawRect(Rect.fromLTWH(0, 0, squareSide, squareSide), paint);

    final double scale = squareSide / boardSize.shortestSide;

    paint.color = Colors.greenAccent;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(player.dx * scale, player.dy * scale), 4, paint);

    paint.color = Colors.yellow;
    for (final food in foods) {
      canvas.drawCircle(
        Offset(food.pos.dx * scale, food.pos.dy * scale),
        2.5,
        paint,
      );
    }

    paint.color = Colors.red;
    for (final snake in snakes) {
      if (!snake.isPlayer && snake.alive) {
        canvas.drawCircle(
          Offset(snake.head.dx * scale, snake.head.dy * scale),
          3,
          paint,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _resetProgress() {
    setState(() {
      GameSettings.highScore = 0;
      GameSettings.coins = 0;
      GameSettings.currentSkinId = 'default';
      GameSettings.currentBackground = 'forest';
      GameSettings.unlockedSkins
        ..clear()
        ..addAll({'default': true});
      GameSettings.unlockedBackgrounds
        ..clear()
        ..addAll({'forest': true});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Progress reset successfully.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(fit: BoxFit.scaleDown, child: Text('Settings')),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.teal.shade900],
          ),
        ),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.palette, color: Colors.white),
              title: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Selected Skin',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              subtitle: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  GameSettings.currentSkin.name,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.landscape, color: Colors.white),
              title: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Selected Background',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              subtitle: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  GameSettings.backgrounds
                      .firstWhere(
                        (bg) => bg.id == GameSettings.currentBackground,
                      )
                      .name,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up),
              title: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Sound'),
              ),
              value: GameSettings.soundEnabled,
              onChanged: (v) => setState(() => GameSettings.soundEnabled = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration),
              title: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Vibration'),
              ),
              value: GameSettings.vibrationEnabled,
              onChanged: (v) =>
                  setState(() => GameSettings.vibrationEnabled = v),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.white),
              title: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Coins', style: TextStyle(color: Colors.white)),
              ),
              trailing: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${GameSettings.coins}',
                  style: const TextStyle(
                    color: Colors.lightGreenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                icon: const Icon(Icons.restore, color: Colors.white),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Reset Progress',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: _resetProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  bool _showSkins = true;

  void _buySkin(SnakeSkin skin) {
    final unlocked = GameSettings.unlockedSkins[skin.id] ?? false;
    if (unlocked) {
      setState(() => GameSettings.currentSkinId = skin.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Selected skin: ${skin.name}'),
          ),
        ),
      );
      return;
    }

    if (GameSettings.coins >= skin.price) {
      setState(() {
        GameSettings.spendCoins(skin.price);
        GameSettings.unlockedSkins[skin.id] = true;
        GameSettings.currentSkinId = skin.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Purchased skin: ${skin.name}'),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Not enough coins to purchase this skin.'),
          ),
        ),
      );
    }
  }

  void _buyBackground(BackgroundPack pack) {
    final unlocked = GameSettings.unlockedBackgrounds[pack.id] ?? false;
    if (unlocked) {
      setState(() => GameSettings.currentBackground = pack.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Selected background: ${pack.name}'),
          ),
        ),
      );
      return;
    }

    if (GameSettings.coins >= pack.price) {
      setState(() {
        GameSettings.spendCoins(pack.price);
        GameSettings.unlockedBackgrounds[pack.id] = true;
        GameSettings.currentBackground = pack.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Purchased background: ${pack.name}'),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Not enough coins to purchase this background.'),
          ),
        ),
      );
    }
  }

  Widget _buildSkinCard(SnakeSkin skin) {
    final unlocked = GameSettings.unlockedSkins[skin.id] ?? false;
    final selected = GameSettings.currentSkinId == skin.id;
    final canBuy = GameSettings.coins >= skin.price;
    final buttonLabel =
        unlocked ? (selected ? 'SELECTED' : 'SELECT') : 'BUY ${skin.price}';

    return Card(
      color: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: skin.color.withAlpha(180),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    skin.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Price: ${skin.price} coins',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selected ? Colors.green : Colors.blue,
                minimumSize: const Size.fromHeight(42),
              ),
              onPressed: unlocked || canBuy ? () => _buySkin(skin) : null,
              child: FittedBox(fit: BoxFit.scaleDown, child: Text(buttonLabel)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCard(BackgroundPack pack) {
    final unlocked = GameSettings.unlockedBackgrounds[pack.id] ?? false;
    final selected = GameSettings.currentBackground == pack.id;
    final canBuy = GameSettings.coins >= pack.price;
    final buttonLabel =
        unlocked ? (selected ? 'SELECTED' : 'SELECT') : 'BUY ${pack.price}';

    return Card(
      color: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      pack.asset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Store background image failed: $error');
                        return const ColoredBox(color: Colors.blueGrey);
                      },
                    ),
                    const ColoredBox(color: Color(0x66000000)),
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          pack.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Price: ${pack.price} coins',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selected ? Colors.green : Colors.blue,
                minimumSize: const Size.fromHeight(42),
              ),
              onPressed: unlocked || canBuy ? () => _buyBackground(pack) : null,
              child: FittedBox(fit: BoxFit.scaleDown, child: Text(buttonLabel)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _showSkins ? GameSettings.skins : GameSettings.backgrounds;

    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(fit: BoxFit.scaleDown, child: Text('Store')),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.teal.shade900],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            _showSkins ? Colors.white : Colors.white70,
                        backgroundColor: _showSkins
                            ? Colors.green.shade700
                            : Colors.transparent,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      onPressed: () => setState(() => _showSkins = true),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Skins'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            !_showSkins ? Colors.white : Colors.white70,
                        backgroundColor: !_showSkins
                            ? Colors.green.shade700
                            : Colors.transparent,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      onPressed: () => setState(() => _showSkins = false),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Backgrounds'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Coins: ${GameSettings.coins}',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _showSkins ? 'Skins' : 'Backgrounds',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                crossAxisCount: 1,
                childAspectRatio: 3 / 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: items.map((item) {
                  if (_showSkins) {
                    return _buildSkinCard(item as SnakeSkin);
                  }
                  return _buildBackgroundCard(item as BackgroundPack);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
