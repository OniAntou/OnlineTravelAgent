const fs = require('fs');
const path = require('path');

const htmlPath = path.join(__dirname, '../partner/index.html');
const stylesDir = path.join(__dirname, '../partner/styles');
const scriptsDir = path.join(__dirname, '../partner/scripts');
const modulesDir = path.join(__dirname, '../partner/scripts/modules');

if (!fs.existsSync(stylesDir)) fs.mkdirSync(stylesDir, { recursive: true });
if (!fs.existsSync(modulesDir)) fs.mkdirSync(modulesDir, { recursive: true });

let html = fs.readFileSync(htmlPath, 'utf8');

// 1. Extract CSS
const styleMatch = html.match(/<style>([\s\S]*?)<\/style>/);
if (styleMatch) {
  fs.writeFileSync(path.join(stylesDir, 'main.css'), styleMatch[1].trim());
  html = html.replace(/<style>[\s\S]*?<\/style>/, '<link rel="stylesheet" href="styles/main.css" />');
}

// 2. Extract handleUpload from the renderUploadField block before we delete it
const handleUploadMatch = html.match(/async function handleUpload[\s\S]*?\n\}/);
let handleUploadCode = "";
if (handleUploadMatch) {
    handleUploadCode = handleUploadMatch[0];
}

// 3. Replace document.write inside HTML
const uploadFields = [
  ['ds-img', 'ds-img-preview', 'Ảnh Điểm đến'],
  ['h-img', 'h-img-preview', 'Ảnh đại diện'],
  ['r-img', 'r-img-preview', 'Ảnh Phòng'],
  ['f-logo', 'f-logo-preview', 'Logo Hãng Bay'],
  ['t-img', 't-img-preview', 'Ảnh Bìa Tour']
];

for (const [idInput, idImg, idLabel] of uploadFields) {
  const replacement = `
    <div class="col-span-2">
      <label class="text-[10px] uppercase tracking-widest text-muted font-bold block mb-2">${idLabel} (Upload Ảnh)</label>
      <div class="upload-box h-32 flex flex-col items-center justify-center group">
        <div class="text-silver group-hover:text-primary transition-all text-3xl mb-2"><i class="fa-solid fa-cloud-arrow-up"></i></div>
        <div class="text-xs font-bold text-muted group-hover:text-primary transition-all">Click để chọn file</div>
        <img id="${idImg}" class="upload-img">
        <input type="file" id="file-${idInput}" class="upload-input" accept="image/*" onchange="handleUpload(this, '${idInput}', '${idImg}')">
        <input type="hidden" id="${idInput}">
      </div>
    </div>
  `;
  const regex = new RegExp(`<script>\\s*document\\.write\\(renderUploadField\\('${idLabel}', '${idInput}', '${idImg}'\\)\\)\\s*<\\/script>`);
  html = html.replace(regex, replacement);
}

// 4. Remove renderUploadField script block entirely
// We use regex to remove the <script> block containing renderUploadField
html = html.replace(/<script>\s*function renderUploadField[\s\S]*?<\/script>/, '');

// 5. Extract Main Script
const curPageIdx = html.indexOf("let curPage='dashboard';");
if (curPageIdx === -1) {
    console.error("Could not find 'let curPage' text");
    process.exit(1);
}

const scriptStartIdx = html.lastIndexOf("<script>", curPageIdx);
const scriptEndIdx = html.lastIndexOf("</script>");

const scriptContent = html.substring(scriptStartIdx + 8, scriptEndIdx);

const sections = [
  { name: 'dashboard', marker: '// ── DASHBOARD ──' },
  { name: 'hotels', marker: '// ── HOTELS & ROOMS ──' },
  { name: 'flights', marker: '// ── FLIGHTS ──' },
  { name: 'tours', marker: '// ── TOURS ──' },
  { name: 'trips', marker: '// ── TRIPS ──' },
  { name: 'schedule', marker: '// ── TRIP SCHEDULE ──' },
  { name: 'users', marker: '// ── USERS ──' },
  { name: 'documents', marker: '// ── DOCUMENTS ──' },
  { name: 'destinations', marker: '// ── DESTINATIONS ──' },
  { name: 'categories', marker: '// ── CATEGORIES & MISC ──' },
];

let remainingCode = scriptContent;
const extractedModules = [];

const splitPoints = sections.map(s => ({ name: s.name, idx: remainingCode.indexOf(s.marker) }))
                            .filter(s => s.idx !== -1)
                            .sort((a,b) => a.idx - b.idx);

let currentIdx = 0;
// First part is app.js (globals, api, ui)
const globalsCode = remainingCode.substring(0, splitPoints[0].idx);
// Append handleUpload to app.js
fs.writeFileSync(path.join(scriptsDir, 'app.js'), globalsCode.trim() + '\n\n' + handleUploadCode);

for (let i = 0; i < splitPoints.length; i++) {
  const start = splitPoints[i].idx;
  const end = i < splitPoints.length - 1 ? splitPoints[i+1].idx : remainingCode.length;
  let codeChunk = remainingCode.substring(start, end).trim();
  
  fs.writeFileSync(path.join(modulesDir, `${splitPoints[i].name}.js`), codeChunk);
  extractedModules.push(`scripts/modules/${splitPoints[i].name}.js`);
}

// Replace in HTML
const newScriptTags = `
<script src="scripts/app.js"></script>
${extractedModules.map(m => `<script src="${m}"></script>`).join('\n')}
`;

html = html.substring(0, scriptStartIdx) + newScriptTags + html.substring(scriptEndIdx + 9);

fs.writeFileSync(htmlPath, html);
console.log("Refactoring complete.");
