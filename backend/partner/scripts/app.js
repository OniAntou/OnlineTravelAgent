let curPage = 'dashboard';
let data = { hotels: [], tours: [] };
const API = window.location.hostname === 'localhost' ? 'http://localhost:3000' : '';

function getAuth() { return localStorage.getItem('partner_token') || ''; }

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  })[char]);
}
function safeClassNames(value) {
  return String(value ?? '').split(/\s+/).filter((token) => /^[\w\-[\]:/]+$/.test(token)).join(' ');
}
function encodeActionValue(value) {
  return encodeURIComponent(String(value ?? '')).replace(/'/g, '%27');
}
function decodeActionValue(value) { return decodeURIComponent(value); }

async function req(path, method = 'GET', body = null) {
  const options = { method, headers: {} };
  const auth = getAuth();
  if (auth) options.headers.Authorization = `Bearer ${auth}`;
  if (body) {
    options.headers['Content-Type'] = 'application/json';
    options.body = JSON.stringify(body);
  }
  const response = await fetch(API + path, options);
  if (!response.ok) throw new Error((await response.text()) || response.statusText);
  return response.json();
}

function setConnectionStatus(online) {
  document.getElementById('statusDot').className = online
    ? 'w-2 h-2 rounded-full bg-emerald-500 shadow-[0_0_12px_rgba(16,185,129,0.8)]'
    : 'w-2 h-2 rounded-full bg-red-500';
  document.getElementById('statusText').textContent = online ? 'Online' : 'Offline';
}
async function checkHealth() {
  try { await req('/health'); setConnectionStatus(true); }
  catch (error) {
    if (String(error.message).includes('401') || String(error.message).includes('Unauthorized')) {
      localStorage.removeItem('partner_token');
      location.reload();
      return;
    }
    setConnectionStatus(false);
  }
}

function navigate(page) {
  const allowedPages = ['dashboard', 'hotels', 'tours'];
  if (!allowedPages.includes(page)) return;
  document.querySelectorAll('.nav-item').forEach((element) => {
    element.classList.remove('active', 'bg-primary', 'text-white');
    element.classList.add('text-muted');
  });
  const nav = document.getElementById(`nav-${page}`);
  if (nav) {
    nav.classList.add('active', 'bg-primary', 'text-white');
    nav.classList.remove('text-muted');
  }
  document.querySelectorAll('.page').forEach((element) => element.classList.remove('active'));
  document.getElementById(`page-${page}`).classList.add('active');
  curPage = page;
  document.getElementById('pageTitle').textContent = ({ dashboard: 'Dashboard', hotels: 'Khách sạn', tours: 'Gói tour' })[page];
  document.getElementById('addBtn').style.display = page === 'hotels' || page === 'tours' ? 'flex' : 'none';
  loadPage(page);
}

function loadPage(page) {
  const loaders = { dashboard: loadDashboard, hotels: loadHotels, tours: loadTours };
  if (!loaders[page]) return;
  loaders[page]().catch((error) => {
    if (String(error.message).includes('401') || String(error.message).includes('Unauthorized')) {
      localStorage.removeItem('partner_token');
      toast('Phiên đã hết hạn, đang tải lại...', 'error');
      setTimeout(() => location.reload(), 1500);
    } else {
      toast(`Lỗi tải dữ liệu: ${error.message}`, 'error');
    }
  });
}
function refreshData() { loadPage(curPage); }
function filterTable(type) {
  const search = document.getElementById(`search-${type}`);
  const query = search ? search.value.trim().toLocaleLowerCase() : '';
  if (type === 'hotels') {
    renderHotels(data.hotels.filter((hotel) => `${hotel.name} ${hotel.location}`.toLocaleLowerCase().includes(query)));
  }
  if (type === 'tours') {
    renderTours(data.tours.filter((tour) => `${tour.name} ${tour.departure}`.toLocaleLowerCase().includes(query)));
  }
}
function openAddModal() {
  if (curPage === 'hotels') openHotelModal();
  if (curPage === 'tours') openTourModal();
}

const listRow = (cols, actions) => `
  <div class="flex items-center justify-between p-6 bg-white rounded-3xl shadow-sm border border-silver hover:shadow-glass hover:-translate-y-1 transition-all duration-700 ease-[cubic-bezier(0.32,0.72,0,1)]">
    <div class="flex flex-1 items-center gap-8">
      ${cols.map((c) => `<div class="${safeClassNames(c.cls)}"><div class="text-[10px] uppercase tracking-widest text-muted font-bold mb-1">${escapeHtml(c.label)}</div><div class="text-sm font-bold text-ink">${c.html??escapeHtml(c.val)}</div></div>`).join('')}
    </div>
    <div class="flex gap-2 ml-6">${actions}</div>
  </div>`;

function openModal(id) { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }
function toast(msg, type = 'info') {
  const element = document.createElement('div');
  element.className = 'toast';
  const dot = document.createElement('div');
  dot.className = `w-2 h-2 rounded-full ${type === 'error' ? 'bg-red-500' : 'bg-primary'}`;
  const message = document.createElement('span');
  message.className = 'text-ink';
  message.appendChild(document.createTextNode(String(msg ?? '')));
  element.append(dot, message);
  document.getElementById('toasts').appendChild(element);
  setTimeout(() => {
    element.style.opacity = '0';
    element.style.transform = 'translateY(20px)';
    setTimeout(() => element.remove(), 600);
  }, 3000);
}
const v = (id) => document.getElementById(id).value.trim();
const fmtUSD = (price) => price != null
  ? new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(price)
  : '—';
function resolveImageUrl(url) { return /^https?:\/\//i.test(url) ? url : API + url; }
function setImg(id, url) {
  document.getElementById(id).value = url;
  const image = document.getElementById(`${id}-preview`);
  if (url) { image.src = resolveImageUrl(url); image.classList.add('show'); }
  else image.classList.remove('show');
}

function confirmDel(type, id, name) {
  const paths = { hotel: `/api/partner/hotels/${id}`, tour: `/api/partner/tours/${id}` };
  const path = type === 'room'
    ? `/api/partner/hotels/${document.getElementById('h-id').value}/rooms/${id}`
    : paths[type];
  if (!path) return;
  document.getElementById('confirm-msg').textContent = `Chắc chắn xóa "${name}"?`;
  document.getElementById('confirm-ok').onclick = async () => {
    try {
      await req(path, 'DELETE');
      closeModal('modal-confirm');
      if (type === 'room') { await loadHotels(); editHotel(document.getElementById('h-id').value); }
      else await loadPage(curPage);
      toast('Đã xóa', 'success');
    } catch (error) { toast(error.message, 'error'); }
  };
  openModal('modal-confirm');
}

async function handleUpload(fileInput, hiddenId, imageId) {
  const file = fileInput.files[0];
  if (!file) return;
  const formData = new FormData();
  formData.append('file', file);
  try {
    const response = await fetch(`${API}/api/partner/upload`, {
      method: 'POST', headers: { Authorization: `Bearer ${getAuth()}` }, body: formData,
    });
    if (!response.ok) throw new Error('Upload failed');
    const json = await response.json();
    document.getElementById(hiddenId).value = json.url;
    const image = document.getElementById(imageId);
    image.src = resolveImageUrl(json.url);
    image.classList.add('show');
    toast('Upload thành công', 'success');
  } catch (error) { toast(error.message, 'error'); }
}

async function doLogin() {
  const email = document.getElementById('login-user').value.trim();
  const password = document.getElementById('login-pass').value.trim();
  if (!email || !password) return toast('Vui lòng nhập đủ thông tin', 'error');
  const button = document.getElementById('login-btn');
  button.textContent = 'Đang xử lý...';
  try {
    const response = await fetch(`${API}/api/auth/login`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email, password }),
    });
    if (!response.ok) throw new Error((await response.json()).message || 'Đăng nhập thất bại');
    const result = await response.json();
    if (!['partner', 'PARTNER', 'admin', 'ADMIN'].includes(result.user.role)) throw new Error('Tài khoản này không có quyền đối tác');
    localStorage.setItem('partner_token', result.token);
    document.getElementById('login-screen').style.display = 'none';
    toast('Đăng nhập thành công!', 'success');
    checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
  } catch (error) {
    button.innerHTML = 'Đăng nhập đối tác <i class="fa-solid fa-arrow-right ml-2"></i>';
    toast(error.message, 'error');
  }
}

async function initPartner() {
  document.querySelectorAll('.modal-overlay').forEach((overlay) => overlay.addEventListener('click', (event) => {
    if (event.target === overlay) overlay.classList.remove('open');
  }));
  try {
    await req('/api/partner/stats');
    document.getElementById('login-screen').style.display = 'none';
    checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
  } catch (_) {
    document.getElementById('login-screen').style.display = 'flex';
    document.getElementById('login-screen').style.opacity = '1';
  }
}
window.addEventListener('DOMContentLoaded', initPartner);
