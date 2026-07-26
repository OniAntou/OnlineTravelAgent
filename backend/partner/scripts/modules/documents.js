// ── DOCUMENTS ──
async function loadDocuments(){ data.documents=await req('/api/partner/documents'); renderDocuments(data.documents); }
function renderDocuments(rows){
  const tb=document.getElementById('tb-documents'), em=document.getElementById('empty-documents');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(d=>listRow([
    {label:'Icon', val:`<i class="fa-solid ${d.icon} ${d.color} text-xl"></i>`},
    {label:'Tiêu đề', val:d.title, cls:'w-1/3'},
    {label:'Mô tả', val:d.description}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editDocument('${d.id}')"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('document','${d.id}',decodeURIComponent('${encodeURIComponent(d.title).replace(/'/g,"%27")}'))"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function openDocumentModal(doc=null){
  document.getElementById('mdoc-title').textContent=doc?'Sửa Tài Liệu':'Thêm Tài Liệu';
  document.getElementById('d-id').value=doc?.id??'';
  ['title','icon','color','desc'].forEach(k=>document.getElementById(`d-${k}`).value=doc?.[k==='desc'?'description':k]??'');
  openModal('modal-document');
}
function editDocument(id){openDocumentModal(data.documents.find(x=>x.id===id));}
async function saveDocument(){
  const id=document.getElementById('d-id').value;
  const body={title:v('d-title'), icon:v('d-icon'), color:v('d-color'), description:v('d-desc')};
  try{ if(id)await req(`/api/partner/documents/${id}`,'PUT',body); else await req('/api/partner/documents','POST',body); closeModal('modal-document'); await loadDocuments(); toast('Lưu thành công','success'); }catch(e){toast(e.message,'error');}
}