// ── FLIGHTS ──
async function loadFlights(){ data.flights=await req('/api/partner/flights'); renderFlights(data.flights); }
function renderFlights(rows){
  const tb=document.getElementById('tb-flights'), em=document.getElementById('empty-flights');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(f=>listRow([
    {label:'Hãng bay', val:f.airline, cls:'w-1/4'},
    {label:'Hành trình', val:`${f.departure} <i class="fa-solid fa-arrow-right text-[10px] mx-1 text-muted"></i> ${f.arrival}`, cls:'w-1/4'},
    {label:'Thời gian', val:`${f.departureTime} - ${f.arrivalTime}`},
    {label:'Giá', val:fmtUSD(f.price)}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editFlight('${f.id}')"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('flight','${f.id}',decodeURIComponent('${encodeURIComponent(f.airline).replace(/'/g,"%27")}'))"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function openFlightModal(fl=null){
  document.getElementById('mflight-title').textContent=fl?'Sửa chuyến bay':'Thêm chuyến bay';
  document.getElementById('f-id').value=fl?.id??'';
  document.getElementById('f-slug').value=fl?.id??'';
  document.getElementById('f-slug').disabled=!!fl;
  ['airline','dep','arr','dep-time','arr-time','price','dur'].forEach(k=>{
    const mk=k==='dep'?'departure':k==='arr'?'arrival':k==='dep-time'?'departureTime':k==='arr-time'?'arrivalTime':k==='dur'?'duration':k;
    document.getElementById(`f-${k}`).value=fl?.[mk]??'';
  });
  setImg('f-logo', fl?.airlineLogo??'');
  openModal('modal-flight');
}
function editFlight(id){openFlightModal(data.flights.find(x=>x.id===id));}
async function saveFlight(){
  const id=document.getElementById('f-id').value;
  const body={id:id||v('f-slug')||`fl-${Date.now()}`,airline:v('f-airline'),airlineLogo:v('f-logo'),departure:v('f-dep'),arrival:v('f-arr'),departureTime:v('f-dep-time'),arrivalTime:v('f-arr-time'),price:parseFloat(v('f-price'))||0,duration:v('f-dur')};
  try{ if(id)await req(`/api/partner/flights/${id}`,'PUT',body); else await req('/api/partner/flights','POST',body); closeModal('modal-flight'); await loadFlights(); toast('Lưu thành công','success'); }catch(e){toast(e.message,'error');}
}