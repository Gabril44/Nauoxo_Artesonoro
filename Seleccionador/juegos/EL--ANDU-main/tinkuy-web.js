(() => {
  const style=document.createElement('style');
  style.textContent=`
    html,body{width:100%;height:100%;min-height:0!important;overflow:hidden;box-sizing:border-box}
    body{padding:56px 0 76px!important}
    #tinkuy-bar{position:fixed;inset:0 0 auto 0;height:52px;background:#182332;display:flex;align-items:center;gap:12px;padding:0 12px;z-index:99999;box-sizing:border-box;font:14px system-ui;color:white}
    #tinkuy-controls{position:fixed;bottom:0;left:0;right:0;min-height:68px;display:flex;justify-content:center;align-items:center;gap:8px;background:#182332;z-index:99999}
    #tinkuy-bar button,#tinkuy-controls button{background:#457134;color:white;border:0;border-radius:8px;padding:12px 16px;font:14px system-ui;touch-action:none;cursor:pointer}
    #tinkuy-controls button:active{background:#e98890}
    body>h1,body>.instructions{display:none}
    #game-container{max-width:none!important;max-height:none!important;width:100%!important;height:100%!important}
    #mobile-controls{display:none!important}
    @media(max-width:600px){#tinkuy-bar span{display:none}#tinkuy-controls button{padding:12px 10px}}
  `;
  document.head.append(style);
  const bar=document.createElement('div'); bar.id='tinkuy-bar';
  const back=document.createElement('button'); back.textContent='Volver a TINKUY';
  const full=document.createElement('button'); full.textContent='Pantalla completa';
  const hint=document.createElement('span'); hint.textContent='ESC: volver';
  bar.append(back,full,hint); document.body.append(bar);
  function closeGame(){ window.close(); setTimeout(()=>{hint.textContent='Si sigue abierto: Alt + F4 para volver a TINKUY';},150); }
  back.onclick=closeGame;
  full.onclick=()=>document.documentElement.requestFullscreen?.().catch(()=>{});
  window.addEventListener('keydown',e=>{if(e.key==='Escape'){e.preventDefault();e.stopImmediatePropagation();closeGame();}},true);
  const controls=document.createElement('div'); controls.id='tinkuy-controls';
  const pressed=new Map();
  function emit(type,key,code){window.dispatchEvent(new KeyboardEvent(type,{key,code,bubbles:true}));}
  const fluid=!!document.getElementById('game-container');
  const keys=fluid ? [['◀','ArrowLeft','ArrowLeft'],['▶','ArrowRight','ArrowRight'],['▲','ArrowUp','ArrowUp'],['▼','ArrowDown','ArrowDown']] : [['◀','ArrowLeft','ArrowLeft'],['▶','ArrowRight','ArrowRight'],['Saltar / continuar',' ','Space']];
  for(const [label,key,code] of keys){
    const b=document.createElement('button'); b.textContent=label;
    b.onpointerdown=e=>{e.preventDefault();b.setPointerCapture(e.pointerId);pressed.set(e.pointerId,[key,code]);emit('keydown',key,code);};
    const release=e=>{const k=pressed.get(e.pointerId);if(k){emit('keyup',...k);pressed.delete(e.pointerId);}};
    b.onpointerup=release;b.onpointercancel=release;b.onlostpointercapture=release;controls.append(b);
  }
  window.addEventListener('blur',()=>{for(const k of pressed.values())emit('keyup',...k);pressed.clear();});
  document.body.append(controls);
  const canvas=document.getElementById('gameCanvas');
  const fixed=document.body.contains(canvas)&&canvas.parentElement===document.body;
  let previousWidth=canvas.width,previousHeight=canvas.height;
  function fit(){
    if(fixed){const s=Math.min(innerWidth/800,Math.max(1,innerHeight-140)/600);canvas.style.width=`${800*s}px`;canvas.style.height=`${600*s}px`;canvas.style.boxSizing='border-box';}
    else if(typeof player!=='undefined'){
      const rx=canvas.width/Math.max(1,previousWidth),ry=canvas.height/Math.max(1,previousHeight);
      player.x*=rx;player.y*=ry;
      if(typeof player.targetX==='number')player.targetX*=rx;
      if(typeof player.targetY==='number')player.targetY*=ry;
      previousWidth=canvas.width;previousHeight=canvas.height;
    }
  }
  addEventListener('resize',fit);fit();
  // Existing fluid games recalculate their canvas after the shared toolbar is inserted.
  window.dispatchEvent(new Event('resize'));
})();
