enum FieldKind {
  text,
  multiline,
  lines,
  number,
  toggle,
  select,
  url,
  email,
  month,
  gallery,
  links,
}

class ContentField {
  final String key, label, group, help;
  final FieldKind kind;
  final bool required;
  final List<String> choices;
  const ContentField(
    this.key,
    this.label, {
    this.group = 'Content',
    this.kind = FieldKind.text,
    this.help = '',
    this.required = false,
    this.choices = const [],
  });
}

class ContentSchema {
  final String collection, title, singular, nameKey, description;
  final List<ContentField> fields;
  const ContentSchema(
    this.collection,
    this.title,
    this.singular,
    this.nameKey,
    this.description,
    this.fields,
  );
}

const projectSchema = ContentSchema(
  'projects',
  'Projects',
  'project',
  'title',
  'Curate the collection, write case studies, and choose what leads.',
  [
    ContentField(
      'title',
      'Project name',
      group: 'The essentials',
      required: true,
    ),
    ContentField(
      'slug',
      'Page address',
      group: 'The essentials',
      required: true,
      help:
          'Lowercase words separated by hyphens. Changing this breaks shared links.',
    ),
    ContentField(
      'category',
      'Product category',
      group: 'The essentials',
      required: true,
      help:
          'Use a small set of clear categories, such as Services, Marketplace, or Fitness.',
    ),
    ContentField(
      'description',
      'Short purpose',
      group: 'The essentials',
      kind: FieldKind.multiline,
      required: true,
    ),
    ContentField(
      'date',
      'Project date',
      group: 'The essentials',
      help: 'For example, January 2026 or May–July 2025.',
    ),
    ContentField(
      'status',
      'Publication',
      group: 'Visibility & selection',
      kind: FieldKind.select,
      choices: ['draft', 'published'],
    ),
    ContentField(
      'featured',
      'Feature on the home page',
      group: 'Visibility & selection',
      kind: FieldKind.toggle,
      help: 'The first four featured projects are displayed on the home page.',
    ),
    ContentField(
      'featuredOrder',
      'Featured position',
      group: 'Visibility & selection',
      kind: FieldKind.number,
      help: 'Lower numbers appear first. Independent of collection order.',
    ),
    ContentField(
      'overview',
      'Product overview',
      group: 'Case study',
      kind: FieldKind.multiline,
    ),
    ContentField(
      'audience',
      'Intended users',
      group: 'Case study',
      kind: FieldKind.multiline,
    ),
    ContentField(
      'role',
      'My role & contribution',
      group: 'Case study',
      kind: FieldKind.multiline,
      help: 'Include only contributions you can substantiate.',
    ),
    ContentField(
      'features',
      'Features & user journeys',
      group: 'Case study',
      kind: FieldKind.lines,
      help: 'One feature per line.',
    ),
    ContentField(
      'challenges',
      'Technical challenges',
      group: 'Case study',
      kind: FieldKind.multiline,
    ),
    ContentField(
      'decisions',
      'Implementation decisions',
      group: 'Case study',
      kind: FieldKind.multiline,
    ),
    ContentField(
      'technologies',
      'Technologies & integrations',
      group: 'Case study',
      kind: FieldKind.lines,
      help: 'Only technologies verified for this project. One per line.',
    ),
    ContentField(
      'outcomes',
      'Supported outcomes',
      group: 'Case study',
      kind: FieldKind.multiline,
      help: 'Leave blank when there is no evidence.',
    ),
    ContentField(
      'capabilities',
      'Preview capabilities',
      group: 'Case study',
      kind: FieldKind.lines,
      help:
          'Use short, verified capabilities. The first three appear in the preview.',
    ),
    ContentField(
      'gallery',
      'Screenshot gallery',
      group: 'Imagery',
      kind: FieldKind.gallery,
    ),
    ContentField(
      'image',
      'Fallback image URL',
      group: 'Imagery',
      kind: FieldKind.url,
      help:
          'Used when the gallery is empty. A verified application image or logo.',
    ),
    ContentField('imageAlt', 'Fallback image description', group: 'Imagery'),
    ContentField(
      'imageKind',
      'Fallback image type',
      group: 'Imagery',
      kind: FieldKind.select,
      choices: ['placeholder', 'screenshot', 'logo'],
      help:
          'Legacy images stay hidden until you confirm that they belong to this application.',
    ),
    ContentField(
      'googlePlayUrl',
      'Google Play URL',
      group: 'Links',
      kind: FieldKind.url,
    ),
    ContentField(
      'appStoreUrl',
      'App Store URL',
      group: 'Links',
      kind: FieldKind.url,
    ),
    ContentField('liveUrl', 'Website URL', group: 'Links', kind: FieldKind.url),
    ContentField(
      'codeUrl',
      'Source code URL',
      group: 'Links',
      kind: FieldKind.url,
    ),
    ContentField(
      'additionalLinks',
      'Other verified links',
      group: 'Links',
      kind: FieldKind.links,
      help: 'Use for a connected provider app or other relevant destination.',
    ),
    ContentField(
      'seoTitle',
      'Page title',
      group: 'Search & sharing',
      help: 'Optional. Defaults to the project name and your name.',
    ),
    ContentField(
      'seoDescription',
      'Page description',
      group: 'Search & sharing',
      kind: FieldKind.multiline,
      help: 'Optional. Defaults to the short purpose.',
    ),
    ContentField(
      'tags',
      'Legacy tags',
      group: 'Existing content',
      kind: FieldKind.lines,
      help:
          'Preserved for compatibility. Use preview capabilities for the redesigned site.',
    ),
    ContentField(
      'downloads',
      'Existing download figure',
      group: 'Existing content',
      help:
          'Retained in storage. Only publish evidence-backed outcomes in the case study.',
    ),
    ContentField(
      'rating',
      'Existing rating',
      group: 'Existing content',
      help: 'Retained in storage; not used in the public preview.',
    ),
  ],
);
const profileFields = [
  ContentField('name', 'Name', group: 'Identity', required: true),
  ContentField(
    'professionalTitle',
    'Professional title',
    group: 'Identity',
    required: true,
  ),
  ContentField('contactLocation', 'Location', group: 'Identity'),
  ContentField(
    'heroTitle',
    'Hero headline',
    group: 'Introduction',
    kind: FieldKind.multiline,
    required: true,
  ),
  ContentField('heroHighlight', 'Additional hero line', group: 'Introduction'),
  ContentField(
    'heroDescription',
    'Introduction',
    group: 'Introduction',
    kind: FieldKind.multiline,
    required: true,
  ),
  ContentField(
    'availabilityStatus',
    'Availability',
    group: 'Introduction',
    kind: FieldKind.select,
    choices: ['', 'available', 'open', 'unavailable'],
  ),
  ContentField('availabilityNote', 'Availability note', group: 'Introduction'),
  ContentField(
    'contactFormEnabled',
    'Show contact form',
    group: 'CV & contact',
    kind: FieldKind.toggle,
    help:
        'Firebase mode requires Anonymous Authentication. Messages are stored in your private inbox.',
  ),
  ContentField(
    'cvUrl',
    'CV URL or uploaded PDF',
    group: 'CV & contact',
    kind: FieldKind.url,
    help:
        'Upload a PDF below or use a working URL. Blank disables the download button.',
  ),
  ContentField('cvLabel', 'CV file label', group: 'CV & contact'),
  ContentField(
    'contactEmail',
    'Email',
    group: 'CV & contact',
    kind: FieldKind.email,
    required: true,
  ),
  ContentField('contactPhone', 'Phone', group: 'CV & contact'),
  ContentField(
    'contactTitle',
    'Contact headline',
    group: 'CV & contact',
    kind: FieldKind.multiline,
  ),
  ContentField(
    'contactDescription',
    'Contact introduction',
    group: 'CV & contact',
    kind: FieldKind.multiline,
  ),
  ContentField('aboutTitle', 'About heading', group: 'About & languages'),
  ContentField(
    'aboutDescription',
    'About introduction',
    group: 'About & languages',
    kind: FieldKind.multiline,
  ),
  ContentField(
    'languages',
    'Languages',
    group: 'About & languages',
    kind: FieldKind.multiline,
  ),
  ContentField(
    'projectsTitle',
    'Selected work heading',
    group: 'Section introductions',
  ),
  ContentField(
    'projectsDescription',
    'Selected work introduction',
    group: 'Section introductions',
    kind: FieldKind.multiline,
  ),
  ContentField(
    'experienceTitle',
    'Experience heading',
    group: 'Section introductions',
  ),
  ContentField(
    'experienceDescription',
    'Experience introduction',
    group: 'Section introductions',
    kind: FieldKind.multiline,
  ),
  ContentField(
    'packagesTitle',
    'Open source heading',
    group: 'Section introductions',
    kind: FieldKind.multiline,
  ),
  ContentField(
    'packagesDescription',
    'Open source introduction',
    group: 'Section introductions',
    kind: FieldKind.multiline,
  ),
  ContentField(
    'skillsTitle',
    'Capabilities heading',
    group: 'Section introductions',
  ),
  ContentField(
    'skillsDescription',
    'Capabilities introduction',
    group: 'Section introductions',
    kind: FieldKind.multiline,
  ),
  ContentField(
    'copyright',
    'Copyright line',
    group: 'Footer',
    help: 'Leave blank for the current year and your name.',
  ),
  ContentField('badge', 'Legacy professional badge', group: 'Existing content'),
  ContentField(
    'heroImage',
    'Legacy hero image',
    group: 'Existing content',
    kind: FieldKind.url,
  ),
  ContentField(
    'contactCtaTitle',
    'Legacy contact CTA title',
    group: 'Existing content',
  ),
  ContentField(
    'contactCtaDescription',
    'Legacy contact CTA description',
    group: 'Existing content',
    kind: FieldKind.multiline,
  ),
  ContentField('footerBrand', 'Legacy footer brand', group: 'Existing content'),
  ContentField(
    'footerDescription',
    'Legacy footer description',
    group: 'Existing content',
    kind: FieldKind.multiline,
  ),
];
const metadataFields = [
  ContentField('seoTitle', 'Page title', required: true),
  ContentField(
    'seoDescription',
    'Search & sharing description',
    kind: FieldKind.multiline,
    required: true,
  ),
  ContentField(
    'siteUrl',
    'Public site URL',
    kind: FieldKind.url,
    required: true,
    help:
        'Used for canonical links, sitemap generation, and the Open portfolio action.',
  ),
  ContentField(
    'socialImage',
    'Social preview image URL',
    kind: FieldKind.url,
    help: 'Use an absolute public image URL, ideally 1200 × 630.',
  ),
];
const schemas = [
  projectSchema,
  ContentSchema(
    'experiences',
    'Experience',
    'experience',
    'company',
    'Present your work, ownership, collaboration, and release experience.',
    [
      ContentField('company', 'Company or engagement', required: true),
      ContentField('title', 'Role', required: true),
      ContentField('location', 'Location'),
      ContentField(
        'startDate',
        'Start month',
        kind: FieldKind.month,
        required: true,
      ),
      ContentField(
        'endDate',
        'End month',
        kind: FieldKind.month,
        help: 'Leave blank for a current role.',
      ),
      ContentField('current', 'Current role', kind: FieldKind.toggle),
      ContentField(
        'period',
        'Date label',
        help: 'Optional. Generated from months when blank.',
      ),
      ContentField('description', 'Summary', kind: FieldKind.multiline),
      ContentField(
        'achievements',
        'Contributions',
        kind: FieldKind.lines,
        help: 'One concise contribution per line.',
      ),
    ],
  ),
  ContentSchema(
    'packages',
    'Flutter packages',
    'package',
    'name',
    'Explain the problem each reusable package solves.',
    [
      ContentField('name', 'Package name', required: true),
      ContentField('subtitle', 'Short purpose'),
      ContentField(
        'description',
        'Explanation',
        kind: FieldKind.multiline,
        required: true,
      ),
      ContentField('url', 'pub.dev URL', kind: FieldKind.url, required: true),
      ContentField('date', 'Published date'),
    ],
  ),
  ContentSchema(
    'technical_skills',
    'Capabilities',
    'capability',
    'name',
    'Group skills by the work they enable. No proficiency scores.',
    [
      ContentField('name', 'Capability group', required: true),
      ContentField('description', 'Description', kind: FieldKind.multiline),
      ContentField(
        'items',
        'Skills & tools',
        kind: FieldKind.lines,
        help: 'One skill per line.',
      ),
      ContentField(
        'projectIds',
        'Related projects',
        kind: FieldKind.lines,
        help:
            'Select projects that demonstrate this capability. Only verified relationships.',
      ),
    ],
  ),
  ContentSchema(
    'education',
    'Education',
    'education entry',
    'title',
    'Degrees, institutions, and dates.',
    [
      ContentField('title', 'Degree', required: true),
      ContentField('institution', 'Institution', required: true),
      ContentField('startDate', 'Start month', kind: FieldKind.month),
      ContentField('endDate', 'End month', kind: FieldKind.month),
      ContentField(
        'period',
        'Date label',
        help: 'Generated from months when blank.',
      ),
      ContentField('description', 'Details', kind: FieldKind.multiline),
    ],
  ),
  ContentSchema(
    'stats',
    'Credibility indicators',
    'indicator',
    'label',
    'CV-backed facts shown beneath your introduction.',
    [
      ContentField('value', 'Value', required: true),
      ContentField('label', 'Label', required: true),
    ],
  ),
  ContentSchema(
    'social_links',
    'Social links',
    'link',
    'label',
    'The contact destinations shown on your public site.',
    [
      ContentField('label', 'Display label', required: true),
      ContentField('icon', 'Legacy icon name'),
      ContentField('url', 'Destination', kind: FieldKind.url, required: true),
    ],
  ),
  ContentSchema(
    'soft_skills',
    'Collaboration skills',
    'skill',
    'name',
    'Preserved existing collaboration content.',
    [
      ContentField('name', 'Name', required: true),
      ContentField('description', 'Description', kind: FieldKind.multiline),
      ContentField('icon', 'Icon name'),
    ],
  ),
  ContentSchema(
    'about_features',
    'About details',
    'detail',
    'title',
    'Additional personal details, preserved from the existing site.',
    [
      ContentField('title', 'Title', required: true),
      ContentField('description', 'Description', kind: FieldKind.multiline),
      ContentField('icon', 'Icon name'),
    ],
  ),
  ContentSchema(
    'tools',
    'Additional tools',
    'tool',
    'name',
    'Preserved tool collection.',
    [ContentField('name', 'Tool name', required: true)],
  ),
  ContentSchema(
    'experience_stats',
    'Legacy experience indicators',
    'indicator',
    'label',
    'Preserved data from the previous experience section.',
    [
      ContentField('value', 'Value', required: true),
      ContentField('label', 'Label', required: true),
    ],
  ),
];
