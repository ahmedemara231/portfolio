const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const path=require('node:path');
const fs=require('node:fs');
const base=process.env.FIREBASE_PREVIEW_URL||'http://localhost:4174';
const root=path.resolve(__dirname,'../..');
const errors=[];
function recordErrors(page){page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.text().includes('EXCEPTION CAUGHT')||m.text().startsWith('Another exception was thrown:'))errors.push(m.text());});}
const pause=ms=>new Promise(resolve=>setTimeout(resolve,ms));
async function focus(page,field){await field.scrollIntoViewIfNeeded();await pause(250);await field.focus();await pause(200);}
async function fill(page,field,value){await focus(page,field);await page.keyboard.press('ControlOrMeta+A');await page.keyboard.insertText(value);await pause(100);}
async function read(page,field){await focus(page,field);return page.evaluate(()=>document.activeElement.value);}
async function click(field){await field.scrollIntoViewIfNeeded();await pause(250);await field.click();}
async function contains(page,text){try{await page.waitForFunction(t=>(document.body.innerText+'\n'+Array.from(document.querySelectorAll('[aria-label]'),e=>e.getAttribute('aria-label')).join('\n')).includes(t),text,{timeout:20000});}catch(e){console.log('Expected:',text,'Actual:',await page.locator('body').innerText(),'Errors:',errors);await page.screenshot({path:path.join(root,'.preview/media-failure.png')});throw e;}}
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 try{
 const context=await browser.newContext({viewport:{width:1440,height:1000},acceptDownloads:true});
 const admin=await context.newPage();recordErrors(admin);await admin.goto(base+'/admin/');await admin.waitForSelector('flt-semantics',{timeout:60000});
 await admin.evaluate(async()=>{
  const auth=window.firebase_auth.getAuth();
  if(auth.app.options.projectId!=='demo-portfolio')throw Error('Use the local Firebase emulator preview.');
  await window.firebase_auth.signInWithEmailAndPassword(auth,'studio@example.test','local-preview-only');
 });
 await admin.reload();await admin.waitForSelector('flt-semantics',{timeout:60000});await contains(admin,'Welcome to your studio.');
 await admin.getByRole('button',{name:'Projects',exact:true}).click();await admin.getByRole('button',{name:'Add project',exact:true}).click();
 await admin.setViewportSize({width:320,height:800});await pause(350);await admin.screenshot({path:path.join(root,'.preview/project-editor-320.png')});
 await admin.setViewportSize({width:1440,height:1000});await pause(350);
 for(const [name,value] of [['Project name *','Gallery verification'],['Page address *','gallery-verification'],['Product category *','Services'],['Short purpose *','A temporary case used only to verify the local Firebase media workflow.']]) await fill(admin,admin.getByRole('textbox',{name,exact:true}),value);
 const chooser=admin.waitForEvent('filechooser');await click(admin.getByRole('button',{name:'Upload screenshot',exact:true}));await (await chooser).setFiles(path.join(root,'packages/core/assets/projects/fix-3.webp'));
 await admin.getByRole('textbox',{name:'Meaningful screen description *',exact:true}).waitFor();await fill(admin,admin.getByRole('textbox',{name:'Meaningful screen description *',exact:true}),'Verified FIX service screenshot');
 const image=await read(admin,admin.getByRole('textbox',{name:'Image URL',exact:true}));assert.ok(image.startsWith('storage://projects/'));
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Project saved.');
 await fill(admin,admin.getByRole('textbox',{name:'Search entries',exact:true}),'Gallery verification');
 const publicPage=await context.newPage();recordErrors(publicPage);await publicPage.goto(base+'/projects/gallery-verification');await publicPage.waitForSelector('flt-semantics');await contains(publicPage,'This page took a wrong turn.');
 const imageUrl='http://127.0.0.1:9199/v0/b/demo-portfolio.appspot.com/o/'+encodeURIComponent(image.slice(10))+'?alt=media';
 assert.equal((await context.request.get(imageUrl)).status(),403);
 await admin.getByRole('button',{name:'Preview Gallery verification',exact:true}).click();await contains(admin,'Private draft preview');await admin.getByRole('img',{name:'Verified FIX service screenshot',exact:true}).first().waitFor();await admin.screenshot({path:path.join(root,'.preview/private-media-preview.png')});await admin.getByRole('button',{name:'Close preview',exact:true}).click();
 await admin.getByRole('button',{name:'Edit entry',exact:true}).click();await admin.getByRole('button',{name:'Publication Draft',exact:true}).click();await admin.getByRole('menuitem',{name:'Published',exact:true}).click();await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Project saved.');
 await publicPage.reload();await publicPage.waitForSelector('flt-semantics');await contains(publicPage,'Gallery verification');assert.equal((await context.request.get(imageUrl)).status(),200);
 await click(publicPage.getByRole('button',{name:'View Verified FIX service screenshot full size',exact:true}));await publicPage.getByRole('img',{name:'Verified FIX service screenshot',exact:true}).waitFor();await publicPage.getByRole('button',{name:'Close gallery',exact:true}).click();
 await admin.getByRole('button',{name:'Search & sharing',exact:true}).click();
 const publishedExport=admin.waitForEvent('download');await admin.getByRole('button',{name:'Export published content',exact:true}).click();
 const snapshot=JSON.parse(fs.readFileSync(await (await publishedExport).path(),'utf8'));
 const published=Object.values(snapshot.collections.projects).find(p=>p.slug==='gallery-verification');
 assert.equal(published.gallery[0].url,imageUrl);assert.ok(!published.gallery[0].url.includes('token='));assert.equal((await context.request.get(published.gallery[0].url)).status(),200);
 await admin.getByRole('button',{name:'Projects',exact:true}).click();await fill(admin,admin.getByRole('textbox',{name:'Search entries',exact:true}),'Gallery verification');
 await admin.getByRole('button',{name:'Delete entry',exact:true}).click();await contains(admin,'Delete project?');await admin.getByRole('button',{name:'Cancel',exact:true}).click();await pause(400);await contains(admin,'Gallery verification');
 await admin.getByRole('button',{name:'Delete entry',exact:true}).click();await contains(admin,'Delete project?');await pause(350);await admin.getByRole('button',{name:'Delete entry',exact:true}).click();await contains(admin,'Entry deleted.');assert.equal((await context.request.get(imageUrl)).status(),403);
 // CV upload includes a Content-Disposition header for cross-origin downloads.
 await admin.getByRole('button',{name:'Profile & contact',exact:true}).click();await admin.getByRole('button',{name:'Edit profile',exact:true}).click();const cvField=admin.getByRole('textbox',{name:'CV URL or uploaded PDF',exact:true});const originalCv=await read(admin,cvField);
 const pdf=admin.waitForEvent('filechooser');await click(admin.getByRole('button',{name:'Upload PDF',exact:true}));await (await pdf).setFiles(path.join(root,'apps/portfolio/web/files/ahmed-emara-cv.pdf'));await pause(500);const uploadedCv=await read(admin,cvField);assert.ok(uploadedCv.includes('127.0.0.1:9199'));
 const response=await context.request.get(uploadedCv);assert.equal(response.status(),200);assert.ok(response.headers()['content-disposition'].includes('attachment'));assert.equal((await response.body()).subarray(0,5).toString(),'%PDF-');
 await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Profile saved.');await publicPage.goto(base+'/');await publicPage.waitForSelector('flt-semantics');await contains(publicPage,'Ahmed Emara');const download=publicPage.waitForEvent('download');await publicPage.getByRole('button',{name:'Download CV',exact:true}).click();assert.equal((await download).suggestedFilename(),'Ahmed-Emara-CV.pdf');
 await admin.getByRole('button',{name:'Edit profile',exact:true}).click();await fill(admin,admin.getByRole('textbox',{name:'CV URL or uploaded PDF',exact:true}),originalCv);await admin.getByRole('button',{name:'Save changes',exact:true}).click();await contains(admin,'Profile saved.');
 assert.deepEqual(errors,[]);
 console.log('Passed: genuine media upload, mobile editor, optimized preview, draft Storage denial, private preview, publication, anonymous image access, safe deletion, PDF upload, and real cross-origin CV download. Demo emulator only.');
 await context.close();
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
