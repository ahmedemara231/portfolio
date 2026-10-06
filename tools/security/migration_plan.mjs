// Plan additive schema updates without replacing any existing content.
export function planCollectionMigration(collection, documents, {featureLegacyProjects = false} = {}) {
  const projects = collection === 'projects';
  const slugs = new Set(documents.map(document => document.data.slug).filter(Boolean));
  const legacyFeatured = projects && featureLegacyProjects &&
    documents.every(document => document.data.featured == null);
  const selected = new Map(legacyFeatured ? documents
    .filter(document => document.data.status == null || document.data.status === 'published')
    .toSorted((a, b) => (a.data.order ?? 0) - (b.data.order ?? 0) || a.id.localeCompare(b.id))
    .slice(0, 4).map((document, index) => [document.id, index]) : []);

  return documents.flatMap(({id, data}, order) => {
    const patch = {};
    if (data.status == null) patch.status = 'published';
    if (data.order == null) patch.order = order;
    if (projects && !data.slug) {
      const raw = (data.title ?? 'project').toLowerCase()
        .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'project';
      let slug = raw;
      if (slugs.has(slug)) slug = `${raw}-${id.toLowerCase()}`;
      let suffix = 2;
      while (slugs.has(slug)) slug = `${raw}-${id.toLowerCase()}-${suffix++}`;
      slugs.add(slug);
      patch.slug = slug;
    }
    if (legacyFeatured) {
      patch.featured = selected.has(id);
      if (data.featuredOrder == null && selected.has(id)) patch.featuredOrder = selected.get(id);
    }
    return Object.keys(patch).length ? [{path: `${collection}/${id}`, patch}] : [];
  });
}
