import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const StudySwipeApp());
}

class StudySwipeApp extends StatefulWidget {
  const StudySwipeApp({super.key});

  @override
  State<StudySwipeApp> createState() => _StudySwipeAppState();
}

class _StudySwipeAppState extends State<StudySwipeApp> {
  final StudyStore store = StudyStore();
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    await store.load();
    if (mounted) setState(() => isLoading = false);
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandPurple,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF121016)
          : const Color(0xFFFAF8FF),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: store.darkMode,
      builder: (context, isDark, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StudyMatch',
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/splash',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/splash':
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
                settings: settings,
              );
            case '/onboarding':
              return MaterialPageRoute(
                builder: (_) => OnboardingScreen(store: store),
                settings: settings,
              );
            case '/login':
              return MaterialPageRoute(
                builder: (_) => LoginScreen(store: store),
                settings: settings,
              );
            case '/':
            case '/home':
            return MaterialPageRoute(
              builder: (_) => isLoading
                  ? const _LoadingScreen()
                  : DiscoverScreen(store: store),
              settings: settings,
            );
          case '/topics':
            return MaterialPageRoute(
              builder: (_) => TopicsScreen(store: store),
              settings: settings,
            );
          case '/topic/new':
            return MaterialPageRoute(
              builder: (_) => TopicFormScreen(store: store),
              settings: settings,
            );
          case '/topic/edit':
            return MaterialPageRoute(
              builder: (_) => TopicFormScreen(
                store: store,
                topic: settings.arguments! as StudyTopic,
              ),
              settings: settings,
            );
          case '/matches':
            return MaterialPageRoute(
              builder: (_) => MatchesScreen(store: store),
              settings: settings,
            );
          case '/match':
            return MaterialPageRoute(
              builder: (_) => MatchScreen(
                store: store,
                profile: settings.arguments! as StudyProfile,
              ),
              settings: settings,
            );
          case '/chat':
            return MaterialPageRoute(
              builder: (_) => ChatScreen(
                store: store,
                profile: settings.arguments! as StudyProfile,
              ),
              settings: settings,
            );
          case '/report':
            return MaterialPageRoute(
              builder: (_) => ReportResultScreen(
                profile: settings.arguments! as StudyProfile,
              ),
              settings: settings,
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => ProfileScreen(store: store),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}

class AppColors {
  static const Color brandPurple = Color(0xFF6366F1);
  static const Color brandPurpleDeep = Color(0xFF4338CA);
  static const Color matchGreen = Color(0xFF10B981);
  static const Color passRed = Color(0xFFEF4444);

  /// Gradiente diagonal da marca, usado em telas de destaque.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandPurple, brandPurpleDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color brandPurple = AppColors.brandPurple;

  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: .25),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: _buildLogo(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _textFade,
                      child: _buildWelcomeText(),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: FadeTransition(
                    opacity: _textFade,
                    child: const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.white70),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _textWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.size.width;
  }

  Widget _buildWelcomeText() {
    const baseStyle = TextStyle(
      color: Colors.white,
      fontSize: 40,
      fontWeight: FontWeight.w800,
    );

    const firstLine = 'Bem-vindo ao';
    const secondLine = 'StudyMatch';

    final firstLineStyle = baseStyle.copyWith(letterSpacing: 0.2);
    final firstLineWidth = _textWidth(firstLine, firstLineStyle);
    final secondLineBaseWidth = _textWidth(
      secondLine,
      baseStyle.copyWith(letterSpacing: 0),
    );

    final gaps = secondLine.length - 1;
    final extraSpacing = gaps > 0
        ? (firstLineWidth - secondLineBaseWidth) / gaps
        : 0.0;

    final secondLineStyle = baseStyle.copyWith(letterSpacing: extraSpacing);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(firstLine, style: firstLineStyle),
        Transform.translate(
          offset: const Offset(0, -8),
          child: Text(secondLine, style: secondLineStyle),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo_white.png',
      width: 250,
      height: 250,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.local_fire_department,
          size: 180,
          color: Colors.white,
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Botão único de tema: alterna claro/escuro em todo o app.
class ThemeToggleButton extends StatelessWidget {
  final StudyStore store;
  final Color? color;

  const ThemeToggleButton({super.key, required this.store, this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: store.darkMode,
      builder: (context, isDark, _) => IconButton(
        tooltip: isDark ? 'Tema claro' : 'Tema escuro',
        color: color,
        onPressed: store.toggleDarkMode,
        icon: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final StudyStore store;

  const OnboardingScreen({super.key, required this.store});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.verified_user_outlined,
      title: 'Bem-vindo ao StudyMatch',
      description:
          'Conecte-se com pessoas que querem estudar os mesmos assuntos que você. '
          'Antes de começar, conheça nossas regras de segurança.',
    ),
    _OnboardingPage(
      icon: Icons.shield_outlined,
      title: 'Respeito em primeiro lugar',
      description:
          'Mensagens ofensivas são bloqueadas automaticamente. '
          'Trate todo mundo com educação: aqui o foco é estudar junto.',
    ),
    _OnboardingPage(
      icon: Icons.flag_outlined,
      title: 'Denúncia e moderação',
      description:
          'Encontrou algo errado? Use o botão de denúncia no chat. '
          'Nossa equipe avalia cada conta denunciada em até 24h.',
    ),
    _OnboardingPage(
      icon: Icons.lock_outline,
      title: 'Seus dados protegidos',
      description:
          'Combine encontros de estudo sempre em locais seguros ou online. '
          'Nunca compartilhe senhas ou dados bancários no chat.',
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  void _next() {
    if (_isLast) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regras de segurança'),
        actions: [
          ThemeToggleButton(store: widget.store),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('Pular'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => _pages[index],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _page ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _page
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(_isLast ? 'Começar' : 'Próximo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPurple.withValues(alpha: .35),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(icon, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final StudyStore store;

  const LoginScreen({super.key, required this.store});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final user = _userController.text.trim();
    final password = _passwordController.text.trim();
    if (user == 'admin' && password == '123') {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = 'Usuário inválido. Use admin / 123.');
    }
  }

  void _socialLogin(String provider) {
    // Para a apresentação: simula a autenticação e entra com conta de teste.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entrando com $provider...')),
    );
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  InputDecoration _fieldDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 32),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ThemeToggleButton(
                        store: widget.store,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'StudyMatch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Encontre sua dupla de estudos',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: _userController,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration('Usuário', Icons.person_outline),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  onSubmitted: (_) => _login(),
                  decoration: _fieldDecoration(
                    'Senha',
                    Icons.lock_outline,
                    suffix: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _login,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'ou continue com',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _socialLogin('Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continuar com Google'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _socialLogin('Apple'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.apple),
                  label: const Text('Continuar com Apple'),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Dica de demonstração: admin / 123',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudyTopic {
  final String id;
  final String title;
  final String category;
  final String level;
  final String description;

  const StudyTopic({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.description,
  });
}

class StudyProfile {
  final String id;
  final String name;
  final String course;
  final String bio;
  final List<String> interests;
  final IconData icon;
  final Color color;

  const StudyProfile({
    required this.id,
    required this.name,
    required this.course,
    required this.bio,
    required this.interests,
    required this.icon,
    required this.color,
  });
}

class ChatMessage {
  final String text;
  final bool isMine;
  final DateTime time;

  ChatMessage({required this.text, required this.isMine, DateTime? time})
    : time = time ?? DateTime.now();
}

/// Roteiro da conversa simulada do bot para a demonstração.
class _ChatScript {
  final String opening;
  final List<String> replies;

  const _ChatScript({required this.opening, required this.replies});
}

class ChatSafetyFilter {
  static final _blockedContent = RegExp(
    r'\b(?:idiota(?:s)?|burr(?:o|a|os|as)|otari(?:o|a|os|as)|babaca(?:s)?|imbecil(?:es)?|trouxa(?:s)?|nojent(?:o|a|os|as)|ridicul(?:o|a|os|as)|inutil|inuteis|desgracad(?:o|a|os|as)|lixo(?:s)?|merda(?:s)?|porra(?:s)?|caralho(?:s)?|cala\s+(?:a\s+)?boca|vai\s+se\s+ferrar|vai\s+tomar\s+no\s+cu|filh[oa]\s+da\s+puta|foda[\s-]?se|fdp|vsf)\b',
    caseSensitive: false,
  );

  static final _blockedCompactContent = RegExp(
    r'(?:idiotas?|burros?|burras?|otarios?|otarias?|babacas?|imbecis?|trouxas?|nojentos?|nojentas?|ridiculos?|ridiculas?|inutil|inuteis|desgracados?|desgracadas?|lixos?|merdas?|porras?|caralhos?|calaboca|vaiseferrar|vaitomarnocu|filhodaputa|filhadaputa|fodase|fdp|vsf)',
  );

  static bool containsBlockedContent(String content) {
    final normalized = _normalize(content);
    final compact = normalized.replaceAll(RegExp(r'[^a-z]'), '');
    return _blockedContent.hasMatch(normalized) ||
        _blockedCompactContent.hasMatch(compact);
  }

  static String _normalize(String content) {
    return content
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c');
  }
}

class StudyStore {
  List<StudyTopic> topics = List.of(_initialTopics);
  final Set<String> myInterests = {'Física', 'Doramas', 'Flutter'};
  final Set<String> matchedProfileIds = {};
  final Set<String> seenProfileIds = {};
  final Set<String> reportedProfileIds = {};

  /// Tema claro/escuro compartilhado por todas as telas.
  final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);

  void toggleDarkMode() => darkMode.value = !darkMode.value;

  static const profiles = [
    StudyProfile(
      id: 'luiza',
      name: 'Luiza',
      course: 'Engenharia Física',
      bio: 'Entre uma lista de exercícios e outra, sempre cabe um dorama.',
      interests: ['Física', 'Doramas', 'Literatura'],
      icon: Icons.auto_awesome,
      color: Color(0xFF7E57C2),
    ),
    StudyProfile(
      id: 'pedro',
      name: 'Pedro',
      course: 'Análise e Desenvolvimento de Sistemas',
      bio: 'Aprendendo Flutter e colecionando bons projetos de portfólio.',
      interests: ['Flutter', 'Café', 'Jogos'],
      icon: Icons.code_rounded,
      color: Color(0xFF00897B),
    ),
    StudyProfile(
      id: 'nina',
      name: 'Nina',
      course: 'Biomedicina',
      bio: 'Estudo com música baixa, marca-texto e muita curiosidade.',
      interests: ['Biologia', 'Química', 'Animes'],
      icon: Icons.biotech_outlined,
      color: Color(0xFFEF6C00),
    ),
    StudyProfile(
      id: 'rafa',
      name: 'Rafa',
      course: 'Administração',
      bio: 'Gosto de aprender na prática e trocar mapas mentais.',
      interests: ['Matemática', 'Música', 'Corrida'],
      icon: Icons.account_tree_outlined,
      color: Color(0xFF3949AB),
    ),
  ];

  static const _initialTopics = [
    StudyTopic(
      id: 'flutter',
      title: 'Flutter do zero',
      category: 'Programação',
      level: 'Iniciante',
      description: 'Widgets, rotas e criação de aplicativos mobile.',
    ),
    StudyTopic(
      id: 'english',
      title: 'Inglês para viagens',
      category: 'Idiomas',
      level: 'Iniciante',
      description: 'Vocabulário essencial para se comunicar com confiança.',
    ),
    StudyTopic(
      id: 'math',
      title: 'Matemática para provas',
      category: 'Exatas',
      level: 'Intermediário',
      description: 'Porcentagem, regra de três e resolução de exercícios.',
    ),
  ];

  Future<void> load() async {
    // Os perfis de demonstração são locais para facilitar a apresentação.
  }

  StudyProfile? get currentProfile {
    for (final profile in profiles) {
      if (!seenProfileIds.contains(profile.id) &&
          !reportedProfileIds.contains(profile.id)) {
        return profile;
      }
    }
    return null;
  }

  List<StudyProfile> get matches => profiles
      .where(
        (profile) =>
            matchedProfileIds.contains(profile.id) &&
            !reportedProfileIds.contains(profile.id),
      )
      .toList();

  List<String> sharedInterests(StudyProfile profile) {
    return profile.interests
        .where((interest) => myInterests.contains(interest))
        .toList();
  }

  bool likeProfile(StudyProfile profile) {
    seenProfileIds.add(profile.id);
    final hasMatch = sharedInterests(profile).isNotEmpty;
    if (hasMatch) matchedProfileIds.add(profile.id);
    return hasMatch;
  }

  void passProfile(StudyProfile profile) {
    seenProfileIds.add(profile.id);
  }

  void resetProfiles() {
    seenProfileIds.clear();
  }

  void reportProfile(StudyProfile profile) {
    reportedProfileIds.add(profile.id);
    matchedProfileIds.remove(profile.id);
  }

  void addTopic({
    required String title,
    required String category,
    required String level,
    required String description,
  }) {
    topics.add(
      StudyTopic(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        category: category,
        level: level,
        description: description,
      ),
    );
  }

  void updateTopic(StudyTopic updatedTopic) {
    final index = topics.indexWhere((topic) => topic.id == updatedTopic.id);
    if (index != -1) topics[index] = updatedTopic;
  }

  void deleteTopic(StudyTopic topic) {
    topics.removeWhere((item) => item.id == topic.id);
  }
}

class DiscoverScreen extends StatefulWidget {
  final StudyStore store;

  const DiscoverScreen({super.key, required this.store});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  double dragX = 0;

  void _passCurrent() {
    final profile = widget.store.currentProfile;
    if (profile == null) return;
    setState(() {
      widget.store.passProfile(profile);
      dragX = 0;
    });
  }

  void _likeCurrent() {
    final profile = widget.store.currentProfile;
    if (profile == null) return;
    final didMatch = widget.store.likeProfile(profile);
    setState(() => dragX = 0);

    if (didMatch) {
      Navigator.pushNamed(context, '/match', arguments: profile).then((_) {
        if (mounted) setState(() {});
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ainda não foi match. Continue conhecendo pessoas!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.store.currentProfile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyMatch'),
        centerTitle: true,
        actions: [
          ThemeToggleButton(store: widget.store),
          IconButton(
            tooltip: 'Meus assuntos',
            onPressed: () async {
              await Navigator.pushNamed(context, '/topics');
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.list_alt_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          children: [
            const Text(
              'Encontre sua dupla de estudos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: profile == null
                  ? _EmptyProfiles(
                      onReset: () => setState(widget.store.resetProfiles),
                    )
                  : GestureDetector(
                      onPanUpdate: (details) =>
                          setState(() => dragX += details.delta.dx),
                      onPanEnd: (_) {
                        if (dragX > 100) {
                          _likeCurrent();
                        } else if (dragX < -100) {
                          _passCurrent();
                        } else {
                          setState(() => dragX = 0);
                        }
                      },
                      child: Transform.translate(
                        offset: Offset(dragX, 0),
                        child: Transform.rotate(
                          angle: dragX / 1200,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: .92,
                                      end: 1.0,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                            child: ProfileCard(
                              key: ValueKey(profile.id),
                              profile: profile,
                              dragX: dragX,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            if (profile != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundAction(
                    icon: Icons.close_rounded,
                    color: AppColors.passRed,
                    label: 'Passar',
                    onTap: _passCurrent,
                  ),
                  const SizedBox(width: 24),
                  RoundAction(
                    icon: Icons.favorite_rounded,
                    color: AppColors.matchGreen,
                    label: 'Curtir',
                    onTap: _likeCurrent,
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigation(currentIndex: 0),
    );
  }
}

class TopicsScreen extends StatefulWidget {
  final StudyStore store;

  const TopicsScreen({super.key, required this.store});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  Future<void> _deleteTopic(StudyTopic topic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir assunto?'),
        content: Text('"${topic.title}" será removido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) setState(() => widget.store.deleteTopic(topic));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus assuntos')),
      body: widget.store.topics.isEmpty
          ? _EmptyTopics(
              onAdd: () => Navigator.pushNamed(context, '/topic/new'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.store.topics.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final topic = widget.store.topics[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: topicColor(
                        topic.category,
                      ).withValues(alpha: .15),
                      child: Icon(
                        topicIcon(topic.category),
                        color: topicColor(topic.category),
                      ),
                    ),
                    title: Text(topic.title),
                    subtitle: Text('${topic.category} - ${topic.level}'),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              '/topic/edit',
                              arguments: topic,
                            );
                            if (mounted) setState(() {});
                          },
                        ),
                        IconButton(
                          tooltip: 'Excluir',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteTopic(topic),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/topic/new');
          if (mounted) setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo assunto'),
      ),
    );
  }
}

class TopicFormScreen extends StatefulWidget {
  final StudyStore store;
  final StudyTopic? topic;

  const TopicFormScreen({super.key, required this.store, this.topic});

  @override
  State<TopicFormScreen> createState() => _TopicFormScreenState();
}

class _TopicFormScreenState extends State<TopicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _category;
  late String _level;

  static const categories = [
    'Programação',
    'Idiomas',
    'Exatas',
    'Humanas',
    'Concursos',
  ];
  static const levels = ['Iniciante', 'Intermediário', 'Avançado'];

  bool get isEditing => widget.topic != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.topic?.description ?? '',
    );
    _category = widget.topic?.category ?? categories.first;
    _level = widget.topic?.level ?? levels.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (isEditing) {
      widget.store.updateTopic(
        StudyTopic(
          id: widget.topic!.id,
          title: title,
          category: _category,
          level: _level,
          description: description,
        ),
      );
    } else {
      widget.store.addTopic(
        title: title,
        category: _category,
        level: _level,
        description: description,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar assunto' : 'Novo assunto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              isEditing
                  ? 'Atualize os dados do assunto.'
                  : 'Cadastre algo que você quer aprender.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Assunto',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe o assunto.'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _level,
              decoration: const InputDecoration(
                labelText: 'Nível',
                border: OutlineInputBorder(),
              ),
              items: levels
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _level = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Descreva o assunto.'
                  : null,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                isEditing ? 'Salvar alterações' : 'Cadastrar assunto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchesScreen extends StatefulWidget {
  final StudyStore store;

  const MatchesScreen({super.key, required this.store});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  Widget build(BuildContext context) {
    final matches = widget.store.matches;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus matches'),
        actions: [ThemeToggleButton(store: widget.store)],
      ),
      body: matches.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Curta perfis com interesses em comum para criar um match.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final profile = matches[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: profile.color.withValues(alpha: .15),
                      foregroundColor: profile.color,
                      child: Icon(profile.icon),
                    ),
                    title: Text(profile.name),
                    subtitle: Text(
                      'Em comum: ${widget.store.sharedInterests(profile).join(', ')}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Abrir chat',
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: profile,
                        );
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const AppNavigation(currentIndex: 1),
    );
  }
}

class MatchScreen extends StatefulWidget {
  final StudyStore store;
  final StudyProfile profile;

  const MatchScreen({super.key, required this.store, required this.profile});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pop;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _pop = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final shared = widget.store.sharedInterests(profile);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pop,
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 88,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        const Text(
                          'É um match!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Você e ${profile.name} podem trocar ideias e estudar juntos.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white24,
                              child: Icon(
                                Icons.person,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white24,
                              child: Icon(
                                profile.icon,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Interesses em comum',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: shared
                              .map(
                                (interest) => Chip(
                                  label: Text(
                                    interest,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.white.withValues(
                                    alpha: .18,
                                  ),
                                  side: BorderSide.none,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.brandPurpleDeep,
                            minimumSize: const Size(220, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/chat',
                            arguments: profile,
                          ),
                          icon: const Icon(Icons.chat_bubble_rounded),
                          label: const Text('Ir para o chat'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                          child: const Text('Continuar vendo perfis'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final StudyStore store;
  final StudyProfile profile;

  const ChatScreen({super.key, required this.store, required this.profile});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  late final List<ChatMessage> _messages;
  late final List<String> _botReplies;
  var _replyIndex = 0;
  var _isTyping = false;
  var _containsBlockedWord = false;

  @override
  void initState() {
    super.initState();
    final script = _scriptFor(widget.profile.id);
    _botReplies = script.replies;
    _messages = [ChatMessage(text: script.opening, isMine: false)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend =>
      _controller.text.trim().isNotEmpty && !_containsBlockedWord;

  void _onMessageChanged(String value) {
    setState(
      () =>
          _containsBlockedWord = ChatSafetyFilter.containsBlockedContent(value),
    );
  }

  void _sendMessage() {
    if (!_canSend) return;
    final message = _controller.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: message, isMine: true));
      _controller.clear();
      _isTyping = true;
    });

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: _nextReply(), isMine: false));
      });
    });
  }

  // Avança pela conversa roteirizada; ao chegar no fim, repete a última fala.
  String _nextReply() {
    final reply = _botReplies[_replyIndex.clamp(0, _botReplies.length - 1)];
    if (_replyIndex < _botReplies.length - 1) _replyIndex++;
    return reply;
  }

  _ChatScript _scriptFor(String profileId) {
    switch (profileId) {
      case 'luiza':
        return const _ChatScript(
          opening:
              'Oi! Vi que a gente curte Física e Doramas em comum 👀 que sorte!',
          replies: [
            'Sim! Estou sofrendo pra entender Termodinâmica, mas assistindo um dorama novo pra relaxar kkk. Vamos estudar juntos?',
            'Boa! Tenho uns resumos de entropia que me salvaram na última prova, posso te mandar 📚',
            'Que tal marcarmos uma call de 40 min essa semana? A gente revisa Física e no fim troca indicação de dorama 😄',
            'Fechou! Me conta: você rende mais estudando de manhã ou à noite?',
          ],
        );
      case 'pedro':
        return const _ChatScript(
          opening: 'E aí! Vi que você também tá nessa de Flutter 🚀',
          replies: [
            'Tô montando um app de estudos pro portfólio. Travei num layout, mas tá ficando legal!',
            'Se quiser, a gente compara as telas e troca dicas depois da aula ☕',
            'Curto programar ouvindo música. Você usa algum atalho de produtividade no VS Code?',
            'Massa! Bora marcar um pair programming então, rende muito mais a dois 💪',
          ],
        );
      case 'nina':
        return const _ChatScript(
          opening: 'Oi! Que bom achar alguém que também curte Biologia 🌱',
          replies: [
            'Tô revisando Citologia hoje. Estudo com música baixa e MUITO marca-texto kkk',
            'Tenho uns mapas mentais de Bioquímica, se quiser eu te mando!',
            'E aí, qual anime você tá assistindo? Preciso de recomendação pro fim de semana 🍿',
            'Combinado! Bora montar um grupinho de revisão então 📖',
          ],
        );
      default:
        return const _ChatScript(
          opening: 'Opa! Vi que a gente tem bastante interesse em comum 👋',
          replies: [
            'Curto aprender na prática e trocar mapas mentais. Qual matéria você tá focando agora?',
            'Eu estudo melhor depois de uma corrida pra clarear a cabeça 🏃',
            'Posso te mandar uma playlist que me ajuda a concentrar nos estudos 🎧',
            'Show! Bora combinar um horário curto e deixar os estudos mais leves 😎',
          ],
        );
    }
  }

  void _reportProfile() {
    widget.store.reportProfile(widget.profile);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/report',
      (route) => false,
      arguments: widget.profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.profile.color.withValues(alpha: .15),
              foregroundColor: widget.profile.color,
              child: Icon(widget.profile.icon, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.profile.name),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.matchGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'online agora',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Denunciar usuário',
            onPressed: _reportProfile,
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Conversa segura: mensagens ofensivas são bloqueadas.',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return _TypingIndicator(
                      name: widget.profile.name,
                      profile: widget.profile,
                    );
                  }
                  return _ChatBubble(
                    message: _messages[index],
                    profile: widget.profile,
                  );
                },
              ),
            ),
            if (_containsBlockedWord)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Mensagem bloqueada: remova a palavra inadequada para enviar.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: _onMessageChanged,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Escreva uma mensagem...',
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Enviar mensagem',
                    onPressed: _canSend ? _sendMessage : null,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportResultScreen extends StatelessWidget {
  final StudyProfile profile;

  const ReportResultScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Denúncia enviada',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Usuário denunciado. Nossa equipe avaliará a conta nas próximas 24h.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(220, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Voltar aos perfis'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final StudyStore store;

  const ProfileScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: [ThemeToggleButton(store: store)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 52, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Estudante', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            const Text('Construindo novos hábitos de estudo.'),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(value: '${store.topics.length}', label: 'Assuntos'),
                    _Stat(value: '${store.matches.length}', label: 'Matches'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/topics'),
              icon: const Icon(Icons.edit_note),
              label: const Text('Gerenciar assuntos'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigation(currentIndex: 2),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final StudyProfile profile;
  final double dragX;

  const ProfileCard({super.key, required this.profile, required this.dragX});

  @override
  Widget build(BuildContext context) {
    final likeOpacity = (dragX / 120).clamp(0.0, 1.0).toDouble();
    final passOpacity = (-dragX / 120).clamp(0.0, 1.0).toDouble();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [profile.color, profile.color.withValues(alpha: .62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: profile.color.withValues(alpha: .35),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Tags de interesse no topo (#hashtags).
          Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.interests
                  .map(
                    (interest) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$interest',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // Avatar/ícone grande central.
          Align(
            alignment: const Alignment(0, -0.1),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                shape: BoxShape.circle,
              ),
              child: Icon(profile.icon, size: 92, color: Colors.white),
            ),
          ),
          // Selos de swipe (aparecem ao arrastar).
          Opacity(
            opacity: likeOpacity,
            child: const Align(
              alignment: Alignment(-0.95, -0.35),
              child: SwipeBadge(text: 'CURTIR', color: Colors.greenAccent),
            ),
          ),
          Opacity(
            opacity: passOpacity,
            child: const Align(
              alignment: Alignment(0.95, -0.35),
              child: SwipeBadge(text: 'PASSAR', color: Colors.redAccent),
            ),
          ),
          // Informações na base.
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        profile.course,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  profile.bio,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final StudyProfile profile;

  const _ChatBubble({required this.message, required this.profile});

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMine = message.isMine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: profile.color.withValues(alpha: .18),
              foregroundColor: profile.color,
              child: Icon(profile.icon, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * .70,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isMine
                          ? AppColors.brandPurple
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMine ? 18 : 4),
                        bottomRight: Radius.circular(isMine ? 4 : 18),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isMine ? Colors.white : colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.time),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final String name;
  final StudyProfile profile;

  const _TypingIndicator({required this.name, required this.profile});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: widget.profile.color.withValues(alpha: .18),
            foregroundColor: widget.profile.color,
            child: Icon(widget.profile.icon, size: 18),
          ),
          const SizedBox(width: 8),
          FadeTransition(
            opacity: Tween<double>(begin: .45, end: 1).animate(_controller),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Text('${widget.name} está digitando...'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProfiles extends StatelessWidget {
  final VoidCallback onReset;

  const _EmptyProfiles({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Você viu todos os perfis.',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Ver perfis novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppNavigation extends StatelessWidget {
  final int currentIndex;

  const AppNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        const routes = ['/', '/matches', '/profile'];
        if (index != currentIndex) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.style_outlined),
          selectedIcon: Icon(Icons.style),
          label: 'Perfis',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Matches',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}

class RoundAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const RoundAction({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 66,
                height: 66,
                child: Center(child: Icon(icon, color: color, size: 32)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class SwipeBadge extends StatelessWidget {
  final String text;
  final Color color;

  const SwipeBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyTopics extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyTopics({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Nenhum assunto cadastrado.',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar assunto'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label),
      ],
    );
  }
}

IconData topicIcon(String category) {
  switch (category) {
    case 'Idiomas':
      return Icons.translate;
    case 'Exatas':
      return Icons.calculate_outlined;
    case 'Humanas':
      return Icons.public_outlined;
    case 'Concursos':
      return Icons.assignment_turned_in_outlined;
    default:
      return Icons.code;
  }
}

Color topicColor(String category) {
  switch (category) {
    case 'Idiomas':
      return const Color(0xFF00897B);
    case 'Exatas':
      return const Color(0xFF3949AB);
    case 'Humanas':
      return const Color(0xFF8E24AA);
    case 'Concursos':
      return const Color(0xFFF4511E);
    default:
      return const Color(0xFF6750A4);
  }
}
