const { chromium } = require('playwright');
const { createRequire } = require('node:module');
const securityRequire = createRequire(require.resolve('../security/package.json'));
const { initializeApp, deleteApp } = securityRequire('firebase-admin/app');
const { getFirestore } = securityRequire('firebase-admin/firestore');
const assert = require('node:assert/strict');

const base = process.env.FIREBASE_PREVIEW_URL || 'http://localhost:4174';
const emulatorHost = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
assert.ok(['localhost', '127.0.0.1'].includes(new URL(base).hostname), 'Use a local Firebase preview.');
assert.match(emulatorHost, /^(localhost|127\.0\.0\.1):\d+$/, 'Use a local Firestore emulator.');
process.env.FIRESTORE_EMULATOR_HOST = emulatorHost;

async function fill(page, label, value) {
  const field = page.getByRole('textbox', { name: label, exact: true });
  await field.scrollIntoViewIfNeeded();
  await field.focus();
  await page.waitForTimeout(200);
  await page.keyboard.press('ControlOrMeta+A');
  await page.keyboard.insertText(value);
}

async function openContact(page) {
  await page.getByRole('button', { name: 'Let’s talk', exact: true }).first().click();
  await page.getByRole('button', { name: 'Send a message', exact: true }).click();
  await page.getByRole('textbox', { name: 'Your name', exact: true }).waitFor();
}

async function enterMessage(page, subject) {
  await fill(page, 'Your name', 'Contact verification');
  await fill(page, 'Email', 'verification@example.test');
  await fill(page, 'Subject (optional)', subject);
  await fill(page, 'Message', 'This message verifies that the contact form saves to Firestore.');
}

(async () => {
  const app = initializeApp({ projectId: 'demo-portfolio' }, 'contact-verification');
  const db = getFirestore(app);
  const subject = 'Contact verification ' + Date.now();
  let messageRef;
  let senderUid;
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  try {
    const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
    // A fresh context excludes prior Auth sessions and browser-stored messages.
    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    // Fail before any request can write to a production Firebase service.
    await page.route(/https:\/\/(identitytoolkit|firestore)\.googleapis\.com\//, route => route.abort());
    await page.goto(base);
    await page.waitForSelector('flt-semantics', { timeout: 60000 });
    await openContact(page);
    await enterMessage(page, subject);
    await page.getByRole('button', { name: 'Send message', exact: true }).click();
    await page.getByText('Message sent.', { exact: true }).waitFor({ timeout: 20000 });

    const saved = await db.collection('messages').where('subject', '==', subject).get();
    assert.equal(saved.size, 1, 'Success must correspond to exactly one Firestore document.');
    messageRef = saved.docs[0].ref;
    const message = saved.docs[0].data();
    senderUid = message.senderUid;
    assert.equal(message.name, 'Contact verification');
    assert.equal(message.email, 'verification@example.test');
    assert.equal(message.message, 'This message verifies that the contact form saves to Firestore.');
    assert.equal(message.read, false);
    assert.ok(senderUid);
    assert.ok(message.createdAt.toDate() instanceof Date);
    const limit = await db.collection('contact_limits').doc(senderUid).get();
    assert.ok(limit.data().lastSent.isEqual(message.createdAt), 'Both writes use the same server timestamp.');

    await page.getByRole('button', { name: 'Done', exact: true }).click();
    await openContact(page);
    await enterMessage(page, subject);
    await page.getByRole('button', { name: 'Send message', exact: true }).click();
    await page.getByText(/Could not send your message/).waitFor({ timeout: 20000 });
    assert.equal(await page.getByText('Message sent.', { exact: true }).count(), 0);
    assert.equal((await db.collection('messages').where('subject', '==', subject).get()).size, 1);
    assert.deepEqual(errors, []);
    console.log('Passed: contact form saves to Firestore messages, server timestamps and sender are persisted, and cooldown rejection shows no false success. Emulator only.');
  } finally {
    await browser.close();
    if (messageRef) await messageRef.delete();
    if (senderUid) await db.collection('contact_limits').doc(senderUid).delete();
    await deleteApp(app);
  }
})().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
