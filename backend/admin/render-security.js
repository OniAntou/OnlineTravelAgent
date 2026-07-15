(function attachAdminRenderSecurity(root) {
  function escapeHtml(value) {
    return String(value ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
  }

  function encodeActionValue(value) {
    return encodeURIComponent(String(value ?? "")).replaceAll("'", "%27");
  }

  function decodeActionValue(value) {
    return decodeURIComponent(value);
  }

  function safeClassNames(value) {
    return String(value ?? "")
      .split(/\s+/)
      .filter((token) => /^[A-Za-z0-9_-]+$/.test(token))
      .join(" ");
  }

  root.AdminRenderSecurity = {
    escapeHtml,
    safeClassNames,
    encodeActionValue,
    decodeActionValue,
  };
})(globalThis);
