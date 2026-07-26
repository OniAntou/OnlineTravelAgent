// ── USERS ──
async function loadUsers(){ data.users=await req('/api/partner/users'); renderUsers(data.users); }
function renderUsers(rows){
  const tb=document.getElementById('tb-users'), em=document.getElementById('empty-users');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(u=>listRow([
    {label:'Tên', val:u.name, cls:'w-1/3'},
    {label:'Email', val:u.email},
    {label:'Ngày tạo', val:new Date(u.createdAt).toLocaleDateString('vi-VN')}
  ], `
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('user','${u.id}',decodeURIComponent('${encodeURIComponent(u.name).replace(/'/g,"%27")}'))"><i class="fa-solid fa-ban"></i></button>
  `)).join('');
}
function openUserModal(){ document.getElementById('u-name').value=''; document.getElementById('u-email').value=''; document.getElementById('u-pass').value=''; openModal('modal-user'); }
async function saveUser(){
  try{ await req('/api/partner/users','POST',{name:v('u-name'), email:v('u-email'), password:v('u-pass')}); closeModal('modal-user'); await loadUsers(); toast('Đã tạo User','success'); }catch(e){toast(e.message,'error');}
}