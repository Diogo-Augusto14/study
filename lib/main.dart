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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyMatch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        scaffoldBackgroundColor: const Color(0xFFFAF8FF),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
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
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color brandPurple = Color(0xFF6366F1);

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
      Navigator.of(context).pushReplacementNamed('/home');
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
      backgroundColor: brandPurple,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(scale: _logoScale, child: _buildLogo()),
            ),
            const SizedBox(height: 8),
            FadeTransition(opacity: _textFade, child: _buildWelcomeText()),
          ],
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

  const ChatMessage({required this.text, required this.isMine});
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
                          child: ProfileCard(profile: profile, dragX: dragX),
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
                    color: Colors.red,
                    label: 'Passar',
                    onTap: _passCurrent,
                  ),
                  const SizedBox(width: 24),
                  RoundAction(
                    icon: Icons.favorite_rounded,
                    color: Colors.green,
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
      appBar: AppBar(title: const Text('Seus matches')),
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

class MatchScreen extends StatelessWidget {
  final StudyStore store;
  final StudyProfile profile;

  const MatchScreen({super.key, required this.store, required this.profile});

  @override
  Widget build(BuildContext context) {
    final shared = store.sharedInterests(profile);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Colors.pink,
                  size: 76,
                ),
                const SizedBox(height: 16),
                Text(
                  'É um match!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Você e ${profile.name} podem trocar ideias e estudar juntos.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      child: Icon(Icons.person, size: 38),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.favorite, color: Colors.pink, size: 30),
                    ),
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: profile.color.withValues(alpha: .15),
                      foregroundColor: profile.color,
                      child: Icon(profile.icon, size: 38),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('Interesses em comum'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: shared
                      .map((interest) => Chip(label: Text(interest)))
                      .toList(),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
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
                  child: const Text('Continuar vendo perfis'),
                ),
              ],
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
  var _isTyping = false;
  var _containsBlockedWord = false;

  @override
  void initState() {
    super.initState();
    final shared = widget.store.sharedInterests(widget.profile).join(' e ');
    _messages = [
      ChatMessage(
        text:
            'Oi! Que bom encontrar alguém que também curte $shared. Como você está estudando esses assuntos?',
        isMine: false,
      ),
    ];
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
        _messages.add(ChatMessage(text: _automaticReply(), isMine: false));
      });
    });
  }

  String _automaticReply() {
    switch (widget.profile.id) {
      case 'luiza':
        return 'Eu também! Termodinâmica está rendendo uma batalha hoje, mas o episódio novo do dorama salvou a noite 😄. Que tal fazer uma revisão de 40 minutos esta semana?';
      case 'pedro':
        return 'Boa! Estou montando um projetinho em Flutter para praticar. Se quiser, a gente pode comparar as telas e trocar dicas depois da aula.';
      default:
        return 'Gostei da ideia! Podemos combinar um horário curto e deixar os estudos mais leves.';
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
            Text(widget.profile.name),
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
                    return _TypingIndicator(name: widget.profile.name);
                  }
                  return _ChatBubble(message: _messages[index]);
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
                      decoration: const InputDecoration(
                        hintText: 'Escreva uma mensagem...',
                        border: OutlineInputBorder(),
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
                Icon(
                  Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 74,
                ),
                const SizedBox(height: 20),
                Text(
                  'Denúncia enviada',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Usuário denunciado. Nossa equipe avaliará a conta nas próximas 24h.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
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
      appBar: AppBar(title: const Text('Meu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(radius: 46, child: Icon(Icons.person, size: 50)),
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [profile.color, profile.color.withValues(alpha: .68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: profile.color.withValues(alpha: .28),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Icon(
              profile.icon,
              size: 128,
              color: Colors.white.withValues(alpha: .9),
            ),
          ),
          Opacity(
            opacity: likeOpacity,
            child: const Align(
              alignment: Alignment.topLeft,
              child: SwipeBadge(text: 'CURTIR', color: Colors.greenAccent),
            ),
          ),
          Opacity(
            opacity: passOpacity,
            child: const Align(
              alignment: Alignment.topRight,
              child: SwipeBadge(text: 'PASSAR', color: Colors.redAccent),
            ),
          ),
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
                Text(
                  profile.course,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.interests
                      .map(
                        (interest) => Chip(
                          label: Text(interest),
                          backgroundColor: Colors.white.withValues(alpha: .85),
                        ),
                      )
                      .toList(),
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

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .78,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: message.isMine
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(message.text),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final String name;

  const _TypingIndicator({required this.name});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('$name está digitando...'),
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
        FloatingActionButton(
          heroTag: label,
          backgroundColor: Colors.white,
          foregroundColor: color,
          onPressed: onTap,
          child: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(label),
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
