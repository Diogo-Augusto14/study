import 'package:flutter/material.dart';

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
      home: isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : DiscoverScreen(store: store),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => DiscoverScreen(store: store),
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
          case '/favorites':
            return MaterialPageRoute(
              builder: (_) => FavoritesScreen(store: store),
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

  Map<String, String> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'level': level,
    'description': description,
  };

  factory StudyTopic.fromJson(Map<String, dynamic> json) => StudyTopic(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    level: json['level'] as String,
    description: json['description'] as String,
  );
}

class StudyStore {
  List<StudyTopic> topics = List.of(_initialTopics);
  Set<String> favoriteIds = {};
  int currentIndex = 0;

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
    currentIndex = 0;
  }

  StudyTopic? get currentTopic =>
      topics.isEmpty ? null : topics[currentIndex % topics.length];

  List<StudyTopic> get favorites =>
      topics.where((topic) => favoriteIds.contains(topic.id)).toList();

  void nextTopic() {
    if (topics.isNotEmpty) currentIndex = (currentIndex + 1) % topics.length;
  }

  void toggleFavorite(StudyTopic topic) {
    if (!favoriteIds.add(topic.id)) favoriteIds.remove(topic.id);
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
    favoriteIds.remove(topic.id);
    if (topics.isEmpty) currentIndex = 0;
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

  void _moveNext({bool favorite = false}) {
    final topic = widget.store.currentTopic;
    if (topic != null &&
        favorite &&
        !widget.store.favoriteIds.contains(topic.id)) {
      widget.store.toggleFavorite(topic);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${topic.title} salvo nos favoritos!')),
      );
    }
    setState(() {
      widget.store.nextTopic();
      dragX = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.store.currentTopic;
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
              'Encontre algo novo para estudar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: topic == null
                  ? _EmptyTopics(
                      onAdd: () => Navigator.pushNamed(context, '/topic/new'),
                    )
                  : GestureDetector(
                      onPanUpdate: (details) =>
                          setState(() => dragX += details.delta.dx),
                      onPanEnd: (_) {
                        if (dragX > 100) _moveNext(favorite: true);
                        if (dragX < -100) _moveNext();
                        if (dragX.abs() <= 100) setState(() => dragX = 0);
                      },
                      child: Transform.translate(
                        offset: Offset(dragX, 0),
                        child: Transform.rotate(
                          angle: dragX / 1200,
                          child: TopicCard(topic: topic, dragX: dragX),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            if (topic != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundAction(
                    icon: Icons.close_rounded,
                    color: Colors.red,
                    label: 'Passar',
                    onTap: _moveNext,
                  ),
                  const SizedBox(width: 24),
                  RoundAction(
                    icon: Icons.favorite_rounded,
                    color: Colors.green,
                    label: 'Quero estudar',
                    onTap: () => _moveNext(favorite: true),
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

class FavoritesScreen extends StatefulWidget {
  final StudyStore store;

  const FavoritesScreen({super.key, required this.store});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favorites = widget.store.favorites;
    return Scaffold(
      appBar: AppBar(title: const Text('Quero estudar')),
      body: favorites.isEmpty
          ? const Center(child: Text('Ainda não há assuntos salvos.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final topic = favorites[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      topicIcon(topic.category),
                      color: topicColor(topic.category),
                    ),
                    title: Text(topic.title),
                    subtitle: Text(topic.description),
                    trailing: IconButton(
                      tooltip: 'Remover favorito',
                      onPressed: () =>
                          setState(() => widget.store.toggleFavorite(topic)),
                      icon: const Icon(Icons.favorite, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const AppNavigation(currentIndex: 1),
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
                    _Stat(value: '${store.favorites.length}', label: 'Salvos'),
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

class TopicCard extends StatelessWidget {
  final StudyTopic topic;
  final double dragX;

  const TopicCard({super.key, required this.topic, required this.dragX});

  @override
  Widget build(BuildContext context) {
    final likedOpacity = (dragX / 120).clamp(0.0, 1.0).toDouble();
    final skippedOpacity = (-dragX / 120).clamp(0.0, 1.0).toDouble();
    final color = topicColor(topic.category);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: .68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .28),
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
              topicIcon(topic.category),
              size: 120,
              color: Colors.white.withValues(alpha: .9),
            ),
          ),
          Opacity(
            opacity: likedOpacity,
            child: const Align(
              alignment: Alignment.topLeft,
              child: SwipeBadge(text: 'QUERO', color: Colors.greenAccent),
            ),
          ),
          Opacity(
            opacity: skippedOpacity,
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
                Chip(
                  label: Text(topic.category),
                  backgroundColor: Colors.white.withValues(alpha: .85),
                ),
                const SizedBox(height: 12),
                Text(
                  topic.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  topic.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Nível: ${topic.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

class AppNavigation extends StatelessWidget {
  final int currentIndex;

  const AppNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        const routes = ['/', '/favorites', '/profile'];
        if (index != currentIndex) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.style_outlined),
          selectedIcon: Icon(Icons.style),
          label: 'Descobrir',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Salvos',
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
