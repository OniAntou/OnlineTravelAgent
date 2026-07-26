// ── DESTINATIONS ──
async function loadDestinations(){ data.destinations=await req('/api/partner/destinations'); renderDestinations(data.destinations); }
function renderDestinations(rows){
  const tb=document.getElementById('tb-destinations'), em=document.getElementById('empty-destinations');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(d=>listRow([
    {label:'Tên', val:d.name, cls:'w-1/3'},
    {label:'Vị trí', val:d.location},
    {label:'Danh mục', val:d.category},
    {label:'Tags', val:(d.isFavorite?'<span class="px-2 py-1 bg-red-100 text-red-500 rounded-full text-xs mr-2"><i class="fa-solid fa-heart"></i></span>':'')+(d.isRecommended?'<span class="px-2 py-1 bg-blue-100 text-blue-500 rounded-full text-xs"><i class="fa-solid fa-thumbs-up"></i></span>':'')}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editDestination('${d.id}')"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('destination','${d.id}',decodeURIComponent('${encodeURIComponent(d.name).replace(/'/g,"%27")}'))"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function openDestinationModal(dest=null){
  document.getElementById('mdest-title').textContent=dest?'Cập nhật Điểm đến':'Thêm Điểm đến';
  document.getElementById('ds-id').value=dest?.id??'';
  document.getElementById('ds-slug').value=dest?.id??'';
  document.getElementById('ds-slug').disabled=!!dest;
  ['name','loc','cat','rating','desc'].forEach(k=>document.getElementById(`ds-${k}`).value=dest?.[k==='loc'?'location':k==='cat'?'category':k==='desc'?'description':k]??'');
  setImg('ds-img', dest?.imagePath??'');
  document.getElementById('ds-fav').checked=dest?.isFavorite??false;
  document.getElementById('ds-rec').checked=dest?.isRecommended??false;
  openModal('modal-destination');
}
function editDestination(id){openDestinationModal(data.destinations.find(x=>x.id===id));}
async function saveDestination(){
  const id=document.getElementById('ds-id').value;
  const body={ id:id||v('ds-slug')||`dest-${Date.now()}`, name:v('ds-name'), location:v('ds-loc'), category:v('ds-cat'), rating:v('ds-rating'), imagePath:v('ds-img'), description:v('ds-desc'), isFavorite:document.getElementById('ds-fav').checked, isRecommended:document.getElementById('ds-rec').checked };
  try{ if(id)await req(`/api/partner/destinations/${id}`,'PUT',body); else await req('/api/partner/destinations','POST',body); closeModal('modal-destination'); await loadDestinations(); toast(id?'Đã cập nhật':'Đã thêm mới','success'); }catch(e){toast(e.message,'error');}
}

async function loadCategories(){ data.categories=await req('/api/partner/categories'); renderCategories(data.categories); }
function renderCategories(rows){
  const tb=document.getElementById('tb-categories'), em=document.getElementById('empty-categories');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(c=>listRow([ {label:'ID', val:c.id, cls:'font-mono text-muted'}, {label:'Tên danh mục', val:c.name, cls:'w-1/2'} ], `
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('category','${c.id}',decodeURIComponent('${encodeURIComponent(c.name).replace(/'/g,"%27")}'))"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
async function saveCategory(){ try{ await req('/api/partner/categories','POST',{name:v('cat-name')}); closeModal('modal-category'); await loadCategories(); toast('Đã thêm','success'); }catch(e){toast(e.message,'error');} }

function confirmDel(type,id,name){
  document.getElementById('confirm-msg').textContent=`Chắc chắn xóa "${name}"?`;
  document.getElementById('confirm-ok').onclick = async ()=>{
    let path=`/api/partner/${type}s/${id}`;
    if(type==='room') path=`/api/partner/hotels/${document.getElementById('h-id').value}/rooms/${id}`;
    try{ await req(path,'DELETE'); closeModal('modal-confirm'); if(type==='room'){await loadHotels(); editHotel(document.getElementById('h-id').value);}else await loadPage(curPage); toast('Đã xóa','success'); }catch(e){toast(e.message,'error');}
  };
  openModal('modal-confirm');
}

function openModal(id){document.getElementById(id).classList.add('open');}
function closeModal(id){document.getElementById(id).classList.remove('open');}
document.querySelectorAll('.modal-overlay').forEach(o=>o.addEventListener('click',e=>{if(e.target===o)o.classList.remove('open');}));
function toast(msg,type='info'){
  const el=document.createElement('div'); el.className=`toast`;
  el.innerHTML=`<div class="w-2 h-2 rounded-full ${type==='error'?'bg-red-500':'bg-primary'}"></div><span class="text-ink">${msg}</span>`;
  document.getElementById('toasts').appendChild(el);
  setTimeout(()=>{el.style.opacity='0';el.style.transform='translateY(20px)';setTimeout(()=>el.remove(),600);},3000);
}
const v=id=>document.getElementById(id).value.trim();
const fmtUSD=p=>p!=null?new Intl.NumberFormat('en-US',{style:'currency',currency:'USD',maximumFractionDigits:0}).format(p):'—';

function promptLogin(){
  const user=prompt('Admin Username:');
  if(user===null) return false;
  const pass=prompt('Admin Password:');
  if(pass===null) return false;
  sessionStorage.setItem('adminAuth',btoa(user+':'+pass));
  return true;
}


async function initAdmin(){
  try{
    await req('/api/partner/stats');
    document.getElementById('login-screen').style.display='none';
    checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
  }catch(e){
    // Show login
    document.getElementById('login-screen').style.display='flex';
    document.getElementById('login-screen').style.opacity='1';
  }
}

initAdmin();