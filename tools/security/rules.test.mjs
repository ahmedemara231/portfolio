import fs from 'node:fs';
import {before,after,beforeEach,test} from 'node:test';
import {initializeTestEnvironment,assertSucceeds,assertFails} from '@firebase/rules-unit-testing';
import {doc,setDoc,getDoc,getDocs,collection,query,where,writeBatch,serverTimestamp,updateDoc} from 'firebase/firestore';
import {ref,uploadBytes,getBytes} from 'firebase/storage';
let env;
before(async()=>{
 env=await initializeTestEnvironment({projectId:'demo-portfolio',firestore:{host:'127.0.0.1',port:8080,rules:fs.readFileSync('firestore.rules','utf8')},
  storage:{host:'127.0.0.1',port:9199,rules:fs.readFileSync('storage.rules','utf8')}});
});
after(async()=>{await env.cleanup();});
beforeEach(async()=>{await env.clearFirestore();await env.withSecurityRulesDisabled(async ctx=>{
 const db=ctx.firestore();
 await setDoc(doc(db,'projects','published'),{title:'Published',slug:'published',status:'published',order:0});
 await setDoc(doc(db,'projects','draft'),{title:'Private draft',slug:'private-draft',status:'draft',order:1});
 await setDoc(doc(db,'profile','main'),{name:'Ahmed Emara'});
 });});
test('anonymous visitors read published content and cannot access drafts by ID or collection',async()=>{
 const db=env.unauthenticatedContext().firestore();
 await assertSucceeds(getDoc(doc(db,'profile','main')));
 await assertSucceeds(getDoc(doc(db,'projects','published')));
 await assertFails(getDoc(doc(db,'projects','draft')));
 await assertFails(getDocs(collection(db,'projects')));
 await assertSucceeds(getDocs(query(collection(db,'projects'),where('status','==','published'))));
});
test('ordinary authenticated users cannot edit content or grant themselves access',async()=>{
 const db=env.authenticatedContext('visitor').firestore();
 await assertFails(updateDoc(doc(db,'projects','published'),{title:'Changed'}));
 await assertFails(setDoc(doc(db,'admins','visitor'),{admin:true}));
 await assertFails(getDoc(doc(db,'projects','draft')));
 await assertFails(getDocs(collection(db,'messages')));
});
test('an administrator can save, reorder atomically, and unpublish a project',async()=>{
 const db=env.authenticatedContext('owner',{admin:true}).firestore();
 await assertSucceeds(getDoc(doc(db,'projects','draft')));
 await assertSucceeds(updateDoc(doc(db,'projects','draft'),{status:'published'}));
 const batch=writeBatch(db);batch.update(doc(db,'projects','draft'),{order:0});batch.update(doc(db,'projects','published'),{order:1});
 await assertSucceeds(batch.commit());
 await assertSucceeds(updateDoc(doc(db,'projects','published'),{status:'draft'}));
 await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(),'projects','published')));
});
test('invalid publication and project addresses are rejected on the backend',async()=>{
 const db=env.authenticatedContext('owner',{admin:true}).firestore();
 await assertFails(updateDoc(doc(db,'projects','published'),{status:'anything'}));
 await assertFails(updateDoc(doc(db,'projects','published'),{slug:'Bad Address'}));
});
test('contact writes require validation, a server timestamp, and a cooldown batch',async()=>{
 const db=env.authenticatedContext('sender').firestore();
 const payload={name:'Test sender',email:'test@example.com',subject:'Hello',message:'A valid test message.',senderUid:'sender',read:false,createdAt:serverTimestamp()};
 await assertFails(setDoc(doc(db,'messages','without-limit'),payload));
 const send=()=>{const batch=writeBatch(db);batch.set(doc(db,'contact_limits','sender'),{lastSent:serverTimestamp()});batch.set(doc(db,'messages','valid'),payload);return batch.commit();};
 await assertSucceeds(send());
 await assertFails(send());
 await assertFails(getDoc(doc(db,'messages','valid')));
 await assertSucceeds(getDoc(doc(env.authenticatedContext('owner',{admin:true}).firestore(),'messages','valid')));
});
test('draft screenshots cannot be downloaded without administrator authorization',async()=>{
 const admin=env.authenticatedContext('owner',{admin:true});
 const bytes=new Uint8Array([137,80,78,71,13,10,26,10]);
 await assertSucceeds(uploadBytes(ref(admin.storage(),'projects/draft/test.png'),bytes,{contentType:'image/png'}));
 await assertFails(getBytes(ref(env.unauthenticatedContext().storage(),'projects/draft/test.png')));
 await assertSucceeds(uploadBytes(ref(admin.storage(),'projects/published/test.png'),bytes,{contentType:'image/png'}));
 await assertSucceeds(getBytes(ref(env.unauthenticatedContext().storage(),'projects/published/test.png')));
 await assertFails(uploadBytes(ref(env.authenticatedContext('visitor').storage(),'projects/published/bad.png'),bytes,{contentType:'image/png'}));
});
