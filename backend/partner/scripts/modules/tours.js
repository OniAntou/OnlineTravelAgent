// ── TOURS ──
async function loadTours(){ data.tours=await req('/api/partner/tours'); renderTours(data.tours); }
function renderTours(rows){
  const tb=document.getElementById('tb-tours'), em=document.getElementById('empty-tours');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(t=>listRow([
    {label:'Tên Tour', val:t.name, cls:'w-1/3'},
    {label:'Khởi hành', val:t.departure},
    {label:'Giá', html:`${fmtUSD(t.price)} ${t.originalPrice?`<s class="text-muted font-normal ml-2">${fmtUSD(t.originalPrice)}</s>`:''}`},
    {label:'Tag', html:t.isPopular?'<span class="px-3 py-1 bg-primary text-white rounded-full text-[10px]">HOT</span>':''}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editTour(decodeActionValue('${encodeActionValue(t.id)}'))"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('tour',decodeActionValue('${encodeActionValue(t.id)}'),decodeActionValue('${encodeActionValue(t.name)}'))"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function openTourModal(tour=null){
  document.getElementById('mtour-title').textContent=tour?'Sửa tour':'Thêm tour';
  document.getElementById('t-id').value=tour?.id??'';
  document.getElementById('t-slug').value=tour?.id??'';
  document.getElementById('t-slug').disabled=!!tour;
  ['name','dep','dur','price','orig','dests','incl','desc'].forEach(k=>{
    const mk=k==='dep'?'departure':k==='dur'?'duration':k==='orig'?'originalPrice':k==='dests'?'destinations':k==='incl'?'includes':k==='desc'?'description':k;
    let v=tour?.[mk]??''; if(Array.isArray(v))v=v.join(', ');
    document.getElementById(`t-${k}`).value=v;
  });
  document.getElementById('t-depdate').value=tour?.departureDate??'';
  setImg('t-img', tour?.imagePath??'');
  document.getElementById('t-popular').checked=tour?.isPopular??false;
  document.getElementById('t-guide').checked=tour?.includesGuide??true;
  openModal('modal-tour');
}
function editTour(id){openTourModal(data.tours.find(x=>x.id===id));}
async function saveTour(){
  const id=document.getElementById('t-id').value;
  const body={id:id||v('t-slug')||`tour-${Date.now()}`,name:v('t-name'),departure:v('t-dep'),duration:v('t-dur'),departureDate:v('t-depdate')||null,price:parseFloat(v('t-price'))||0,originalPrice:parseFloat(v('t-orig'))||null,imagePath:v('t-img'),description:v('t-desc'),isPopular:document.getElementById('t-popular').checked,includesGuide:document.getElementById('t-guide').checked,destinations:v('t-dests').split(',').map(s=>s.trim()).filter(Boolean),includes:v('t-incl').split(',').map(s=>s.trim()).filter(Boolean)};
  try{ if(id)await req(`/api/partner/tours/${id}`,'PUT',body); else await req('/api/partner/tours','POST',body); closeModal('modal-tour'); await loadTours(); toast('Lưu thành công','success'); }catch(e){toast(e.message,'error');}
}
