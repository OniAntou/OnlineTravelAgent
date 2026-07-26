// ── TRIP SCHEDULE ──
async function openTripSchedule(id) {
  document.getElementById('ts-trip-id').value = id;
  await loadTripSchedule(id);
  openModal('modal-trip-schedule');
}

async function loadTripSchedule(id) {
  try {
    const data = await req(`/api/partner/trips/${id}/schedule`);
    renderTripSchedule(data.days);
    renderTripUpdates(data.updates);
  } catch (e) {
    toast(e.message, 'error');
  }
}

function renderTripSchedule(days) {
  const container = document.getElementById('ts-days-list');
  if (!days || !days.length) {
    container.innerHTML = `<div class="text-sm font-bold text-muted text-center py-10">Chuyến đi này chưa có lịch trình. Nhấn "Thêm ngày mới" để bắt đầu.</div>`;
    return;
  }
  container.innerHTML = days.map(d => `
    <div class="bg-white rounded-3xl p-6 shadow-sm border border-silver mb-4" data-day-id="${d.id}">
      <div class="flex items-center justify-between mb-4">
        <div class="text-lg font-extrabold text-ink">Ngày ${d.dayNumber} ${d.title ? `- <input type="text" class="inline-block bg-transparent border-b border-silver focus:border-primary outline-none text-lg font-extrabold text-ink w-48" value="${d.title || ''}" onblur="updateDayTitle('${d.id}', this.value)" placeholder="Thêm tiêu đề...">` : `- <input type="text" class="inline-block bg-transparent border-b border-silver focus:border-primary outline-none text-lg font-extrabold text-ink w-48" value="" onblur="updateDayTitle('${d.id}', this.value)" placeholder="Thêm tiêu đề...">`}</div>
        <button class="w-8 h-8 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center text-xs" onclick="deleteDay('${d.id}', ${d.dayNumber})"><i class="fa-solid fa-trash"></i></button>
      </div>
      <div class="flex flex-col gap-3" id="day-items-${d.id}">
        ${d.items.map((item, idx) => renderItemRow(item, idx)).join('')}
      </div>
      <button class="mt-3 w-full bg-offwhite hover:bg-primary/10 text-muted hover:text-primary font-bold py-2 rounded-xl transition-all text-xs border border-dashed border-silver hover:border-primary" onclick="addItemToDay('${d.id}')">
        <i class="fa-solid fa-plus mr-1"></i>Thêm mục
      </button>
    </div>
  `).join('');
}

function renderItemRow(item, idx) {
  return `
    <div class="flex items-start gap-3 bg-offwhite rounded-2xl p-4 border border-silver group" data-item-id="${item.id}">
      <div class="flex flex-col gap-1 w-14 shrink-0">
        <input type="text" class="w-full text-xs font-bold text-ink bg-white border border-silver rounded-lg p-1.5 text-center focus:border-primary outline-none" value="${item.startTime}" placeholder="08:00" onblur="updateItem('${item.id}','startTime',this.value)">
        <input type="text" class="w-full text-[10px] font-bold text-muted bg-white border border-silver rounded-lg p-1.5 text-center focus:border-primary outline-none" value="${item.endTime || ''}" placeholder="--:--" onblur="updateItem('${item.id}','endTime',this.value)">
      </div>
      <div class="flex-1 flex flex-col gap-1.5">
        <input type="text" class="w-full text-sm font-bold text-ink bg-white border border-silver rounded-lg px-3 py-1.5 focus:border-primary outline-none" value="${item.title}" placeholder="Tên hoạt động" onblur="updateItem('${item.id}','title',this.value)">
        <div class="flex gap-2">
          <input type="text" class="flex-1 text-xs text-muted bg-white border border-silver rounded-lg px-3 py-1.5 focus:border-primary outline-none" value="${item.locationName || ''}" placeholder="Địa điểm" onblur="updateItem('${item.id}','locationName',this.value)">
          <input type="text" class="flex-1 text-xs text-muted bg-white border border-silver rounded-lg px-3 py-1.5 focus:border-primary outline-none" value="${item.description || ''}" placeholder="Mô tả" onblur="updateItem('${item.id}','description',this.value)">
        </div>
      </div>
      <div class="flex flex-col gap-2 shrink-0 w-36">
        <select class="text-[10px] bg-white border border-silver rounded-lg p-1.5 font-bold" onchange="updateItem('${item.id}','statusOverride',this.value)">
          <option value="" ${!item.statusOverride ? 'selected' : ''}>-- Mặc định --</option>
          <option value="pending" ${item.statusOverride==='pending'?'selected':''}>Chưa diễn ra</option>
          <option value="ongoing" ${item.statusOverride==='ongoing'?'selected':''}>Đang diễn ra</option>
          <option value="completed" ${item.statusOverride==='completed'?'selected':''}>Đã hoàn thành</option>
          <option value="skipped" ${item.statusOverride==='skipped'?'selected':''}>Đã bỏ qua</option>
        </select>
        <input type="text" class="text-[10px] bg-white border border-silver rounded-lg px-2 py-1.5" placeholder="Ghi chú" value="${item.note || ''}" onblur="updateItem('${item.id}','note',this.value)">
      </div>
      <button class="w-7 h-7 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center text-xs opacity-0 group-hover:opacity-100 shrink-0" onclick="deleteItem('${item.id}')"><i class="fa-solid fa-xmark"></i></button>
    </div>
  `;
}

function renderTripUpdates(updates) {
  const container = document.getElementById('ts-updates-list');
  if (!updates || !updates.length) {
    container.innerHTML = `<div class="text-xs text-muted">Chưa có cập nhật nào.</div>`;
    return;
  }
  container.innerHTML = updates.map(u => `
    <div class="bg-offwhite p-4 rounded-xl border border-silver">
      <div class="text-[10px] text-muted font-bold mb-1">${new Date(u.createdAt).toLocaleString('vi-VN')}</div>
      <div class="text-sm font-semibold text-ink">${u.message}</div>
    </div>
  `).join('');
}

async function updateItem(itemId, field, value) {
  const tripId = document.getElementById('ts-trip-id').value;
  try {
    const body = {};
    body[field] = value || null;
    await req(`/api/partner/trips/${tripId}/schedule/items/${itemId}`, 'PUT', body);
    toast('Đã lưu', 'success');
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function deleteItem(itemId) {
  const tripId = document.getElementById('ts-trip-id').value;
  if (!confirm('Xóa mục này?')) return;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/items/${itemId}`, 'DELETE');
    toast('Đã xóa', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function addItemToDay(dayId) {
  const tripId = document.getElementById('ts-trip-id').value;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/items`, 'POST', {
      dayId,
      startTime: '08:00',
      title: 'Hoạt động mới',
    });
    toast('Đã thêm mục', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function updateDayTitle(dayId, title) {
  const tripId = document.getElementById('ts-trip-id').value;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/days/${dayId}`, 'PUT', { title: title || null });
  } catch (e) {
    // silent
  }
}

async function addTripDay() {
  const tripId = document.getElementById('ts-trip-id').value;
  try {
    const data = await req(`/api/partner/trips/${tripId}/schedule`);
    const maxDay = data.days.length ? Math.max(...data.days.map(d => d.dayNumber)) : 0;
    await req(`/api/partner/trips/${tripId}/schedule/days`, 'POST', {
      dayNumber: maxDay + 1,
      title: '',
    });
    toast('Đã thêm ngày mới', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function deleteDay(dayId, dayNumber) {
  const tripId = document.getElementById('ts-trip-id').value;
  if (!confirm(`Xóa ngày ${dayNumber} và tất cả mục bên trong?`)) return;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/days/${dayId}`, 'DELETE');
    toast('Đã xóa ngày', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function sendTripUpdate() {
  const tripId = document.getElementById('ts-trip-id').value;
  const msgInput = document.getElementById('ts-update-msg');
  const message = msgInput.value.trim();
  if (!message) return;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/updates`, 'POST', { message });
    msgInput.value = '';
    toast('Đã gửi thông báo!', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi gửi thông báo: ' + e.message, 'error');
  }
}



  async function doLogin(){
    const user = document.getElementById('login-user').value.trim();
    const pass = document.getElementById('login-pass').value.trim();
    if(!user || !pass) return toast('Vui lòng nhập đủ thông tin','error');
    document.getElementById('login-btn').innerText = 'Đang xử lý...';
    try {
      const r = await fetch(API+'/api/auth/login', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({email: user, password: pass})
      });
      const d = await r.json();
      if(!r.ok) throw new Error(d.message || 'Sai thông tin đăng nhập');
      if(d.user.role !== 'partner' && d.user.role !== 'PARTNER' && d.user.role !== 'admin' && d.user.role !== 'ADMIN') {
        throw new Error('Tài khoản này không có quyền đối tác');
      }
      localStorage.setItem('partner_token', d.token);
      
      document.getElementById('login-screen').style.opacity = '0';
      setTimeout(()=>document.getElementById('login-screen').style.display='none', 700);
      toast('Đăng nhập thành công!','success');
      
      checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
    } catch (e) {
      document.getElementById('login-btn').innerHTML = 'Đăng nhập đối tác <i class="fa-solid fa-arrow-right ml-2"></i>';
      toast(e.message, 'error');
    }
  }

  async function checkHealth(){
    try{
      await req('/health');
      const dot = document.getElementById('status-dot');
      if (dot) dot.className = 'w-3 h-3 rounded-full bg-green-500 shadow-[0_0_10px_rgba(34,197,94,0.5)]';
      const text = document.getElementById('status-text');
      if (text) text.textContent = 'System Online';
    }catch(e){
      const dot = document.getElementById('status-dot');
      if (dot) dot.className = 'w-3 h-3 rounded-full bg-red-500 shadow-[0_0_10px_rgba(239,68,68,0.5)]';
      const text = document.getElementById('status-text');
      if (text) text.textContent = 'System Offline';
      if(e.message && (e.message.includes('401')||e.message.includes('Unauthorized'))){
        localStorage.removeItem('partner_token');
        location.reload();
      }
    }
  }

  async function initPartner(){
    try{
      await req('/api/partner/stats');
      document.getElementById('login-screen').style.display='none';
      checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
    }catch(e){
      document.getElementById('login-screen').style.display='flex';
      document.getElementById('login-screen').style.opacity='1';
    }
  }
  
  window.onload = initPartner;