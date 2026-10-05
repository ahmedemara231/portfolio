// Reviewable additive migration. A production run is always a dry run unless
// --apply is explicitly supplied. Never overwrites existing user content.
import {initializeApp,applicationDefault} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import fs from 'node:fs';
import path from 'node:path';
const args=process.argv.slice(2);const index=args.indexOf('--project');const project=index>=0?args[index+1]:null;
if(!project)throw Error('Supply --project. No default production project is used.');
initializeApp({projectId:project,credential:applicationDefault()});const db=getFirestore();
const collections=['projects','experiences','packages','education','technical_skills','soft_skills','tools','about_features','stats','social_links','experience_stats'];
const backup={profile:(await db.doc('profile/main').get()).data()??{},collections:{}};const changes=[];
for(const collection of collections){
 const docs=await db.collection(collection).get();backup.collections[collection]={};const slugs=new Set(docs.docs.map(d=>d.data().slug).filter(Boolean));
 let order=0;
 for(const document of docs.docs){
  const data=document.data();backup.collections[collection][document.id]=data;const patch={};
  if(data.status==null)patch.status='published';
  if(data.order==null)patch.order=order;
  if(collection==='projects'&&!data.slug){
   const raw=(data.title??'project').toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')||'project';let slug=raw;
   if(slugs.has(slug))slug=raw+'-'+document.id.toLowerCase().slice(0,8);slugs.add(slug);patch.slug=slug;
  }
  if(Object.keys(patch).length)changes.push({path:document.ref.path,patch});order++;
 }
}
fs.mkdirSync('.backups',{recursive:true});const directory=path.join('.backups',new Date().toISOString().replaceAll(':','-'));fs.mkdirSync(directory);
fs.writeFileSync(path.join(directory,'before.json'),JSON.stringify(backup,null,2));fs.writeFileSync(path.join(directory,'migration-plan.json'),JSON.stringify(changes,null,2));
console.log(`${changes.length} additive updates. Backup and plan: ${directory}.`);
if(!args.includes('--apply')){console.log('Dry run complete. No remote data was written.');process.exit(0);}
// Re-check missing fields inside transactions so edits made after the dry run survive.
for(const change of changes)await db.runTransaction(async transaction=>{
 const ref=db.doc(change.path);const latest=await transaction.get(ref);if(!latest.exists)return;
 const current=latest.data();const missing=Object.fromEntries(Object.entries(change.patch).filter(([key])=>current[key]==null||(key==='slug'&&current[key]==='')));
 if(Object.keys(missing).length)transaction.update(ref,missing);
});
console.log('Migration applied. Existing content and links were preserved.');
