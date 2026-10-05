class ProjectModel {
  final String? id;
  final String title;
  final String description;
  final String image;
  final List<String> tags;
  final String downloads;
  final double rating;
  final String codeUrl;
  final String liveUrl;
  final String googlePlayUrl;
  final String appStoreUrl;
  final String tagColor;
  final int order;

  final String slug;
  final String category;
  final String overview;
  final String audience;
  final String role;
  final String challenges;
  final String decisions;
  final String outcomes;
  final String date;
  final String imageAlt;
  final String seoTitle;
  final String seoDescription;
  final String status;
  final String imageKind;
  final bool featured;
  final int featuredOrder;
  final List<String> features;
  final List<String> capabilities;
  final List<String> technologies;
  final List<Map<String, dynamic>> gallery;
  final List<Map<String, dynamic>> additionalLinks;

  const ProjectModel({
    this.slug = '',
    this.category = '',
    this.overview = '',
    this.audience = '',
    this.role = '',
    this.challenges = '',
    this.decisions = '',
    this.outcomes = '',
    this.date = '',
    this.imageAlt = '',
    this.seoTitle = '',
    this.seoDescription = '',
    this.status = 'published',
    this.imageKind = 'placeholder',
    this.featured = false,
    this.featuredOrder = 0,
    this.features = const [],
    this.capabilities = const [],
    this.technologies = const [],
    this.gallery = const [],
    this.additionalLinks = const [],
    this.id,
    this.title = '',
    this.description = '',
    this.image = '',
    this.tags = const [],
    this.downloads = '',
    this.rating = 0,
    this.codeUrl = '',
    this.liveUrl = '',
    this.googlePlayUrl = '',
    this.appStoreUrl = '',
    this.tagColor = '',
    this.order = 0,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return ProjectModel(
      slug: map['slug'] ?? '',
      category: map['category'] ?? '',
      overview: map['overview'] ?? '',
      audience: map['audience'] ?? '',
      role: map['role'] ?? '',
      challenges: map['challenges'] ?? '',
      decisions: map['decisions'] ?? '',
      outcomes: map['outcomes'] ?? '',
      date: map['date'] ?? '',
      imageAlt: map['imageAlt'] ?? '',
      seoTitle: map['seoTitle'] ?? '',
      seoDescription: map['seoDescription'] ?? '',
      status: map['status'] ?? 'published',
      imageKind: map['imageKind'] ?? 'placeholder',
      featured: map['featured'] == true,
      featuredOrder: (map['featuredOrder'] as num?)?.toInt() ?? 0,
      features: List<String>.from(map['features'] ?? []),
      capabilities: List<String>.from(map['capabilities'] ?? []),
      technologies: List<String>.from(map['technologies'] ?? []),
      gallery: (map['gallery'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      additionalLinks: (map['additionalLinks'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      downloads: map['downloads'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      codeUrl: map['codeUrl'] ?? '',
      liveUrl: map['liveUrl'] ?? '',
      googlePlayUrl: map['googlePlayUrl'] ?? '',
      appStoreUrl: map['appStoreUrl'] ?? '',
      tagColor: map['tagColor'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slug': slug,
      'category': category,
      'overview': overview,
      'audience': audience,
      'role': role,
      'challenges': challenges,
      'decisions': decisions,
      'outcomes': outcomes,
      'date': date,
      'imageAlt': imageAlt,
      'seoTitle': seoTitle,
      'seoDescription': seoDescription,
      'status': status,
      'imageKind': imageKind,
      'featured': featured,
      'featuredOrder': featuredOrder,
      'features': features,
      'capabilities': capabilities,
      'technologies': technologies,
      'gallery': gallery,
      'additionalLinks': additionalLinks,
      'title': title,
      'description': description,
      'image': image,
      'tags': tags,
      'downloads': downloads,
      'rating': rating,
      'codeUrl': codeUrl,
      'liveUrl': liveUrl,
      'googlePlayUrl': googlePlayUrl,
      'appStoreUrl': appStoreUrl,
      'tagColor': tagColor,
      'order': order,
    };
  }

  ProjectModel copyWith({
    String? slug,
    String? category,
    String? overview,
    String? audience,
    String? role,
    String? challenges,
    String? decisions,
    String? outcomes,
    String? date,
    String? imageAlt,
    String? seoTitle,
    String? seoDescription,
    String? status,
    String? imageKind,
    bool? featured,
    int? featuredOrder,
    List<String>? features,
    List<String>? capabilities,
    List<String>? technologies,
    List<Map<String, dynamic>>? gallery,
    List<Map<String, dynamic>>? additionalLinks,
    String? id,
    String? title,
    String? description,
    String? image,
    List<String>? tags,
    String? downloads,
    double? rating,
    String? codeUrl,
    String? liveUrl,
    String? googlePlayUrl,
    String? appStoreUrl,
    String? tagColor,
    int? order,
  }) {
    return ProjectModel(
      slug: slug ?? this.slug,
      category: category ?? this.category,
      overview: overview ?? this.overview,
      audience: audience ?? this.audience,
      role: role ?? this.role,
      challenges: challenges ?? this.challenges,
      decisions: decisions ?? this.decisions,
      outcomes: outcomes ?? this.outcomes,
      date: date ?? this.date,
      imageAlt: imageAlt ?? this.imageAlt,
      seoTitle: seoTitle ?? this.seoTitle,
      seoDescription: seoDescription ?? this.seoDescription,
      status: status ?? this.status,
      imageKind: imageKind ?? this.imageKind,
      featured: featured ?? this.featured,
      featuredOrder: featuredOrder ?? this.featuredOrder,
      features: features ?? this.features,
      capabilities: capabilities ?? this.capabilities,
      technologies: technologies ?? this.technologies,
      gallery: gallery ?? this.gallery,
      additionalLinks: additionalLinks ?? this.additionalLinks,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      tags: tags ?? this.tags,
      downloads: downloads ?? this.downloads,
      rating: rating ?? this.rating,
      codeUrl: codeUrl ?? this.codeUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      googlePlayUrl: googlePlayUrl ?? this.googlePlayUrl,
      appStoreUrl: appStoreUrl ?? this.appStoreUrl,
      tagColor: tagColor ?? this.tagColor,
      order: order ?? this.order,
    );
  }
}
