(function () {
  var storageKey = "blog-theme";
  var root = document.documentElement;
  var toggleButton = document.getElementById("theme-toggle");

  function getPreferredTheme() {
    var saved = localStorage.getItem(storageKey);
    if (saved === "light" || saved === "dark") {
      return saved;
    }
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }

  function setGiscusTheme(theme) {
    var frame = document.querySelector("iframe.giscus-frame");
    if (!frame) return;
    frame.contentWindow.postMessage(
      { giscus: { setConfig: { theme: theme } } },
      "https://giscus.app"
    );
  }

  function applyTheme(theme) {
    root.setAttribute("data-theme", theme);
    if (toggleButton) {
      toggleButton.textContent = theme === "dark" ? "Light Mode" : "Dark Mode";
    }
    setGiscusTheme(theme);
  }

  var currentTheme = getPreferredTheme();
  applyTheme(currentTheme);

  if (toggleButton) {
    toggleButton.addEventListener("click", function () {
      currentTheme = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
      localStorage.setItem(storageKey, currentTheme);
      applyTheme(currentTheme);
    });
  }
})();
