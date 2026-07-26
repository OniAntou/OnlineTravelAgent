// ── HOTELS & ROOMS ──
async function loadHotels(){ data.hotels=await req('/api/partner/hotels'); renderHotels(data.hotels); }
function renderHotels(rows){
  const tb=document.getElementById('tb-hotels'), em=document.getElementById('empty-hotels');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(h=>listRow([
    {label:'Tên Khách Sạn', val:h.name, cls:'w-1/3'},
    {label:'Địa điểm', val:h.location, cls:'w-1/4'},
    {label:'Phòng', val:`<span class="px-2 py-1 bg-silver rounded-full text-xs">${h.rooms?.length||0}</span>`},
    {label:'Giá từ', val:`$${h.priceFrom}`}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editHotel('${h.id}')"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('hotel','${h.id}',decodeURIComponent('${encodeURIComponent(h.name).replace(/'/g,"%27")}'))"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function resolveImageUrl(url){ return /^https?:\/\//i.test(url) ? url : API + url; }
function setImg(id, url){
  document.getElementById(id).value = url;
  const img = document.getElementById(id+'-preview');
  if(url){ img.src = resolveImageUrl(url); img.classList.add('show'); }
  else { img.classList.remove('show'); }
}
function openHotelModal(hotel=null){
  document.getElementById('mhotel-title').textContent=hotel?'Cập nhật Khách Sạn':'Thêm mới Khách Sạn';
  document.getElementById('h-id').value=hotel?.id??'';
  document.getElementById('h-slug').value=hotel?.id??'';
  document.getElementById('h-slug').disabled=!!hotel;
  ['name','loc','addr','rating','price','desc'].forEach(k=>document.getElementById(`h-${k}`).value=hotel?.[k==='loc'?'location':k==='addr'?'address':k==='price'?'priceFrom':k==='desc'?'description':k]??'');
  setImg('h-img', hotel?.imagePath??'');
  document.getElementById('h-amenities').value=hotel?.amenities?.join(', ')??'';
  
  const roomSec=document.getElementById('h-rooms-section');
  if(hotel){ roomSec.style.display='block'; renderRooms(hotel.rooms||[]); } else { roomSec.style.display='none'; }
  openModal('modal-hotel');
}
function editHotel(id){openHotelModal(data.hotels.find(x=>x.id===id));}
async function saveHotel(){
  const id=document.getElementById('h-id').value;
  const body={ id:id||v('h-slug')||`hotel-${Date.now()}`, name:v('h-name'), location:v('h-loc'), address:v('h-addr'), rating:v('h-rating'), priceFrom:parseFloat(v('h-price'))||0, imagePath:v('h-img'), description:v('h-desc'), amenities: v('h-amenities').split(',').map(a=>a.trim()).filter(Boolean)};
  try{ if(id)await req(`/api/partner/hotels/${id}`,'PUT',body); else await req('/api/partner/hotels','POST',body); closeModal('modal-hotel'); await loadHotels(); toast(id?'Đã cập nhật':'Đã thêm mới','success'); }catch(e){toast(e.message,'error');}
}

function renderRooms(rooms){
  const tb = document.getElementById('h-rooms-list');
  if(!rooms.length){tb.innerHTML='<div class="text-xs text-muted">Khách sạn này chưa có phòng nào.</div>';return;}
  tb.innerHTML = rooms.map(r=>`
    <div class="flex items-center justify-between p-4 bg-white border border-silver rounded-2xl">
      <div><div class="text-sm font-bold text-ink">${r.name}</div><div class="text-xs text-muted">Sức chứa: ${r.capacity} khách - $${r.price}</div></div>
      <div class="flex gap-2">
        <button class="w-8 h-8 rounded-full bg-offwhite hover:bg-silver text-ink" onclick="editRoom('${r.id}')"><i class="fa-solid fa-pen text-xs"></i></button>
        <button class="w-8 h-8 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500" onclick="confirmDel('room','${r.id}',decodeURIComponent('${encodeURIComponent(r.name).replace(/'/g,"%27")}'))"><i class="fa-solid fa-trash text-xs"></i></button>
      </div>
    </div>
  `).join('');
}
function openRoomModal(room=null){
  document.getElementById('mroom-title').textContent=room?'Sửa Phòng':'Thêm Phòng';
  document.getElementById('r-id').value=room?.id??'';
  ['name','cap','price','desc'].forEach(k=>document.getElementById(`r-${k}`).value=room?.[k==='cap'?'capacity':k==='desc'?'description':k]??'');
  setImg('r-img', room?.imagePath??'');
  document.getElementById('r-amenities').value=room?.amenities?.join(', ')??'';
  openModal('modal-room');
}
function editRoom(id){
  const hotel=data.hotels.find(h=>h.id===document.getElementById('h-id').value);
  openRoomModal(hotel.rooms.find(r=>r.id===id));
}
async function saveRoom(){
  const hotelId=document.getElementById('h-id').value;
  const id=document.getElementById('r-id').value;
  const body={ name:v('r-name'), capacity:parseInt(v('r-cap'))||1, price:parseFloat(v('r-price'))||0, imagePath:v('r-img'), description:v('r-desc'), amenities:v('r-amenities').split(',').map(a=>a.trim()).filter(Boolean)};
  try{ 
    if(id) await req(`/api/partner/hotels/${hotelId}/rooms/${id}`,'PUT',body); 
    else await req(`/api/partner/hotels/${hotelId}/rooms`,'POST',body); 
    closeModal('modal-room'); await loadHotels(); editHotel(hotelId); toast('Lưu phòng thành công','success'); 
  }catch(e){toast(e.message,'error');}
}