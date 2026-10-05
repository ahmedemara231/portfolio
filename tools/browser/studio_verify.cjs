const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const path=require('node:path');
const fs=require('node:fs');
const base=process.env.PORTFOLIO_PREVIEW_URL||'http://localhost:4173';
if(!['localhost','127.0.0.1'].includes(new URL(base).hostname))throw Error('Run studio checks against a local preview only.');
const output=path.resolve(__dirname,'../../.preview/studio');fs.mkdirSync(output,{recursive:true});
const errors=[];
async function ready(page){await page.goto(base+'/admin/');await page.waitForSelector('flt-semantics',{timeout:60000});await contains(page,'Welcome to your studio.');}
async function contains(page,text){await page.waitForFunction(t=>(document.body.innerText+'\n'+Array.from(document.querySelectorAll('[aria-label]'),e=>e.getAttribute('aria-label')).join('\n')).includes(t),text,{timeout:20000});}
async function fill(page,field,value){await field.waitFor({state:'visible'});await page.waitForTimeout(400);await field.scrollIntoViewIfNeeded();await page.waitForTimeout(200);await field.focus();await page.waitForTimeout(150);await page.keyboard.press('ControlOrMeta+A');await page.keyboard.insertText(value);}
async function content(page){return page.evaluate(()=>{const raw=JSON.parse(localStorage.getItem('flutter.ahmed-emara-content-v2'));return typeof raw==='string'?JSON.parse(raw):raw;});}
async function capture(page,name){await page.waitForTimeout(400);await page.screenshot({path:path.join(output,name+'.png')});}
async function discard(page){await page.getByRole('button',{name:'Close editor',exact:true}).click();await page.getByRole('button',{name:'Discard changes',exact:true}).click();}
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 try{
  const context=await browser.newContext({viewport:{width:1440,height:1000},acceptDownloads:true});
  const page=await context.newPage();page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(m.text().includes('EXCEPTION CAUGHT')||m.text().startsWith('Another exception was thrown:'))errors.push(m.text());});
  await ready(page);const initial=await content(page);assert.ok(initial?.collections);
  await capture(page,'overview-desktop');
  // Featured selection uses real documents, appends its order, and survives reload.
  const [sitrId,sitr]=Object.entries(initial.collections.projects).find(([,p])=>p.slug==='sitr');
  await page.getByRole('button',{name:'Featured work',exact:true}).click();await page.getByRole('button',{name:'Choose projects',exact:true}).first().click();
  const sitrBox=page.getByRole('checkbox',{name:new RegExp('^'+sitr.title.replace(/[.*+?^${}()|[\]\\]/g,'\\$&'))});
  await sitrBox.click();await contains(page,'Selection saved.');await capture(page,'featured-selection');
  let saved=await content(page);assert.equal(saved.collections.projects[sitrId].featured,true);assert.equal(saved.collections.projects[sitrId].order,sitr.order);
  const maxPosition=Math.max(...Object.values(initial.collections.projects).filter(p=>p.featured).map(p=>p.featuredOrder));assert.equal(saved.collections.projects[sitrId].featuredOrder,maxPosition+1);
  await page.getByRole('button',{name:'Done',exact:true}).click();await ready(page);
  assert.equal((await content(page)).collections.projects[sitrId].featured,true);
  await page.getByRole('button',{name:'Featured work',exact:true}).click();await page.getByRole('button',{name:'Choose projects',exact:true}).first().click();
  await page.getByRole('checkbox',{name:/^Sitr/}).click();await contains(page,'Selection saved.');await page.getByRole('button',{name:'Done',exact:true}).click();
  // The introduction preview includes unsaved values, in both viewport modes.
  await page.getByRole('button',{name:'Profile & contact',exact:true}).click();await capture(page,'profile-desktop');
  await page.getByRole('button',{name:'Edit profile',exact:true}).click();await page.getByRole('button',{name:/Introduction$/}).click();
  await fill(page,page.getByRole('textbox',{name:'Hero headline *',exact:true}),'Unsaved introduction verification');
  await page.getByRole('button',{name:'Preview',exact:true}).click();await contains(page,'Private introduction preview');await contains(page,'Unsaved introduction verification');
  await page.getByRole('checkbox',{name:'Phone',exact:true}).click();await capture(page,'private-introduction-phone');
  await page.getByRole('button',{name:'Close preview',exact:true}).click();await discard(page);
  assert.equal((await content(page)).profile.heroTitle,initial.profile.heroTitle);
  // Capability references display project names and persist the actual IDs.
  const [capId,cap]=Object.entries(initial.collections.technical_skills).sort((a,b)=>a[1].order-b[1].order)[0];
  const fixId=Object.entries(initial.collections.projects).find(([,p])=>p.slug==='fix')[0];const wasSelected=(cap.projectIds||[]).includes(fixId);
  await page.getByRole('button',{name:'Capabilities',exact:true}).click();await page.getByRole('button',{name:'Edit entry',exact:true}).first().click();await contains(page,'Related projects');
  await page.getByRole('checkbox',{name:/^FIX\s/}).first().click();await page.getByRole('button',{name:'Save changes',exact:true}).click();
  await page.getByRole('button',{name:'Edit entry',exact:true}).first().waitFor();await ready(page);
  saved=await content(page);assert.equal(saved.collections.technical_skills[capId].projectIds.includes(fixId),!wasSelected);
  await page.getByRole('button',{name:'Capabilities',exact:true}).click();await page.getByRole('button',{name:'Edit entry',exact:true}).first().click();await page.getByRole('checkbox',{name:/^FIX\s/}).first().click();await capture(page,'capability-editor');await page.getByRole('button',{name:'Save changes',exact:true}).click();await page.getByRole('button',{name:'Edit entry',exact:true}).first().waitFor();
  // Screenshot viewing, accessible ordering, and removal with Undo in a draft edit.
  await page.getByRole('button',{name:'Projects',exact:true}).click();await fill(page,page.getByRole('textbox',{name:'Search entries',exact:true}),'FIX');await page.waitForTimeout(250);await capture(page,'projects-desktop');
  await page.getByRole('button',{name:'Edit entry',exact:true}).first().click();await capture(page,'project-editor-desktop');await page.getByRole('button',{name:/Imagery$/}).click();await capture(page,'gallery-editor-desktop');
  await page.getByRole('button',{name:/^Preview screen 1/}).click();await page.getByRole('button',{name:'Close screenshot preview',exact:true}).waitFor();await capture(page,'screenshot-preview');await page.getByRole('button',{name:'Close screenshot preview',exact:true}).click();
  await page.getByRole('button',{name:'Remove screen 1',exact:true}).click();await contains(page,'Screen removed from this edit.');await page.getByRole('button',{name:'Undo',exact:true}).click();await page.getByRole('button',{name:'Move 1 down',exact:true}).first().click();await page.getByRole('button',{name:'Move 2 up',exact:true}).first().click();await discard(page);
  await page.getByRole('button',{name:'Search & sharing',exact:true}).click();await capture(page,'sharing-desktop');
  // Inspect the same editor and navigation at compact widths.
  for(const width of [320,390,768]){
   await page.setViewportSize({width,height:900});await ready(page);await capture(page,'overview-'+width);
   await page.getByRole('button',{name:'Open studio navigation',exact:true}).click();await capture(page,'navigation-'+width);await page.getByRole('button',{name:'Projects',exact:true}).click();
   await fill(page,page.getByRole('textbox',{name:'Search entries',exact:true}),'FIX');await page.getByRole('button',{name:'Edit entry',exact:true}).first().click();await capture(page,'project-editor-'+width);
   await page.getByRole('button',{name:/Imagery$/}).click();await capture(page,'gallery-editor-'+width);await page.getByRole('button',{name:'Close editor',exact:true}).click();
   assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
  }
  assert.deepEqual(errors,[]);console.log('Passed: featured selection persistence, unsaved profile previews, named capability references, screenshot viewing/Undo/ordering, sharing previews, and mobile/tablet editors.');await context.close();
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
