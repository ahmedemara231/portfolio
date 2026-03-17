class ExperienceModel {
  final String? id;
  final String title;
  final String company;
  final String location;
  final String period;
  final String duration;
  final String description;
  final List<String> achievements;
  final String gradientColor1;
  final String gradientColor2;
  final int order;

  const ExperienceModel({
    this.id,
    this.title = '',
    this.company = '',
    this.location = '',
    this.period = '',
    this.duration = '',
    this.description = '',
    this.achievements = const [],
    this.gradientColor1 = '',
    this.gradientColor2 = '',
    this.order = 0,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return ExperienceModel(
      id: id,
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      period: map['period'] ?? '',
      duration: map['duration'] ?? '',
      description: map['description'] ?? '',
      achievements: List<String>.from(map['achievements'] ?? []),
      gradientColor1: map['gradientColor1'] ?? '',
      gradientColor2: map['gradientColor2'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'period': period,
      'duration': duration,
      'description': description,
      'achievements': achievements,
      'gradientColor1': gradientColor1,
      'gradientColor2': gradientColor2,
      'order': order,
    };
  }

  ExperienceModel copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? period,
    String? duration,
    String? description,
    List<String>? achievements,
    String? gradientColor1,
    String? gradientColor2,
    int? order,
  }) {
    return ExperienceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      period: period ?? this.period,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      achievements: achievements ?? this.achievements,
      gradientColor1: gradientColor1 ?? this.gradientColor1,
      gradientColor2: gradientColor2 ?? this.gradientColor2,
      order: order ?? this.order,
    );
  }
}
