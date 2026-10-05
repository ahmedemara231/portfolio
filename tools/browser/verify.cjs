const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const path=require('node:path');
const fs=require('node:fs');
const base=process.env.PORTFOLIO_PREVIEW_URL||'http://localhost:4173';
const output=path.resolve(__dirname,'../../.preview');fs.mkdirSync(output,{recursive:true});
const errors=[];
const delay=ms=>new Promise(resolve=>setTimeout(resolve,ms));
async function ready(page,url){await page.goto(url);await page.waitForSelector('flt-semantics',{timeout:60000});await page.waitForTimeout(500);}
// Flutter creates its editing input after focus. Use actual keyboard input.
async function fill(page, field, value){await field.scrollIntoViewIfNeeded();await page.waitForTimeout(250);await field.focus();await page.waitForTimeout(200);await page.keyboard.press('ControlOrMeta+A');await page.keyboard.insertText(value);await page.waitForTimeout(100);}
async function readField(page, field){await field.scrollIntoViewIfNeeded();await page.waitForTimeout(250);await field.focus();await page.waitForTimeout(200);return page.evaluate(()=>document.activeElement.value);}
async function contains(page,text){try{await page.waitForFunction(t=>(document.body.innerText+'\n'+Array.from(document.querySelectorAll('[aria-label]'),e=>e.getAttribute('aria-label')).join('\n')).includes(t),text,{timeout:15000});}catch(e){console.log('Expected:',text,'Actual:',await page.locator('body').ariaSnapshot());await screenshot(page,'browser-failure');throw e;}}
async function screenshot(page,name){await page.screenshot({path:path.join(output,name+'.png')});}
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 try {
 const context=await browser.newContext({viewport:{width:1440,height:1000},acceptDownloads:true});
 const publicPage=await context.newPage();publicPage.on('pageerror',e=>errors.push(e.message));
 await ready(publicPage,base+'/');await contains(publicPage,'Ahmed Emara');await screenshot(publicPage,'portfolio-desktop');
 const download=publicPage.waitForEvent('download');await publicPage.getByRole('button',{name:'Download CV',exact:true}).click();assert.equal((await download).suggestedFilename(),'Ahmed-Emara-CV.pdf');
 await publicPage.getByRole('button',{name:'View Projects',exact:true}).click();await delay(500);
 await publicPage.getByRole('button',{name:/All projects \(/}).click();await contains(publicPage,'Work in the wild.');
 await publicPage.getByRole('checkbox',{name:'Fitness',exact:true}).click();await contains(publicPage,'1 project');
 await publicPage.waitForFunction(()=>!document.body.innerText.includes('View FIX'));
 assert.equal(await publicPage.getByRole('button',{name:'View Be Fit',exact:true}).count(),1);
 await publicPage.getByRole('button',{name:'View Be Fit',exact:true}).click();await contains(publicPage,'Inside the application');
 assert.ok(publicPage.url().endsWith('/projects/be-fit'));await screenshot(publicPage,'project-desktop');
 // Gallery controls remain usable with the keyboard.
 const screen=publicPage.getByRole('button',{name:/View Be Fit exercise list full size/});
 await screen.click();await publicPage.getByRole('button',{name:'Close gallery',exact:true}).waitFor();await delay(300);await publicPage.keyboard.press('ArrowRight');await publicPage.getByRole('img',{name:'Be Fit weekly training plan',exact:true}).waitFor();
 await publicPage.keyboard.press('Escape');await delay(300);
 await ready(publicPage,base+'/a-missing-page');await contains(publicPage,'This page took a wrong turn.');
 await ready(publicPage,base+'/');
 const admin=await context.newPage();admin.on('pageerror',e=>errors.push(e.message));await ready(admin,base+'/admin/');
 await contains(admin,'Welcome to your studio.');await screenshot(admin,'dashboard-desktop');
 await admin.getByRole('button',{name:'Projects',exact:true}).click();
 await fill(admin,admin.getByRole('textbox',{name:'Search entries',exact:true}),'FIX');await delay(300);
 await admin.getByRole('button',{name:'Edit entry',exact:true}).first().click();await contains(admin,'Edit project');
 await screenshot(admin,'project-editor-desktop');
 const purpose=admin.getByRole('textbox',{name:'Short purpose *',exact:true});
 const original=await readField(admin,purpose);assert.ok(original.length>20);const changed=original+' Local verification.';await fill(admin,purpose,changed);
 await admin.getByRole('button',{name:'Close editor',exact:true}).click();await contains(admin,'Discard unsaved changes?');
 await admin.getByRole('button',{name:'Keep editing',exact:true}).click();
 await admin.getByRole('button',{name:'Preview',exact:true}).click();await contains(admin,'Project preview');await contains(admin,changed);
 await admin.getByRole('button',{name:'Close preview',exact:true}).click();
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Project saved.');
 // Cross-tab storage notifications keep the open portfolio connected to CMS edits.
 await contains(publicPage,changed);
 await admin.reload();await admin.waitForSelector('flt-semantics');await contains(admin,'Welcome to your studio.');
 await admin.getByRole('button',{name:'Projects',exact:true}).click();await fill(admin,admin.getByRole('textbox',{name:'Search entries',exact:true}),'FIX');await delay(200);
 await admin.getByRole('button',{name:'Edit entry',exact:true}).first().click();assert.equal(await readField(admin,admin.getByRole('textbox',{name:'Short purpose *',exact:true})),changed);
 // Switch the actual project to a draft, then try its public URL directly.
 await admin.getByRole('button',{name:'Publication Published',exact:true}).click();await admin.getByRole('menuitem',{name:'Draft',exact:true}).click();
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Project saved.');
 await ready(publicPage,base+'/projects/fix');await contains(publicPage,'This page took a wrong turn.');
 // Restore the original content and publication state through the editor.
 await admin.getByRole('button',{name:'Edit entry',exact:true}).first().click();await fill(admin,admin.getByRole('textbox',{name:'Short purpose *',exact:true}),original);
 await admin.getByRole('button',{name:'Publication Draft',exact:true}).click();await admin.getByRole('menuitem',{name:'Published',exact:true}).click();
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Project saved.');
 await ready(publicPage,base+'/projects/fix');await contains(publicPage,original);
 // Reorder the featured collection and verify persistence in a reload.
 await admin.getByRole('button',{name:'Featured work',exact:true}).click();await contains(admin,'Featured work');
 await admin.getByRole('button',{name:'Move down',exact:true}).first().click();await contains(admin,'Display order saved.');
 await admin.getByRole('button',{name:'Move up',exact:true}).nth(1).click();await delay(300);
 await admin.getByRole('button',{name:'Profile & contact',exact:true}).click();await admin.getByRole('button',{name:'Edit profile',exact:true}).click();
 const note=admin.getByRole('textbox',{name:'Availability note',exact:true});const originalNote=await readField(admin,note);await fill(admin,note,'Availability verification');
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Profile saved.');
 await ready(publicPage,base+'/');await contains(publicPage,'Availability verification');const raw=JSON.parse(await publicPage.evaluate(()=>localStorage.getItem('flutter.ahmed-emara-content-v2')));const persisted=typeof raw==='string'?JSON.parse(raw):raw;assert.equal(persisted.profile.availabilityNote,'Availability verification');assert.equal(persisted.profile.heroTitle,'Mobile apps.\nMade with purpose.');
 await admin.getByRole('button',{name:'Edit profile',exact:true}).click();await fill(admin,admin.getByRole('textbox',{name:'Availability note',exact:true}),originalNote);
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Profile saved.');
 // Real contact persistence and inbox visibility.
 await publicPage.getByRole('button',{name:'Let’s talk',exact:true}).click();await delay(500);
 await publicPage.getByRole('button',{name:'Send a message',exact:true}).click();
 await fill(publicPage,publicPage.getByRole('textbox',{name:'Your name',exact:true}),'Local verification');
 await fill(publicPage,publicPage.getByRole('textbox',{name:'Email',exact:true}),'verification@example.test');
 await fill(publicPage,publicPage.getByRole('textbox',{name:'Subject (optional)',exact:true}),'Browser verification');
 await fill(publicPage,publicPage.getByRole('textbox',{name:'Message',exact:true}),'A local verification message for the private inbox.');
 await publicPage.getByRole('button',{name:'Send message',exact:true}).click();await contains(publicPage,'Message sent.');await publicPage.getByRole('button',{name:'Done',exact:true}).click();
 await admin.getByRole('button',{name:'Messages',exact:true}).click();await contains(admin,'Browser verification');
 // Actual layouts at small mobile, tablet, laptop, and large desktop widths.
 for(const width of [320,390,768,1280,1920]){
  await publicPage.setViewportSize({width,height:900});await ready(publicPage,base+'/');await screenshot(publicPage,'portfolio-'+width);
  await admin.setViewportSize({width,height:900});await ready(admin,base+'/admin/');await screenshot(admin,'dashboard-'+width);
  assert.ok(await publicPage.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth));
  assert.ok(await admin.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth));
 }
 await publicPage.setViewportSize({width:390,height:844});await publicPage.emulateMedia({reducedMotion:'reduce'});await ready(publicPage,base+'/projects/two-days');await contains(publicPage,'2 Days');await screenshot(publicPage,'project-mobile-reduced-motion');
 await publicPage.keyboard.press('Tab');assert.ok(await publicPage.evaluate(()=>document.activeElement!==document.body));
 assert.deepEqual(errors,[]);console.log('Passed: routing, filters, gallery keyboard controls, CV, saves/reloads, cross-tab updates, private drafts, ordering, profile, contact/inbox, responsive layouts, reduced motion, and keyboard focus.');
 await context.close();
 } finally {await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
