// ── DASHBOARD ──
async function loadDashboard(){
  const st = await req('/api/partner/stats');
  document.getElementById('st-dest').textContent=st.destinations;
  document.getElementById('st-hotel').textContent=st.hotels;
  document.getElementById('st-flight').textContent=st.flights;
  document.getElementById('st-tour').textContent=st.tours;
  document.getElementById('st-upcoming').textContent=st.tripsUpcoming;
}