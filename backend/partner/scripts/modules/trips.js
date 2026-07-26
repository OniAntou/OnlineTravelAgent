// ── TRIPS ──
async function loadTrips(){ data.trips=await req('/api/partner/trips'); renderTrips(data.trips); }
function renderTrips(rows){
  const tb=document.getElementById('tb-trips'), em=document.getElementById('empty-trips');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(t=>listRow([
    {label:'Điểm đến', val:t.destination, cls:'w-1/3'},
    {label:'Ngày đi', val:t.date},
    {label:'Khách', val:t.guests??'—'},
    {label:'Trạng thái', val:`<span class="px-3 py-1 bg-silver text-ink rounded-full text-[10px] uppercase">${t.status}</span>`}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-primary hover:text-white text-ink transition-all flex items-center justify-center" onclick="openTripSchedule('${t.id}')"><i class="fa-solid fa-calendar-alt"></i></button>
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editTrip('${t.id}')"><i class="fa-solid fa-eye"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('trip','${t.id}',decodeURIComponent('${encodeURIComponent(t.destination).replace(/'/g,"%27")}'))"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function editTrip(id){
  const t = data.trips.find(x=>x.id===id);
  document.getElementById('tr-id').value=id; 
  document.getElementById('tr-dest-disp').textContent=t.destination;
  document.getElementById('tr-price-disp').textContent=t.totalPrice ? fmtUSD(t.totalPrice) : 'Chưa có';
  document.getElementById('tr-flight-disp').textContent=t.flightId || 'Không có';
  document.getElementById('tr-hotel-disp').textContent=t.hotelId || 'Không có';
  document.getElementById('tr-status').value=t.status; 
  openModal('modal-trip');
}
async function saveTripStatus(){
  const id=document.getElementById('tr-id').value, status=document.getElementById('tr-status').value;
  try{ await req(`/api/partner/trips/${id}`,'PUT',{status,isUpcoming:!['Đã đi','Đã hủy'].includes(status)}); closeModal('modal-trip'); await loadTrips(); toast('Cập nhật thành công','success'); }catch(e){toast(e.message,'error');}
}