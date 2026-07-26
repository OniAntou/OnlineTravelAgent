let curPage='dashboard';
let data={destinations:[],hotels:[],flights:[],tours:[],trips:[],categories:[],users:[],documents:[]};
const API = window.location.hostname==='localhost'?'http://localhost:3000':'';

function getAuth(){ return localStorage.getItem("partner_token")||""; }

async function req(path,method='GET',body=null){
  const opt={method,headers:{}};
  const auth=getAuth();
  if(auth) opt.headers['Authorization']='Bearer '+auth;
  if(body){opt.headers['Content-Type']='application/json';opt.body=JSON.stringify(body);}
  console.log('[REQ]',method,API+path,auth?'(with auth)':'(no auth)');
  const r=await fetch(API+path,opt);
  console.log('[RES]',r.status,r.statusText);
  if(!r.ok) throw new Error(await r.text()||r.statusText);
  return r.json();
}

async function checkHealth(){
  try{
    await req('/health');
    document.getElementById('statusDot').className='w-2 h-2 rounded-full bg-emerald-500 shadow-[0_0_12px_rgba(16,185,129,0.8)]';
    document.getElementById('statusText').textContent='Online';
  }catch(e){
    if(e.message.includes('401')||e.message.includes('Unauthorized')){
      localStorage.removeItem('partner_token');
      location.reload();
      return;
    }
    document.getElementById('statusDot').className='w-2 h-2 rounded-full bg-red-500';
    document.getElementById('statusText').textContent='Offline';
  }
}

function navigate(page){
  document.querySelectorAll('.nav-item').forEach(e=>{e.classList.remove('active','bg-primary','text-white'); e.classList.add('text-muted');});
  const el=document.getElementById(`nav-${page}`);
  if(el){ el.classList.add('active','bg-primary','text-white'); el.classList.remove('text-muted'); }
  document.querySelectorAll('.page').forEach(e=>e.classList.remove('active'));
  document.getElementById(`page-${page}`).classList.add('active');
  curPage=page;
  const titles={dashboard:'Dashboard',destinations:'Điểm đến',hotels:'Khách sạn',flights:'Chuyến bay',tours:'Gói tour',trips:'Đặt chỗ',categories:'Danh mục',users:'Người dùng',documents:'Hành trang'};
  document.getElementById('pageTitle').textContent=titles[page]||'Admin';
  
  const addBtn=document.getElementById('addBtn');
  if(['destinations','hotels','flights','tours','categories','users','documents'].includes(page)){addBtn.style.display='flex';}else{addBtn.style.display='none';}
  loadPage(page);
}

function loadPage(page){
  const loaders={
    dashboard:loadDashboard, destinations:loadDestinations, hotels:loadHotels,
    flights:loadFlights, tours:loadTours, trips:loadTrips,
    categories:loadCategories, users:loadUsers, documents:loadDocuments
  };
  if(loaders[page]) loaders[page]().catch(e=>{
    console.error('Load error:',e);
    if(e.message.includes('401')||e.message.includes('Unauthorized')){
      localStorage.removeItem('partner_token');
      toast('Phiên hết hạn, đang tải lại...','error');
      setTimeout(()=>location.reload(),1500);
    }else{
      toast('Lỗi tải dữ liệu: '+e.message,'error');
    }
  });
}
function refreshData(){loadPage(curPage);}
function openAddModal(){
  if(curPage==='destinations') openDestinationModal();
  if(curPage==='hotels') openHotelModal();
  if(curPage==='flights') openFlightModal();
  if(curPage==='tours') openTourModal();
  if(curPage==='categories') openModal('modal-category');
  if(curPage==='users') openUserModal();
  if(curPage==='documents') openDocumentModal();
}

const listRow = (cols, actions) => `
  <div class="flex items-center justify-between p-6 bg-white rounded-3xl shadow-sm border border-silver hover:shadow-glass hover:-translate-y-1 transition-all duration-700 ease-[cubic-bezier(0.32,0.72,0,1)]">
    <div class="flex flex-1 items-center gap-8">
      ${cols.map(c=>`<div class="${c.cls||''}"><div class="text-[10px] uppercase tracking-widest text-muted font-bold mb-1">${c.label}</div><div class="text-sm font-bold text-ink">${c.val}</div></div>`).join('')}
    </div>
    <div class="flex gap-2 ml-6">
      ${actions}
    </div>
  </div>`;

async function handleUpload(fileInput, hiddenId, imgId){
  const file = fileInput.files[0];
  if(!file) return;
  const fd = new FormData(); fd.append('file', file);
  try {
    const r = await fetch(API+'/api/partner/upload', {method:'POST', headers:{'Authorization':'Bearer '+getAuth()}, body:fd});
    if(!r.ok) throw new Error("Upload failed");
    const json = await r.json();
    document.getElementById(hiddenId).value = json.url;
    const imgEl = document.getElementById(imgId);
    imgEl.src = resolveImageUrl(json.url);
    imgEl.classList.add('show');
    toast("Upload thành công", "success");
  }catch(e){ toast(e.message, "error"); }
}