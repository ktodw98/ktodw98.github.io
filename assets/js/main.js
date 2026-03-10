(function () {
  var storageKey = "blog-theme";
  var root = document.documentElement;
  var toggleButton = document.getElementById("theme-toggle");
  var drawer = document.getElementById("mobile-drawer");
  var drawerOpenButton = document.getElementById("menu-toggle");
  var drawerCloseButton = document.getElementById("drawer-close");
  var drawerBackdrop = document.getElementById("mobile-drawer-backdrop");

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

  function setDrawerState(isOpen) {
    if (!drawer) return;
    drawer.hidden = !isOpen;
    root.classList.toggle("drawer-open", isOpen);
  }

  if (drawerOpenButton) {
    drawerOpenButton.addEventListener("click", function () {
      setDrawerState(true);
    });
  }

  if (drawerCloseButton) {
    drawerCloseButton.addEventListener("click", function () {
      setDrawerState(false);
    });
  }

  if (drawerBackdrop) {
    drawerBackdrop.addEventListener("click", function () {
      setDrawerState(false);
    });
  }

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      setDrawerState(false);
    }
  });

  function slugify(text) {
    return String(text || "")
      .trim()
      .toLowerCase()
      .replace(/[^\p{L}\p{N}\s-]/gu, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-");
  }

  function buildToc() {
    var toc = document.getElementById("toc-list");
    var content = document.querySelector(".js-rich-content");
    if (!toc || !content) return;
    if (window.matchMedia("(max-width: 979px)").matches) {
      toc.innerHTML = "<p class=\"meta\">TOC is shown on desktop.</p>";
      return;
    }

    var headings = content.querySelectorAll("h2, h3");
    if (!headings.length) {
      toc.innerHTML = "<p class=\"meta\">No sections.</p>";
      return;
    }

    var items = Array.prototype.map.call(headings, function (heading, index) {
      if (!heading.id) {
        heading.id = slugify(heading.textContent) || "section-" + index;
      }
      return {
        id: heading.id,
        text: heading.textContent,
        level: heading.tagName.toLowerCase()
      };
    });

    toc.innerHTML =
      "<ul class=\"toc-items\">" +
      items
        .map(function (item) {
          return (
            "<li class=\"toc-entry toc-" +
            item.level +
            "\" data-target=\"" +
            item.id +
            "\"><a href=\"#" +
            item.id +
            "\">" +
            item.text +
            "</a></li>"
          );
        })
        .join("") +
      "</ul>";

    var tocEntries = toc.querySelectorAll("li.toc-entry[data-target]");
    function setActiveToc(targetId) {
      Array.prototype.forEach.call(tocEntries, function (entry) {
        entry.classList.toggle("active", entry.getAttribute("data-target") === targetId);
      });
    }

    var observer = new IntersectionObserver(
      function (entries) {
        var visible = entries
          .filter(function (entry) {
            return entry.isIntersecting;
          })
          .sort(function (a, b) {
            return a.boundingClientRect.top - b.boundingClientRect.top;
          });

        if (visible.length > 0) {
          setActiveToc(visible[0].target.id);
        }
      },
      { rootMargin: "-18% 0px -72% 0px", threshold: [0, 1] }
    );

    Array.prototype.forEach.call(headings, function (heading) {
      observer.observe(heading);
    });

    if (items.length > 0) {
      setActiveToc(items[0].id);
    }
  }

  function filterPostsByQuery() {
    var postList = document.getElementById("post-archive-list");
    if (!postList) return;

    var filterNotice = document.getElementById("active-tag-filter");
    var params = new URLSearchParams(window.location.search);
    var tag = params.get("tag");
    var category = params.get("category");
    if (!tag && !category) return;

    var normalizedTag = tag ? tag.toLowerCase() : "";
    var normalizedCategory = category ? category.toLowerCase() : "";
    var visibleCount = 0;
    var items = postList.querySelectorAll("li[data-tags]");
    Array.prototype.forEach.call(items, function (item) {
      var rawTags = item.getAttribute("data-tags") || "";
      var tags = rawTags.split("|");
      var rawCategory = (item.getAttribute("data-category") || "").toLowerCase();
      var tagMatched = !normalizedTag || tags.indexOf(normalizedTag) !== -1;
      var categoryMatched = !normalizedCategory || rawCategory === normalizedCategory;
      var matched = tagMatched && categoryMatched;
      item.hidden = !matched;
      if (matched) visibleCount += 1;
    });

    if (filterNotice) {
      filterNotice.hidden = false;
      var labels = [];
      if (tag) labels.push("#" + tag);
      if (category) labels.push("category:" + category);
      filterNotice.textContent = "Filtered by " + labels.join(" + ") + " (" + visibleCount + ")";
    }
  }

  buildToc();
  filterPostsByQuery();
})();
