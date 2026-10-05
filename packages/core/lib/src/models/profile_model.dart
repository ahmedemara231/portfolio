class ProfileModel {
  final String badge;
  final String heroTitle;
  final String heroHighlight;
  final String heroDescription;
  final String heroImage;
  final String cvUrl;
  final String availabilityStatus; // '' | 'available' | 'open' | 'unavailable'
  final String availabilityNote;
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

  final String name;
  final String professionalTitle;
  final String languages;
  final String seoTitle;
  final String seoDescription;
  final String siteUrl;
  final String socialImage;
  final String cvLabel;
  final String projectsTitle;
  final String projectsDescription;
  final String packagesTitle;
  final String packagesDescription;
  final bool contactFormEnabled;

  const ProfileModel({
    this.name = '',
    this.professionalTitle = '',
    this.languages = '',
    this.seoTitle = '',
    this.seoDescription = '',
    this.siteUrl = '',
    this.socialImage = '',
    this.cvLabel = '',
    this.projectsTitle = '',
    this.projectsDescription = '',
    this.packagesTitle = '',
    this.packagesDescription = '',
    this.contactFormEnabled = true,
    this.badge = '',
    this.heroTitle = '',
    this.heroHighlight = '',
    this.heroDescription = '',
    this.heroImage = '',
    this.cvUrl = '',
    this.availabilityStatus = '',
    this.availabilityNote = '',
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
      name: map['name'] ?? '',
      professionalTitle: map['professionalTitle'] ?? '',
      languages: map['languages'] ?? '',
      seoTitle: map['seoTitle'] ?? '',
      seoDescription: map['seoDescription'] ?? '',
      siteUrl: map['siteUrl'] ?? '',
      socialImage: map['socialImage'] ?? '',
      cvLabel: map['cvLabel'] ?? '',
      projectsTitle: map['projectsTitle'] ?? '',
      projectsDescription: map['projectsDescription'] ?? '',
      packagesTitle: map['packagesTitle'] ?? '',
      packagesDescription: map['packagesDescription'] ?? '',
      contactFormEnabled: map['contactFormEnabled'] != false,
      badge: map['badge'] ?? '',
      heroTitle: map['heroTitle'] ?? '',
      heroHighlight: map['heroHighlight'] ?? '',
      heroDescription: map['heroDescription'] ?? '',
      heroImage: map['heroImage'] ?? '',
      cvUrl: map['cvUrl'] ?? '',
      availabilityStatus: map['availabilityStatus'] ?? '',
      availabilityNote: map['availabilityNote'] ?? '',
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
      'name': name,
      'professionalTitle': professionalTitle,
      'languages': languages,
      'seoTitle': seoTitle,
      'seoDescription': seoDescription,
      'siteUrl': siteUrl,
      'socialImage': socialImage,
      'cvLabel': cvLabel,
      'projectsTitle': projectsTitle,
      'projectsDescription': projectsDescription,
      'packagesTitle': packagesTitle,
      'packagesDescription': packagesDescription,
      'contactFormEnabled': contactFormEnabled,
      'badge': badge,
      'heroTitle': heroTitle,
      'heroHighlight': heroHighlight,
      'heroDescription': heroDescription,
      'heroImage': heroImage,
      'cvUrl': cvUrl,
      'availabilityStatus': availabilityStatus,
      'availabilityNote': availabilityNote,
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
    String? name,
    String? professionalTitle,
    String? languages,
    String? seoTitle,
    String? seoDescription,
    String? siteUrl,
    String? socialImage,
    String? cvLabel,
    String? projectsTitle,
    String? projectsDescription,
    String? packagesTitle,
    String? packagesDescription,
    bool? contactFormEnabled,
    String? badge,
    String? heroTitle,
    String? heroHighlight,
    String? heroDescription,
    String? heroImage,
    String? cvUrl,
    String? availabilityStatus,
    String? availabilityNote,
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
      name: name ?? this.name,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      languages: languages ?? this.languages,
      seoTitle: seoTitle ?? this.seoTitle,
      seoDescription: seoDescription ?? this.seoDescription,
      siteUrl: siteUrl ?? this.siteUrl,
      socialImage: socialImage ?? this.socialImage,
      cvLabel: cvLabel ?? this.cvLabel,
      projectsTitle: projectsTitle ?? this.projectsTitle,
      projectsDescription: projectsDescription ?? this.projectsDescription,
      packagesTitle: packagesTitle ?? this.packagesTitle,
      packagesDescription: packagesDescription ?? this.packagesDescription,
      contactFormEnabled: contactFormEnabled ?? this.contactFormEnabled,
      badge: badge ?? this.badge,
      heroTitle: heroTitle ?? this.heroTitle,
      heroHighlight: heroHighlight ?? this.heroHighlight,
      heroDescription: heroDescription ?? this.heroDescription,
      heroImage: heroImage ?? this.heroImage,
      cvUrl: cvUrl ?? this.cvUrl,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      availabilityNote: availabilityNote ?? this.availabilityNote,
      aboutTitle: aboutTitle ?? this.aboutTitle,
      aboutDescription: aboutDescription ?? this.aboutDescription,
      skillsTitle: skillsTitle ?? this.skillsTitle,
      skillsDescription: skillsDescription ?? this.skillsDescription,
      experienceTitle: experienceTitle ?? this.experienceTitle,
      experienceDescription:
          experienceDescription ?? this.experienceDescription,
      contactTitle: contactTitle ?? this.contactTitle,
      contactDescription: contactDescription ?? this.contactDescription,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactLocation: contactLocation ?? this.contactLocation,
      contactCtaTitle: contactCtaTitle ?? this.contactCtaTitle,
      contactCtaDescription:
          contactCtaDescription ?? this.contactCtaDescription,
      footerBrand: footerBrand ?? this.footerBrand,
      footerDescription: footerDescription ?? this.footerDescription,
      copyright: copyright ?? this.copyright,
    );
  }
}
