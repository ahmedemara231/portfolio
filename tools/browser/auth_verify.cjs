const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const path=require('node:path');
const fs=require('node:fs');
const base=process.env.FIREBASE_PREVIEW_URL||'http://localhost:4174';
const errors=[];
function recordErrors(page){page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.text().includes('EXCEPTION CAUGHT')||m.text().startsWith('Another exception was thrown:'))errors.push(m.text());});}
// Flutter creates its editing input after focus. Use actual keyboard input.
async function fill(page, field, value){await field.scrollIntoViewIfNeeded();await page.waitForTimeout(250);await field.focus();await page.waitForTimeout(200);await page.keyboard.press('ControlOrMeta+A');await page.keyboard.insertText(value);await page.waitForTimeout(100);}
async function readField(page, field){await field.scrollIntoViewIfNeeded();await page.waitForTimeout(250);await field.focus();await page.waitForTimeout(200);return page.evaluate(()=>document.activeElement.value);}
async function contains(page,text){try{await page.waitForFunction(t=>(document.body.innerText+'\n'+Array.from(document.querySelectorAll('[aria-label]'),e=>e.getAttribute('aria-label')).join('\n')).includes(t),text,{timeout:20000});}catch(e){console.log('Expected:',text,'Actual:',await page.locator('body').innerText());await page.screenshot({path:path.resolve(__dirname,'../../.preview/auth-failure.png')});throw e;}}
async function authenticateEmulatorOwner(page){
 await page.evaluate(async()=>{
  const auth=window.firebase_auth.getAuth();
  if(auth.app.options.projectId!=='demo-portfolio')throw Error('Use the local Firebase emulator preview.');
  await window.firebase_auth.signInWithEmailAndPassword(auth,'studio@example.test','local-preview-only');
 });
 await page.reload();await page.waitForSelector('flt-semantics',{timeout:60000});
}
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 try{
 const context=await browser.newContext({viewport:{width:1440,height:1000},acceptDownloads:true});
 const admin=await context.newPage();recordErrors(admin);
 await admin.goto(base+'/admin/');await admin.waitForSelector('flt-semantics',{timeout:60000});
 await admin.getByRole('button',{name:'Projects',exact:true}).waitFor();
 assert.equal(await admin.getByRole('button',{name:'Sign in',exact:true}).count(),0);
 assert.equal(await admin.getByRole('button',{name:'Sign out',exact:true}).count(),0);
 // Backend rule checks use the seeded owner without a dashboard login page.
 await authenticateEmulatorOwner(admin);await contains(admin,'Welcome to your studio.');
 const publicPage=await context.newPage();recordErrors(publicPage);await publicPage.goto(base+'/');await publicPage.waitForSelector('flt-semantics',{timeout:60000});await contains(publicPage,'Ahmed Emara');
 await admin.getByRole('button',{name:'Profile & contact',exact:true}).click();await admin.getByRole('button',{name:'Edit profile',exact:true}).click();
 const note=admin.getByRole('textbox',{name:'Availability note',exact:true});const original=await readField(admin,note);await fill(admin,note,'Firebase persistence verified');
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Profile saved.');await contains(publicPage,'Firebase persistence verified');
 await admin.reload();await admin.waitForSelector('flt-semantics');await contains(admin,'Welcome to your studio.');
 await admin.getByRole('button',{name:'Profile & contact',exact:true}).click();await admin.getByRole('button',{name:'Edit profile',exact:true}).click();
 assert.equal(await readField(admin,admin.getByRole('textbox',{name:'Availability note',exact:true})),'Firebase persistence verified');await fill(admin,admin.getByRole('textbox',{name:'Availability note',exact:true}),original);
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(publicPage,original);
 // Check metadata validation and an actual published-content export.
 await admin.getByRole('button',{name:'Search & sharing',exact:true}).click();await admin.getByRole('button',{name:'Edit metadata',exact:true}).click();
 const title=admin.getByRole('textbox',{name:'Page title *',exact:true});const originalTitle=await readField(admin,title);
 await fill(admin,title,'Firebase metadata verification');await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Metadata saved.');
 await publicPage.waitForFunction(()=>document.title==='Firebase metadata verification');
 await admin.getByRole('button',{name:'Edit metadata',exact:true}).click();await fill(admin,admin.getByRole('textbox',{name:'Page title *',exact:true}),originalTitle);
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Metadata saved.');
 const exported=admin.waitForEvent('download');await admin.getByRole('button',{name:'Export published content',exact:true}).click();
 const download=await exported;assert.equal(download.suggestedFilename(),'portfolio-content.json');
 const content=JSON.parse(fs.readFileSync(await download.path(),'utf8'));assert.equal(content.profile.seoTitle,originalTitle);
 assert.ok(!content.collections.messages && !content.collections.activity && !content.collections.contact_limits);
 assert.ok(Object.values(content.collections.projects).every(p=>p.status==='published'));
 // Submit through anonymous Auth and read the actual private inbox on mobile.
 const contactSubject='Firebase contact verification '+Date.now();
 await publicPage.setViewportSize({width:320,height:800});await publicPage.getByRole('button',{name:'Contact',exact:true}).click();
 await publicPage.getByRole('button',{name:'Send a message',exact:true}).click();await publicPage.waitForTimeout(300);
 await publicPage.screenshot({path:path.resolve(__dirname,'../../.preview/contact-form-320.png')});
 await fill(publicPage,publicPage.getByRole('textbox',{name:'Your name',exact:true}),'Firebase verification');
 await fill(publicPage,publicPage.getByRole('textbox',{name:'Email',exact:true}),'verification@example.test');
 await fill(publicPage,publicPage.getByRole('textbox',{name:'Subject (optional)',exact:true}),contactSubject);
 await fill(publicPage,publicPage.getByRole('textbox',{name:'Message',exact:true}),'This message verifies actual anonymous submission and the private inbox.');
 await publicPage.getByRole('button',{name:'Send message',exact:true}).click();await contains(publicPage,'Message sent.');await publicPage.getByRole('button',{name:'Done',exact:true}).click();
 await admin.getByRole('button',{name:'Messages',exact:true}).click();await contains(admin,contactSubject);
 await admin.setViewportSize({width:390,height:844});await admin.waitForTimeout(300);
 await admin.getByRole('button',{name:new RegExp(contactSubject)}).first().click();await admin.getByRole('button',{name:'Close message',exact:true}).waitFor();
 await admin.waitForTimeout(350);
 await admin.screenshot({path:path.resolve(__dirname,'../../.preview/inbox-message-mobile.png')});
 await admin.getByRole('button',{name:'Reply',exact:true}).click();await admin.getByRole('textbox',{name:'Your reply',exact:true}).waitFor();
 await admin.waitForTimeout(350);
 await admin.screenshot({path:path.resolve(__dirname,'../../.preview/inbox-reply-mobile.png')});
 await admin.getByRole('button',{name:'Cancel',exact:true}).click();
 await admin.setViewportSize({width:1440,height:1000});await admin.waitForTimeout(300);
 await admin.getByRole('button',{name:new RegExp(contactSubject)}).first().click();await admin.getByRole('button',{name:'Close message',exact:true}).waitFor();
 await admin.getByRole('button',{name:'Delete',exact:true}).last().click();await contains(admin,'Delete this message?');
 await admin.getByRole('button',{name:'Cancel',exact:true}).click();await admin.getByRole('button',{name:'Close message',exact:true}).waitFor();assert.equal(await admin.getByRole('button',{name:'Close message',exact:true}).count(),1);
 await admin.getByRole('button',{name:'Delete',exact:true}).last().click();await admin.getByRole('button',{name:'Delete message',exact:true}).click();
 await admin.getByRole('button',{name:'Close message',exact:true}).waitFor({state:'hidden'});
 await admin.evaluate(()=>window.firebase_auth.signOut(window.firebase_auth.getAuth()));await admin.reload();
 await admin.getByRole('button',{name:'Projects',exact:true}).waitFor();
 assert.equal(await admin.getByRole('button',{name:'Sign in',exact:true}).count(),0);
 assert.deepEqual(errors,[]);
 console.log('Passed: direct dashboard access without a login page, real Firestore save/reload persistence with the emulator owner, public updates, metadata/export, anonymous contact/private inbox, mobile dialogs, and safe deletion. Demo emulator only.');
 await context.close();
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
