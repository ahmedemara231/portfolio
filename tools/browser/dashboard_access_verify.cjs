const { chromium } = require('playwright');
const assert = require('node:assert/strict');

const base = process.env.DASHBOARD_PREVIEW_URL || 'http://localhost:4185';
assert.ok(['localhost', '127.0.0.1'].includes(new URL(base).hostname), 'Use a local dashboard preview.');

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  try {
    const context = await browser.newContext({
      viewport: { width: 1440, height: 1000 },
      serviceWorkers: 'block',
    });
    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(base);
    const projects = page.getByRole('button', { name: 'Projects', exact: true });
    await projects.waitFor({ timeout: 60000 });
    assert.equal(await page.getByRole('button', { name: 'Sign in', exact: true }).count(), 0);
    assert.equal(await page.getByRole('button', { name: 'Sign out', exact: true }).count(), 0);
    assert.equal(await page.getByRole('textbox', { name: 'Password', exact: true }).count(), 0);

    await projects.click();
    await page.getByRole('button', { name: 'Add project', exact: true }).waitFor();
    await page.reload();
    await projects.waitFor({ timeout: 60000 });
    assert.equal(await page.getByRole('button', { name: 'Sign in', exact: true }).count(), 0);

    await page.setViewportSize({ width: 390, height: 844 });
    await page.getByRole('button', { name: 'Open studio navigation', exact: true }).click();
    await projects.waitFor();
    assert.equal(await page.getByRole('button', { name: 'Sign out', exact: true }).count(), 0);
    await projects.click();
    await page.getByRole('button', { name: 'Add project', exact: true }).waitFor();
    assert.deepEqual(errors, []);
    console.log('Passed: a fresh browser opens the Firebase dashboard directly, navigation works after reload and on mobile, and no sign-in or sign-out controls appear. No data was changed.');
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
