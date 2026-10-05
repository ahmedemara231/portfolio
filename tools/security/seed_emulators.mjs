import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import fs from 'node:fs';
if(!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST)throw Error('This script only runs with local emulator hosts set.');
initializeApp({projectId:'demo-portfolio'});
const content=JSON.parse(fs.readFileSync('packages/core/assets/content.json','utf8'));
const db=getFirestore();const batch=db.batch();batch.set(db.doc('profile/main'),content.profile);
for(const [collection,rows] of Object.entries(content.collections))for(const [id,data] of Object.entries(rows))batch.set(db.doc(`${collection}/${id}`),data);
await batch.commit();
const auth=getAuth();
for(const [email,uid,admin] of [['studio@example.test','local-owner',true],['visitor@example.test','local-visitor',false]]){
 try{await auth.createUser({uid,email,password:'local-preview-only',emailVerified:true});}catch(e){if(e.code!=='auth/uid-already-exists'&&e.code!=='auth/email-already-exists')throw e;}
 await auth.setCustomUserClaims(uid,{admin});
}
console.log('Seeded demo-portfolio only. Owner: studio@example.test. Visitor: visitor@example.test. Local password: local-preview-only.');
