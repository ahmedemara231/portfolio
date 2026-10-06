const {chromium} = require('playwright');
const assert = require('node:assert/strict');

// Read-only: verifies public content without changing Firebase or browser data.
const base = (process.env.PORTFOLIO_PREVIEW_URL || 'http://localhost:4173').replace(/\/$/, '');
const expectedProjects = Number(process.env.EXPECTED_PROJECTS || 11);
const expectedFeatured = Number(process.env.EXPECTED_FEATURED || 4);
const errors = [];
async function contains(page, text) {
  await page.waitForFunction(value => (
    document.body.innerText + '\n' + Array.from(document.querySelectorAll('[aria-label]'), element => element.getAttribute('aria-label')).join('\n')
  ).includes(value), text, {timeout: 60000});
}

(async () => {
  const browser = await chromium.launch({channel: 'chrome', headless: true});
  try {
    const context = await browser.newContext({viewport: {width: 1440, height: 1000}, serviceWorkers: 'block'});
    const page = await context.newPage();
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(`${base}/`);
    const allProjects = page.getByRole('button', {name: `All projects (${expectedProjects})`, exact: true});
    await allProjects.waitFor({timeout: 60000});
    const projectButtons = page.getByRole('button', {name: /^View (?!Projects$)/});
    assert.equal(await projectButtons.count(), expectedFeatured, 'The homepage displays the selected projects.');
    await allProjects.scrollIntoViewIfNeeded();
    await allProjects.click();
    await contains(page, `${expectedProjects} projects`);
    assert.equal(await projectButtons.count(), expectedProjects, 'The full collection displays every published project.');
    const first = projectButtons.first();
    const label = await first.getAttribute('aria-label') || await first.innerText();
    const title = label.replace(/^View /, '').trim();
    assert.ok(title, 'The project has a readable title.');
    await first.scrollIntoViewIfNeeded();
    await first.click();
    await page.waitForURL(url => url.pathname.startsWith('/projects/'));
    await contains(page, title);
    assert.ok(new URL(page.url()).pathname.startsWith('/projects/'), 'Project buttons open a case study.');
    const detailUrl = page.url();
    await page.reload();
    await contains(page, title);
    await page.getByRole('button', {name: 'All projects', exact: true}).waitFor();
    assert.equal(
      new URL(page.url()).pathname.replace(/\/+$/, ''),
      new URL(detailUrl).pathname.replace(/\/+$/, ''),
      'A case study survives a hosting directory redirect on reload.',
    );
    await page.setViewportSize({width: 390, height: 844});
    await page.goto(`${base}/projects`);
    await contains(page, `${expectedProjects} projects`);
    assert.equal(await projectButtons.count(), expectedProjects, 'Projects also load on mobile.');
    await page.goto(`${base}/projects/`);
    await contains(page, `${expectedProjects} projects`);
    assert.equal(await projectButtons.count(), expectedProjects, 'A hosting directory address also loads the collection.');
    assert.deepEqual(errors, []);
    console.log(`Passed: ${expectedFeatured} homepage projects, ${expectedProjects} published projects, case-study navigation and reload, and mobile content. Read-only.`);
  } finally {
    await browser.close();
  }
})().catch(error => {console.error(error); process.exitCode = 1;});
