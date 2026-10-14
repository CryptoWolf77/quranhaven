"use strict";
const assert=require('node:assert/strict'), test=require('node:test');
const {webcrypto}=require('node:crypto');
const fs=require('node:fs'),path=require('node:path'),vm=require('node:vm');
const source=fs.readFileSync(path.join(__dirname,'../web/quran_service_worker.js'),'utf8');
const ORIGIN='https://quranhaven.org';
const ROOT='https://audio-cdn.tarteel.ai/quran/surah/abdulBasit/murattal/mp3/';
const URL1=ROOT+'001.mp3', URL2=ROOT+'002.mp3';
const DETAILS={url:URL1,readerName:'عبد الباسط',surahNumber:1,surahName:'الفاتحة'};
class Caches {
  constructor(){this.values=new Map();this.failMetadata=false;}
  async keys(){return [...this.values.keys()];}
  async delete(name){return this.values.delete(name);}
  async open(name){
    if(!this.values.has(name))this.values.set(name,new Map());const entries=this.values.get(name);
    return {keys:async()=>[...entries.keys()].map(u=>new Request(u)),
      match:async k=>entries.get(typeof k==='string'?k:k.url)?.clone(),
      delete:async k=>entries.delete(typeof k==='string'?k:k.url),
      put:async(k,r)=>{const u=typeof k==='string'?k:k.url;if(this.failMetadata&&u.includes('/_quran_audio_metadata/')){const e=new Error('quota');e.name='QuotaExceededError';throw e;}entries.set(u,r.clone());}};
  }
}
function harness(options={}){
  const listeners={},requests=[],messages=[],caches=options.caches||new Caches();let offline=false;
  const payload=Buffer.from(options.payload||'ID3-complete-recording');
  const context=vm.createContext({Request,Response,Headers,URL,Uint8Array,TextDecoder,TextEncoder,
    AbortController,crypto:webcrypto,console,setTimeout,clearTimeout,caches,
    self:{location:{origin:ORIGIN},navigator:{storage:{estimate:async()=>({quota:options.quota||2**32,usage:0})}},
      addEventListener:(type,fn)=>{listeners[type]=fn;},skipWaiting:async()=>{},
      clients:{get:async id=>({id,url:options.clientOrigin||ORIGIN+'/'}),claim:async()=>{},
        matchAll:async()=>[{id:'reader',url:ORIGIN+'/',postMessage:m=>messages.push(m)}]}},
    fetch:async(url,init)=>{requests.push({url,init});if(offline)throw Error('offline');
      if(options.fetch)return options.fetch(url,init);
      return new Response(payload,{headers:{'Content-Type':'audio/mpeg','Content-Length':options.declared||String(payload.length)}});}});
  vm.runInContext(source.replace('__QURAN_OFFLINE_VERSION__','a'.repeat(64)),context);
  return {context,caches,requests,messages,setOffline:value=>{offline=value;},
    async call(action,details={}){let result,work;listeners.message({source:{id:'reader'},data:{type:'quran-audio-command',action,...details},ports:[{postMessage:v=>{result=v;}}],waitUntil:p=>{work=p;}});await work;return result;}};
}
test('only explicit audio download stores a complete MP3 and survives worker restart offline',async()=>{
  const h=harness();assert.equal((await h.call('list')).entries.length,0);assert.equal(h.requests.length,0);
  const result=await h.call('download',DETAILS);assert.equal(result.state,'ready');assert.equal(result.entry.readerName,'عبد الباسط');
  assert.equal(result.entry.bytes,Buffer.byteLength('ID3-complete-recording'));assert.match(result.entry.sha256,/^[0-9a-f]{64}$/);
  assert.ok(h.requests.every(r=>r.init.credentials==='omit'&&r.init.redirect==='error'&&r.init.mode==='cors'));
  const restarted=harness({caches:h.caches});restarted.setOffline(true);
  assert.equal((await restarted.call('has',{url:URL1})).entry.sha256,result.entry.sha256);assert.equal(restarted.requests.length,0);
  assert.equal((await restarted.call('list')).entries.length,1);
});
test('audio policy rejects arbitrary, authenticated, queried, out-of-range and wrong-verse URLs',async()=>{
  const h=harness();for(const url of ['https://evil.example/001.mp3',ROOT+'000.mp3',ROOT+'115.mp3',URL1+'?token=x',URL1+'#x','https://u:p@audio-cdn.tarteel.ai/quran/surah/abdulBasit/murattal/mp3/001.mp3']){
    assert.equal((await h.call('download',{...DETAILS,url})).state,'error');}
  assert.equal((await h.call('download',{...DETAILS,surahNumber:2})).errorCode,'invalid_audio');assert.equal(h.requests.length,0);
});
test('failed audio format, quota and size checks never create a ready recording',async()=>{
  for(const options of [{payload:'<html>not audio</html>'},{quota:10},{declared:String(257*1024*1024)}]){
    const h=harness(options);assert.equal((await h.call('download',DETAILS)).state,'error');assert.equal((await h.call('list')).entries.length,0);
  }
});
test('corrupt stored audio is not available for playback',async()=>{
  const h=harness();await h.call('download',DETAILS);const cache=await h.caches.open('quran-haven-audio-v1');
  await cache.put(URL1,new Response('ID3-corrupt'));assert.equal((await h.call('has',{url:URL1})).entry,null);
});
test('metadata write failure rolls back only new recording and preserves saved audio and shell',async()=>{
  const h=harness();await h.call('download',DETAILS);const shell=await h.caches.open('quran-haven-shell-v1-fixture');await shell.put(ORIGIN+'/index.html',new Response('reader'));
  h.caches.failMetadata=true;const failed=await h.call('download',{...DETAILS,url:URL2,surahNumber:2,surahName:'البقرة'});
  assert.equal(failed.errorCode,'storage_full');assert.equal((await h.call('list')).entries.length,1);
  assert.equal((await h.call('has',{url:URL1})).entry.surahNumber,1);assert.equal(await (await h.caches.open('quran-haven-audio-v1')).match(URL2),undefined);
  assert.equal(await (await h.caches.open('quran-haven-shell-v1-fixture')).match(ORIGIN+'/index.html').then(r=>r.text()),'reader');
});
test('cancel waits for stream cancellation and never advertises a partial recording',async()=>{
  let started=false,cancelled=false;
  const h=harness({fetch:async(_url,init)=>new Response(new ReadableStream({
    async pull(controller){started=true;await new Promise(resolve=>init.signal.addEventListener('abort',resolve,{once:true}));controller.close();},
    cancel(){cancelled=true;}}),{headers:{'Content-Type':'audio/mpeg'}})});
  const download=h.call('download',DETAILS);while(!started)await new Promise(r=>setTimeout(r,1));
  assert.equal((await h.call('cancel')).state,'cancelled');assert.equal((await download).state,'cancelled');
  assert.equal((await h.call('list')).entries.length,0);
});
test('confirmed individual removal leaves other recordings and personal caches alone',async()=>{
  const h=harness();await h.call('download',DETAILS);await h.call('download',{...DETAILS,url:URL2,surahNumber:2,surahName:'البقرة'});
  const other=await h.caches.open('user-data-fixture');await other.put(ORIGIN+'/personal',new Response('notes'));
  assert.equal((await h.call('remove',{url:URL1})).state,'removed');assert.equal((await h.call('list')).entries.length,1);
  assert.equal((await h.call('has',{url:URL1})).entry,null);assert.equal(await (await other.match(ORIGIN+'/personal')).text(),'notes');
});
test('a foreign client cannot command any download',async()=>{
  const h=harness({clientOrigin:'https://evil.example/'});assert.equal(await h.call('download',DETAILS),undefined);assert.equal(h.requests.length,0);
});
