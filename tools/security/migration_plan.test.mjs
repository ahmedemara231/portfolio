import {test} from 'node:test';
import assert from 'node:assert/strict';
import {planCollectionMigration} from './migration_plan.mjs';

test('legacy projects gain publication and addresses while existing values survive', () => {
  const documents = [
    {id: 'existing', data: {title: 'Be Fit', slug: 'be-fit', status: 'draft', order: 7, featured: false}},
    {id: 'legacy', data: {title: 'Be Fit', order: 3, description: 'Keep this content'}},
    {id: 'arabic', data: {title: 'مسارات الوفادة'}},
  ];
  const original = structuredClone(documents);
  const changes = planCollectionMigration('projects', documents);
  assert.deepEqual(changes, [
    {path: 'projects/legacy', patch: {status: 'published', slug: 'be-fit-legacy'}},
    {path: 'projects/arabic', patch: {status: 'published', order: 2, slug: 'project'}},
  ]);
  assert.deepEqual(documents, original);
  for (const change of changes) Object.assign(documents.find(document => `projects/${document.id}` === change.path).data, change.patch);
  assert.deepEqual(planCollectionMigration('projects', documents), []);
});

test('optional legacy selection follows saved order and excludes explicit drafts', () => {
  const documents = [
    {id: 'draft', data: {title: 'Private', status: 'draft', order: -1}},
    ...[4, 2, 0, 3, 1].map(order => ({id: `p${order}`, data: {title: `Project ${order}`, order}})),
  ];
  const options = {featureLegacyProjects: true};
  const changes = planCollectionMigration('projects', documents, options);
  const patch = id => changes.find(change => change.path === `projects/${id}`).patch;
  assert.equal(patch('draft').status, undefined);
  assert.equal(patch('draft').featured, false);
  for (let order = 0; order < 4; order++) {
    assert.equal(patch(`p${order}`).featured, true);
    assert.equal(patch(`p${order}`).featuredOrder, order);
  }
  assert.equal(patch('p4').featured, false);
  for (const change of changes) Object.assign(documents.find(document => `projects/${document.id}` === change.path).data, change.patch);
  assert.deepEqual(planCollectionMigration('projects', documents, options), []);
});

test('existing featured choices are preserved and legacy selection requires the flag', () => {
  const legacy = {id: 'legacy', data: {title: 'Legacy', status: 'published', slug: 'legacy', order: 0}};
  assert.deepEqual(planCollectionMigration('projects', [legacy]), []);
  const explicit = {id: 'explicit', data: {...legacy.data, slug: 'explicit', featured: false}};
  assert.deepEqual(planCollectionMigration('projects', [legacy, explicit], {featureLegacyProjects: true}), []);
});

test('other collections gain only missing status and order', () => {
  assert.deepEqual(planCollectionMigration('experiences', [
    {id: 'public', data: {company: 'Keep this name', order: 5}},
    {id: 'private', data: {status: 'draft', order: 0}},
  ]), [{path: 'experiences/public', patch: {status: 'published'}}]);
});
