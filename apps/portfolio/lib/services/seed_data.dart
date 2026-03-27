import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedPortfolioData() async {
  final db = FirebaseFirestore.instance;

  // Check if already seeded
  final profileDoc = await db.collection('profile').doc('main').get();
  if (profileDoc.exists) return;

  final batch = db.batch();

  // Profile
  batch.set(db.collection('profile').doc('main'), {
    'badge': 'Flutter Developer',
    'heroTitle': "Hi, I'm a\n",
    'heroHighlight': ' Flutter Developer',
    'heroDescription':
        'With over 10+ published apps in stores, I specialize in creating beautiful, performant mobile applications using Flutter. Let\'s bring your ideas to life.',
    'heroImage':
        'https://images.unsplash.com/photo-1719400471588-575b23e27bd7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwcm9mZXNzaW9uYWwlMjBkZXZlbG9wZXIlMjB3b3Jrc3BhY2UlMjBjb2Rpbmd8ZW58MXx8fHwxNzcyMjU0NjE2fDA&ixlib=rb-4.1.0&q=80&w=1080',
    'cvUrl': '',
    'aboutTitle': 'About Me',
    'aboutDescription':
        "I'm a passionate Flutter developer with a track record of delivering high-quality mobile applications. My expertise lies in transforming ideas into polished, production-ready apps that users love.",
    'skillsTitle': 'Skills & Expertise',
    'skillsDescription':
        'A comprehensive toolkit of technical abilities and interpersonal skills refined through years of development.',
    'experienceTitle': 'Work Experience',
    'experienceDescription':
        'My professional journey in mobile app development, building impactful applications for users worldwide.',
    'contactTitle': 'Get In Touch',
    'contactDescription':
        "Have a project in mind or want to collaborate? I'd love to hear from you!",
    'contactEmail': 'your.email@example.com',
    'contactPhone': '+1 (555) 123-4567',
    'contactLocation': 'Your City, Country',
    'contactCtaTitle': "Let's Work Together",
    'contactCtaDescription':
        "I'm currently available for freelance projects and full-time opportunities. Whether you need a new app built from scratch or help with an existing project, I'm here to help bring your vision to life.",
    'footerBrand': 'Flutter Developer',
    'footerDescription':
        'Creating beautiful, performant mobile applications with passion and precision.',
    'copyright': '',
  });

  // Stats
  final statsData = [
    {'value': '10+', 'label': 'Apps Published', 'order': 0},
    {'value': '5+', 'label': 'Years Experience', 'order': 1},
    {'value': '100K+', 'label': 'Downloads', 'order': 2},
  ];
  for (final s in statsData) {
    batch.set(db.collection('stats').doc(), s);
  }

  // Social Links
  final socialData = [
    {'icon': 'github', 'url': 'https://github.com', 'order': 0},
    {'icon': 'linkedin', 'url': 'https://linkedin.com', 'order': 1},
    {'icon': 'envelope', 'url': 'mailto:your.email@example.com', 'order': 2},
  ];
  for (final s in socialData) {
    batch.set(db.collection('social_links').doc(), s);
  }

  // About Features
  final aboutData = [
    {
      'icon': 'code',
      'title': 'Clean Code',
      'description':
          'Writing maintainable, scalable, and well-documented code following best practices.',
      'order': 0,
    },
    {
      'icon': 'smartphone',
      'title': 'Cross-Platform',
      'description':
          'Building beautiful apps for both iOS and Android from a single codebase.',
      'order': 1,
    },
    {
      'icon': 'bolt',
      'title': 'Performance',
      'description':
          'Optimizing apps for smooth 60fps animations and minimal load times.',
      'order': 2,
    },
    {
      'icon': 'people_outline',
      'title': 'User-Centric',
      'description':
          'Creating intuitive interfaces that users love and enjoy using.',
      'order': 3,
    },
  ];
  for (final a in aboutData) {
    batch.set(db.collection('about_features').doc(), a);
  }

  // Technical Skills
  final techData = [
    {'icon': 'code', 'name': 'Flutter & Dart', 'level': 'Expert', 'order': 0},
    {'icon': 'storage', 'name': 'Firebase', 'level': 'Advanced', 'order': 1},
    {'icon': 'bolt', 'name': 'REST APIs', 'level': 'Advanced', 'order': 2},
    {
      'icon': 'view_quilt',
      'name': 'State Management',
      'level': 'Expert',
      'order': 3
    },
    {
      'icon': 'smartphone',
      'name': 'Native Integration',
      'level': 'Advanced',
      'order': 4
    },
    {
      'icon': 'account_tree_outlined',
      'name': 'Git & GitHub',
      'level': 'Advanced',
      'order': 5
    },
    {
      'icon': 'palette_outlined',
      'name': 'UI/UX Design',
      'level': 'Intermediate',
      'order': 6
    },
    {
      'icon': 'data_object',
      'name': 'SQLite & Hive',
      'level': 'Advanced',
      'order': 7
    },
  ];
  for (final t in techData) {
    batch.set(db.collection('technical_skills').doc(), t);
  }

  // Soft Skills
  final softData = [
    {
      'icon': 'chat_bubble_outline',
      'name': 'Communication',
      'description':
          'Clear and effective communication with team and stakeholders',
      'order': 0,
    },
    {
      'icon': 'people_outline',
      'name': 'Team Leadership',
      'description': 'Leading and mentoring development teams to success',
      'order': 1,
    },
    {
      'icon': 'lightbulb_outline',
      'name': 'Problem Solving',
      'description': 'Creative solutions to complex technical challenges',
      'order': 2,
    },
    {
      'icon': 'gps_fixed',
      'name': 'Goal-Oriented',
      'description':
          'Focused on delivering results and meeting objectives',
      'order': 3,
    },
    {
      'icon': 'access_time',
      'name': 'Time Management',
      'description': 'Efficient prioritization and deadline management',
      'order': 4,
    },
    {
      'icon': 'bolt',
      'name': 'Adaptability',
      'description':
          'Quick learner, adapting to new technologies and methodologies',
      'order': 5,
    },
  ];
  for (final s in softData) {
    batch.set(db.collection('soft_skills').doc(), s);
  }

  // Tools
  final toolNames = [
    'Flutter', 'Dart', 'Firebase', 'REST API', 'GraphQL', 'BLoC',
    'Provider', 'Riverpod', 'GetX', 'SQLite', 'Hive', 'SharedPreferences',
    'Git', 'GitHub Actions', 'Fastlane', 'Android Studio', 'VS Code',
    'Xcode', 'Figma', 'Adobe XD', 'Postman', 'Jira', 'Slack', 'CI/CD',
  ];
  for (int i = 0; i < toolNames.length; i++) {
    batch.set(db.collection('tools').doc(), {'name': toolNames[i], 'order': i});
  }

  // Projects
  final projectsData = [
    {
      'title': 'E-Commerce App',
      'description':
          'A full-featured shopping app with payment integration, real-time inventory, and order tracking.',
      'image':
          'https://images.unsplash.com/photo-1723705027411-9bfc3c99c2e9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      'tags': ['Flutter', 'Firebase', 'Stripe', 'BLoC'],
      'downloads': '50K+',
      'rating': 4.5,
      'codeUrl': '',
      'liveUrl': '',
      'tagColor': '',
      'order': 0,
    },
    {
      'title': 'Fitness Tracker',
      'description':
          'Track workouts, calories, and progress with beautiful charts and personalized workout plans.',
      'image':
          'https://images.unsplash.com/photo-1591311630200-ffa9120a540f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      'tags': ['Flutter', 'SQLite', 'Provider', 'Charts'],
      'downloads': '30K+',
      'rating': 4.7,
      'codeUrl': '',
      'liveUrl': '',
      'tagColor': '',
      'order': 1,
    },
    {
      'title': 'Food Delivery',
      'description':
          'Real-time order tracking, restaurant discovery, and seamless checkout experience.',
      'image':
          'https://images.unsplash.com/photo-1605108222700-0d605d9ebafe?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      'tags': ['Flutter', 'Google Maps', 'Firebase', 'Push Notifications'],
      'downloads': '75K+',
      'rating': 4.6,
      'codeUrl': '',
      'liveUrl': '',
      'tagColor': '',
      'order': 2,
    },
    {
      'title': 'Social Media App',
      'description':
          'Connect with friends, share moments, and engage with a vibrant community.',
      'image':
          'https://images.unsplash.com/photo-1661246626039-5429b8f7488a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      'tags': ['Flutter', 'REST API', 'Riverpod', 'Camera'],
      'downloads': '100K+',
      'rating': 4.4,
      'codeUrl': '',
      'liveUrl': '',
      'tagColor': '',
      'order': 3,
    },
    {
      'title': 'Learning Platform',
      'description':
          'Online courses, video streaming, quizzes, and progress tracking for students.',
      'image':
          'https://images.unsplash.com/photo-1646737554389-49329965ef01?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      'tags': ['Flutter', 'Video Player', 'Firebase', 'BLoC'],
      'downloads': '40K+',
      'rating': 4.8,
      'codeUrl': '',
      'liveUrl': '',
      'tagColor': '',
      'order': 4,
    },
    {
      'title': 'Task Management',
      'description':
          'Organize your life with intuitive task lists, reminders, and productivity analytics.',
      'image':
          'https://images.unsplash.com/photo-1661246626039-5429b8f7488a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
      'tags': ['Flutter', 'SQLite', 'Notifications', 'Provider'],
      'downloads': '25K+',
      'rating': 4.5,
      'codeUrl': '',
      'liveUrl': '',
      'tagColor': '',
      'order': 5,
    },
  ];
  for (final p in projectsData) {
    batch.set(db.collection('projects').doc(), p);
  }

  // Experiences
  final experiencesData = [
    {
      'title': 'Senior Flutter Developer',
      'company': 'Tech Solutions Inc.',
      'location': 'San Francisco, CA',
      'period': '2022 - Present',
      'duration': '2 years',
      'description':
          'Lead Flutter developer responsible for architecture and delivery of multiple high-impact mobile applications. Mentor junior developers and establish best practices.',
      'achievements': [
        'Led development of 5+ production apps with 200K+ combined downloads',
        'Improved app performance by 40% through optimization',
        'Established CI/CD pipeline reducing deployment time by 60%',
        'Mentored 5 junior developers',
      ],
      'gradientColor1': '1A3B82F6',
      'gradientColor2': '1AA855F7',
      'order': 0,
    },
    {
      'title': 'Flutter Developer',
      'company': 'Mobile Apps Studio',
      'location': 'Remote',
      'period': '2020 - 2022',
      'duration': '2 years',
      'description':
          'Developed and maintained Flutter applications for various clients across different industries including e-commerce, healthcare, and education.',
      'achievements': [
        'Built 8+ client apps from scratch to store publication',
        'Integrated third-party APIs and payment gateways',
        'Collaborated with designers to create pixel-perfect UIs',
        'Maintained 4.5+ star rating across all published apps',
      ],
      'gradientColor1': '1A22C55E',
      'gradientColor2': '1A14B8A6',
      'order': 1,
    },
    {
      'title': 'Mobile Developer',
      'company': 'Digital Innovations',
      'location': 'New York, NY',
      'period': '2019 - 2020',
      'duration': '1 year',
      'description':
          'Worked on cross-platform mobile development projects, specializing in Flutter after starting with native development.',
      'achievements': [
        'Successfully migrated 2 native apps to Flutter',
        'Reduced codebase by 50% through Flutter migration',
        'Contributed to 4 production apps',
        'Participated in agile development processes',
      ],
      'gradientColor1': '1AF97316',
      'gradientColor2': '1AEF4444',
      'order': 2,
    },
    {
      'title': 'Junior Mobile Developer',
      'company': 'Startup Labs',
      'location': 'Austin, TX',
      'period': '2018 - 2019',
      'duration': '1 year',
      'description':
          'Gained hands-on experience in mobile app development, working on both native and cross-platform projects.',
      'achievements': [
        'Contributed to 3 production apps',
        'Learned Flutter and contributed to migration from native',
        'Fixed 100+ bugs and implemented new features',
        "Achieved 'Employee of the Quarter' award",
      ],
      'gradientColor1': '1AEC4899',
      'gradientColor2': '1AF43F5E',
      'order': 3,
    },
  ];
  for (final e in experiencesData) {
    batch.set(db.collection('experiences').doc(), e);
  }

  // Experience Stats
  final expStatsData = [
    {'value': '6+', 'label': 'Years Experience', 'order': 0},
    {'value': '4', 'label': 'Companies', 'order': 1},
    {'value': '20+', 'label': 'Projects Delivered', 'order': 2},
    {'value': '200K+', 'label': 'Total Downloads', 'order': 3},
  ];
  for (final s in expStatsData) {
    batch.set(db.collection('experience_stats').doc(), s);
  }

  await batch.commit();
}
