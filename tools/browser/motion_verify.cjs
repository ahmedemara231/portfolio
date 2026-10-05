const { chromium } = require('playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const base = process.env.PORTFOLIO_PREVIEW_URL || 'http://localhost:4173';
const output = path.resolve(__dirname, '../../.preview/motion');
fs.mkdirSync(output, { recursive: true });

async function ready(page, route = '/') {
  await page.goto(base + route);
  await page.waitForSelector('flt-semantics', { timeout: 60000 });
  await page.waitForTimeout(1200);
}

async function capture(page, name, options = {}) {
  return page.screenshot({ path: path.join(output, name + '.png'), ...options });
}

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const errors = [];
  try {
    const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
    const page = await context.newPage();
    page.on('pageerror', error => errors.push(error.message));
    page.on('console', message => {
      if (/EXCEPTION CAUGHT|Another exception was thrown:/.test(message.text())) {
        errors.push(message.text());
      }
    });
    await ready(page);
    const button = page.getByRole('button', { name: 'View Projects', exact: true });
    const box = await button.boundingBox();
    assert.ok(box && box.height >= 48);
    // Native pointer events exercise actual press feedback, rather than an
    // accessibility click that may bypass the pointer's pressed state.
    const before = await capture(page, 'button-idle', { clip: box });
    await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
    await page.waitForTimeout(350);
    const hover = await capture(page, 'button-hover', { clip: box });
    await page.mouse.down();
    await page.waitForTimeout(120);
    const held = await capture(page, 'button-pressed', { clip: box });
    assert.ok(!before.equals(held), 'A held button should visibly respond');
    assert.ok(!hover.equals(held), 'Press feedback should differ from hover');
    const heldBox = await button.boundingBox();
    assert.ok(Math.abs(heldBox.width - box.width) < 1);
    assert.ok(Math.abs(heldBox.height - box.height) < 1);
    await page.mouse.up();
    await page.waitForTimeout(100);
    await capture(page, 'scroll-reveal');
    await page.waitForTimeout(1000);
    await capture(page, 'selected-work');

    const card = page.getByRole('button', { name: /^Explore FIX / });
    await card.scrollIntoViewIfNeeded();
    await page.mouse.move(5, 5);
    await page.waitForTimeout(700);
    const cardBox = await card.boundingBox();
    const idle = await capture(page, 'card-idle', { clip: cardBox });
    await card.hover();
    await page.waitForTimeout(500);
    const hovered = await capture(page, 'card-hover', { clip: cardBox });
    assert.ok(!idle.equals(hovered), 'Project imagery should respond to hover');
    const hoveredBox = await card.boundingBox();
    await page.mouse.move(hoveredBox.x + hoveredBox.width / 2, hoveredBox.y + hoveredBox.height / 2);
    await page.mouse.down();
    await page.waitForTimeout(120);
    const pressedCard = await capture(page, 'card-pressed', { clip: cardBox });
    assert.ok(!hovered.equals(pressedCard), 'Cards should have distinct press feedback');
    await page.mouse.move(5, hoveredBox.y + hoveredBox.height / 2);
    await page.mouse.up();
    await page.waitForTimeout(400);
    assert.equal(new URL(page.url()).pathname, '/', 'Dragging away must cancel the card action');
    await card.click();
    await page.waitForURL('**/projects/fix');
    const screen = page.getByRole('button', { name: 'View FIX service categories full size', exact: true });
    await screen.click();
    await page.waitForTimeout(80);
    await capture(page, 'gallery-opening');
    await page.waitForTimeout(500);
    await capture(page, 'gallery-open');
    await page.keyboard.press('ArrowRight');
    await page.waitForTimeout(80);
    await capture(page, 'gallery-changing');
    await page.waitForTimeout(500);
    await page.getByRole('img', { name: 'FIX repair request journey', exact: true }).waitFor();
    await capture(page, 'gallery-next');
    await page.keyboard.press('Escape');
    await page.waitForTimeout(300);
    assert.equal(await page.getByRole('button', { name: 'Close gallery', exact: true }).count(), 0);

    const admin = await context.newPage();
    admin.on('pageerror', error => errors.push(error.message));
    await ready(admin, '/admin/');
    await admin.getByRole('button', { name: 'Projects', exact: true }).click();
    await admin.getByRole('button', { name: 'Preview FIX', exact: true }).click();
    await admin.waitForTimeout(80);
    await capture(admin, 'dashboard-preview-opening');
    await admin.waitForTimeout(600);
    await capture(admin, 'dashboard-preview');
    await admin.getByRole('button', { name: 'Close preview', exact: true }).click();

    for (const width of [320, 390, 768]) {
      await page.setViewportSize({ width, height: 900 });
      await ready(page);
      await page.getByRole('button', { name: 'View Projects', exact: true }).click();
      await page.waitForTimeout(120);
      await capture(page, `scroll-${width}-entering`);
      await page.waitForTimeout(900);
      await capture(page, `scroll-${width}-settled`);
      assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
    }

    await page.emulateMedia({ reducedMotion: 'reduce' });
    await ready(page);
    assert.ok(await page.evaluate(() => matchMedia('(prefers-reduced-motion: reduce)').matches));
    await page.getByRole('button', { name: 'View Projects', exact: true }).click();
    await page.waitForTimeout(100);
    await capture(page, 'reduced-motion-selected-work');
    await page.getByRole('button', { name: 'View FIX', exact: true }).click();
    await page.waitForURL('**/projects/fix');
    await page.getByRole('button', { name: 'View FIX service categories full size', exact: true }).click();
    await page.getByRole('button', { name: 'Close gallery', exact: true }).waitFor();
    await page.waitForTimeout(50);
    await page.keyboard.press('ArrowRight');
    await page.getByRole('img', { name: 'FIX repair request journey', exact: true }).waitFor();
    await capture(page, 'reduced-motion-gallery');
    await page.keyboard.press('Escape');

    const touchContext = await browser.newContext({
      viewport: { width: 390, height: 844 }, hasTouch: true, isMobile: true,
    });
    const touchPage = await touchContext.newPage();
    touchPage.on('pageerror', error => errors.push(error.message));
    await ready(touchPage);
    const touchBox = await touchPage.getByRole('button', { name: 'View Projects', exact: true }).boundingBox();
    const touchIdle = await capture(touchPage, 'touch-idle', { clip: touchBox });
    const input = await touchContext.newCDPSession(touchPage);
    await input.send('Input.dispatchTouchEvent', {
      type: 'touchStart', touchPoints: [{ x: touchBox.x + touchBox.width / 2, y: touchBox.y + touchBox.height / 2 }],
    });
    await touchPage.waitForTimeout(120);
    const touchHeld = await capture(touchPage, 'touch-pressed', { clip: touchBox });
    assert.ok(!touchIdle.equals(touchHeld), 'Touch presses should visibly respond');
    await input.send('Input.dispatchTouchEvent', { type: 'touchCancel', touchPoints: [] });
    await touchPage.waitForTimeout(400);
    assert.equal(new URL(touchPage.url()).pathname, '/', 'Canceled touches must not navigate');
    await touchContext.close();
    assert.deepEqual(errors, []);
    console.log('Motion browser checks passed: pointer feedback, stable targets, project hover, gallery transitions, dashboard previews, responsive scrolling, and reduced motion.');
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
