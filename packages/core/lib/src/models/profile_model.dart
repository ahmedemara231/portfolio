class ProfileModel {
  final String badge;
  final String heroTitle;
  final String heroHighlight;
  final String heroDescription;
  final String heroImage;
  final String cvUrl;
  final String aboutTitle;
  final String aboutDescription;
  final String skillsTitle;
  final String skillsDescription;
  final String experienceTitle;
  final String experienceDescription;
  final String contactTitle;
  final String contactDescription;
  final String contactEmail;
  final String contactPhone;
  final String contactLocation;
  final String contactCtaTitle;
  final String contactCtaDescription;
  final String footerBrand;
  final String footerDescription;
  final String copyright;

  const ProfileModel({
    this.badge = '',
    this.heroTitle = '',
    this.heroHighlight = '',
    this.heroDescription = '',
    this.heroImage = '',
    this.cvUrl = '',
    this.aboutTitle = '',
    this.aboutDescription = '',
    this.skillsTitle = '',
    this.skillsDescription = '',
    this.experienceTitle = '',
    this.experienceDescription = '',
    this.contactTitle = '',
    this.contactDescription = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.contactLocation = '',
    this.contactCtaTitle = '',
    this.contactCtaDescription = '',
    this.footerBrand = '',
    this.footerDescription = '',
    this.copyright = '',
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      badge: map['badge'] ?? '',
      heroTitle: map['heroTitle'] ?? '',
      heroHighlight: map['heroHighlight'] ?? '',
      heroDescription: map['heroDescription'] ?? '',
      heroImage: map['heroImage'] ?? '',
      cvUrl: map['cvUrl'] ?? '',
      aboutTitle: map['aboutTitle'] ?? '',
      aboutDescription: map['aboutDescription'] ?? '',
      skillsTitle: map['skillsTitle'] ?? '',
      skillsDescription: map['skillsDescription'] ?? '',
      experienceTitle: map['experienceTitle'] ?? '',
      experienceDescription: map['experienceDescription'] ?? '',
      contactTitle: map['contactTitle'] ?? '',
      contactDescription: map['contactDescription'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      contactLocation: map['contactLocation'] ?? '',
      contactCtaTitle: map['contactCtaTitle'] ?? '',
      contactCtaDescription: map['contactCtaDescription'] ?? '',
      footerBrand: map['footerBrand'] ?? '',
      footerDescription: map['footerDescription'] ?? '',
      copyright: map['copyright'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'badge': badge,
      'heroTitle': heroTitle,
      'heroHighlight': heroHighlight,
      'heroDescription': heroDescription,
      'heroImage': heroImage,
      'cvUrl': cvUrl,
      'aboutTitle': aboutTitle,
      'aboutDescription': aboutDescription,
      'skillsTitle': skillsTitle,
      'skillsDescription': skillsDescription,
      'experienceTitle': experienceTitle,
      'experienceDescription': experienceDescription,
      'contactTitle': contactTitle,
      'contactDescription': contactDescription,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'contactLocation': contactLocation,
      'contactCtaTitle': contactCtaTitle,
      'contactCtaDescription': contactCtaDescription,
      'footerBrand': footerBrand,
      'footerDescription': footerDescription,
      'copyright': copyright,
    };
  }

  ProfileModel copyWith({
    String? badge,
    String? heroTitle,
    String? heroHighlight,
    String? heroDescription,
    String? heroImage,
    String? cvUrl,
    String? aboutTitle,
    String? aboutDescription,
    String? skillsTitle,
    String? skillsDescription,
    String? experienceTitle,
    String? experienceDescription,
    String? contactTitle,
    String? contactDescription,
    String? contactEmail,
    String? contactPhone,
    String? contactLocation,
    String? contactCtaTitle,
    String? contactCtaDescription,
    String? footerBrand,
    String? footerDescription,
    String? copyright,
  }) {
    return ProfileModel(
      badge: badge ?? this.badge,
      heroTitle: heroTitle ?? this.heroTitle,
      heroHighlight: heroHighlight ?? this.heroHighlight,
      heroDescription: heroDescription ?? this.heroDescription,
      heroImage: heroImage ?? this.heroImage,
      cvUrl: cvUrl ?? this.cvUrl,
      aboutTitle: aboutTitle ?? this.aboutTitle,
      aboutDescription: aboutDescription ?? this.aboutDescription,
      skillsTitle: skillsTitle ?? this.skillsTitle,
      skillsDescription: skillsDescription ?? this.skillsDescription,
      experienceTitle: experienceTitle ?? this.experienceTitle,
      experienceDescription: experienceDescription ?? this.experienceDescription,
      contactTitle: contactTitle ?? this.contactTitle,
      contactDescription: contactDescription ?? this.contactDescription,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactLocation: contactLocation ?? this.contactLocation,
      contactCtaTitle: contactCtaTitle ?? this.contactCtaTitle,
      contactCtaDescription: contactCtaDescription ?? this.contactCtaDescription,
      footerBrand: footerBrand ?? this.footerBrand,
      footerDescription: footerDescription ?? this.footerDescription,
      copyright: copyright ?? this.copyright,
    );
  }
}
