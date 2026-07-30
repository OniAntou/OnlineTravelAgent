const fs = require('fs');
const path = require('path');

const modulesDir = path.join(__dirname, '../partner/scripts/modules');
const files = fs.readdirSync(modulesDir);

files.forEach(file => {
    if (file.endsWith('.js')) {
        const filePath = path.join(modulesDir, file);
        let content = fs.readFileSync(filePath, 'utf8');
        
        // Find things like: onclick="confirmDel('destination','${d.id}','${d.name}')"
        // and replace the 3rd argument with decodeURIComponent('${encodeURIComponent(d.name).replace(/'/g,"%27")}')
        
        // Use a regex that captures the first two args, and the inner variable of the 3rd arg.
        // Format is usually: onclick="confirmDel('type','${var.id}','${var.name}')"
        // Regex: /onclick="confirmDel\('([^']+)',\s*'(\$\{[^}]+\})',\s*'(\$\{[^}]+\})'\)/g
        
        content = content.replace(/onclick="confirmDel\('([^']+)',\s*'(\$\{[^}]+\})',\s*'(\$\{([^}]+)\})'\)"/g, (match, p1, p2, p3, p4) => {
            return `onclick="confirmDel('${p1}','${p2}',decodeURIComponent('\${encodeURIComponent(${p4}).replace(/'/g,\\"%27\\")}'))"`;
        });
        
        fs.writeFileSync(filePath, content);
    }
});
console.log("XSS fixed in modules.");
