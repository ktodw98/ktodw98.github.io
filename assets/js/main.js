(function () {
  var themeStorageKey = "blog-theme";
  var localeStorageKey = "blog-locale";
  var root = document.documentElement;
  var toggleButton = document.getElementById("theme-toggle");
  var drawer = document.getElementById("mobile-drawer");
  var drawerOpenButton = document.getElementById("menu-toggle");
  var drawerCloseButton = document.getElementById("drawer-close");
  var drawerBackdrop = document.getElementById("mobile-drawer-backdrop");
  var drawerPanel = drawer ? drawer.querySelector("[data-drawer-panel]") : null;

  var i18nConfig = window.BLOG_I18N || {};
  var defaultLocale = i18nConfig.defaultLocale || "ko";
  var supportedLocales = Array.isArray(i18nConfig.supportedLocales)
    ? i18nConfig.supportedLocales
    : [defaultLocale];
  var messages = i18nConfig.messages || {};
  var currentLocale = defaultLocale;

  function normalizeLocale(locale) {
    var value = String(locale || "").toLowerCase().trim();
    return supportedLocales.indexOf(value) >= 0 ? value : defaultLocale;
  }

  function getStoredLocale() {
    try {
      return normalizeLocale(localStorage.getItem(localeStorageKey));
    } catch (error) {
      return defaultLocale;
    }
  }

  function getNestedValue(object, path) {
    if (!object || !path) return null;
    return String(path)
      .split(".")
      .reduce(function (acc, key) {
        if (!acc || typeof acc !== "object" || !(key in acc)) return null;
        return acc[key];
      }, object);
  }

  function getMessage(key) {
    var localized = getNestedValue(messages[currentLocale], key);
    if (typeof localized === "string" && localized.length > 0) return localized;

    var fallback = getNestedValue(messages[defaultLocale], key);
    if (typeof fallback === "string" && fallback.length > 0) return fallback;

    return key;
  }

  function applyI18n(scope) {
    var target = scope || document;

    Array.prototype.forEach.call(target.querySelectorAll("[data-i18n]"), function (node) {
      node.textContent = getMessage(node.getAttribute("data-i18n"));
    });

    Array.prototype.forEach.call(target.querySelectorAll("[data-i18n-placeholder]"), function (node) {
      node.setAttribute("placeholder", getMessage(node.getAttribute("data-i18n-placeholder")));
    });

    Array.prototype.forEach.call(target.querySelectorAll("[data-i18n-aria-label]"), function (node) {
      node.setAttribute("aria-label", getMessage(node.getAttribute("data-i18n-aria-label")));
    });

    Array.prototype.forEach.call(target.querySelectorAll("[data-i18n-title]"), function (node) {
      node.setAttribute("title", getMessage(node.getAttribute("data-i18n-title")));
    });
  }

  function syncLocaleSwitcherButtons() {
    Array.prototype.forEach.call(document.querySelectorAll("[data-locale-switch]"), function (button) {
      var locale = normalizeLocale(button.getAttribute("data-locale-switch"));
      button.classList.toggle("is-active", locale === currentLocale);
      button.setAttribute("aria-pressed", locale === currentLocale ? "true" : "false");
    });
  }

  function applyLocale(locale) {
    currentLocale = normalizeLocale(locale);
    root.lang = currentLocale;
    root.setAttribute("data-locale", currentLocale);
    applyI18n(document);
    syncLocaleSwitcherButtons();
  }

  function bindLocaleSwitchers() {
    Array.prototype.forEach.call(document.querySelectorAll("[data-locale-switch]"), function (button) {
      button.addEventListener("click", function () {
        var nextLocale = normalizeLocale(button.getAttribute("data-locale-switch"));
        if (nextLocale === currentLocale) return;
        try {
          localStorage.setItem(localeStorageKey, nextLocale);
        } catch (error) {}
        window.location.reload();
      });
    });
  }

  window.BlogI18n = {
    t: getMessage,
    getLocale: function () {
      return currentLocale;
    },
    apply: applyI18n
  };

  function getPreferredTheme() {
    try {
      var saved = localStorage.getItem(themeStorageKey);
      if (saved === "light" || saved === "dark") {
        return saved;
      }
    } catch (error) {}
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }

  function setGiscusTheme(theme) {
    var frame = document.querySelector("iframe.giscus-frame");
    if (!frame) return;
    frame.contentWindow.postMessage({ giscus: { setConfig: { theme: theme } } }, "https://giscus.app");
  }

  function applyTheme(theme) {
    root.setAttribute("data-theme", theme);
    if (toggleButton) {
      toggleButton.textContent = theme === "dark" ? getMessage("theme.light_mode") : getMessage("theme.dark_mode");
    }
    setGiscusTheme(theme);
  }

  var currentTheme = getPreferredTheme();
  applyLocale(getStoredLocale());
  bindLocaleSwitchers();
  applyTheme(currentTheme);

  if (toggleButton) {
    toggleButton.addEventListener("click", function () {
      currentTheme = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
      try {
        localStorage.setItem(themeStorageKey, currentTheme);
      } catch (error) {}
      applyTheme(currentTheme);
    });
  }

  function setDrawerState(isOpen) {
    if (!drawer) return;
    drawer.hidden = !isOpen;
    drawer.setAttribute("aria-hidden", isOpen ? "false" : "true");
    root.classList.toggle("drawer-open", isOpen);
    if (drawerOpenButton) {
      drawerOpenButton.setAttribute("aria-expanded", isOpen ? "true" : "false");
    }
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

  if (drawer) {
    drawer.addEventListener("click", function (event) {
      if (event.target === drawer) {
        setDrawerState(false);
        return;
      }

      if (drawerPanel && !event.target.closest("[data-drawer-panel]")) {
        setDrawerState(false);
      }
    });
  }

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      setDrawerState(false);
    }
  });

  function slugify(text) {
    var value = String(text || "").trim().toLowerCase();

    if (typeof value.normalize === "function") {
      value = value.normalize("NFKD").replace(/[\u0300-\u036f]/g, "");
    }

    return value
      .replace(/[^a-z0-9\u00c0-\u024f\u3040-\u30ff\u3400-\u9fbf\uac00-\ud7af\s-]/g, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-");
  }

  function escapeHtml(value) {
    return String(value || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function buildToc() {
    var toc = document.getElementById("toc-list");
    var content = document.querySelector(".js-rich-content");
    if (!toc || !content) return;
    if (window.matchMedia("(max-width: 979px)").matches) {
      toc.innerHTML = "<p class=\"meta\">" + getMessage("toc.desktop_only") + "</p>";
      return;
    }

    var headings = content.querySelectorAll("h2, h3");
    if (!headings.length) {
      toc.innerHTML = "<p class=\"meta\">" + getMessage("toc.no_sections") + "</p>";
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

  function syncPostsSubnav() {
    var root = document.querySelector("[data-posts-subnav-root]");
    if (!root) return;

    var params = new URLSearchParams(window.location.search);
    var postsUrl = root.getAttribute("data-posts-url") || "/posts/";
    var currentCategory = (params.get("category") || root.getAttribute("data-current-category") || "").toLowerCase();
    var currentSubcategory = (params.get("subcategory") || root.getAttribute("data-current-subcategory") || "").toLowerCase();
    var allPosts = root.querySelector("[data-posts-subnav-all]");
    var categoryItems = root.querySelectorAll("[data-category-id]");
    var secondaryNav = root.querySelector("[data-posts-subnav-secondary]");
    var taxonomyNode = root.querySelector("[data-posts-subnav-taxonomy]");
    var taxonomy = [];

    if (taxonomyNode) {
      try {
        taxonomy = JSON.parse(taxonomyNode.textContent || "[]");
      } catch (error) {
        taxonomy = [];
      }
    }

    if (allPosts) {
      allPosts.classList.toggle("is-active", !currentCategory && window.location.pathname === postsUrl);
    }

    Array.prototype.forEach.call(categoryItems, function (item) {
      var itemCategory = (item.getAttribute("data-category-id") || "").toLowerCase();
      item.classList.toggle("is-active", !!currentCategory && itemCategory === currentCategory);
    });

    if (!secondaryNav) return;

    if (!currentCategory) {
      secondaryNav.hidden = true;
      secondaryNav.innerHTML = "";
      return;
    }

    var currentCategoryRecord = taxonomy.find(function (category) {
      return String(category.id || "").toLowerCase() === currentCategory;
    });
    var subcategories = currentCategoryRecord && Array.isArray(currentCategoryRecord.subcategories)
      ? currentCategoryRecord.subcategories.filter(function (subcategory) {
          return subcategory && subcategory.active === true;
        })
      : [];

    if (!subcategories.length) {
      secondaryNav.hidden = true;
      secondaryNav.innerHTML = "";
      return;
    }

    secondaryNav.innerHTML = subcategories
      .map(function (subcategory) {
        var subcategoryId = String(subcategory.id || "");
        var isActive = currentSubcategory && subcategoryId.toLowerCase() === currentSubcategory;
        var href = postsUrl + "?category=" + encodeURIComponent(currentCategoryRecord.id) + "&subcategory=" + encodeURIComponent(subcategoryId);
        return (
          "<a class=\"posts-subnav-item posts-subnav-item-secondary" +
          (isActive ? " is-active" : "") +
          "\" href=\"" + href + "\">" +
          escapeHtml(subcategory.label || subcategoryId) +
          "</a>"
        );
      })
      .join("");
    secondaryNav.hidden = false;
  }

  function filterPostsByQuery() {
    var postList = document.getElementById("post-archive-list");
    if (!postList) return;

    var filterNotice = document.getElementById("active-tag-filter");
    var params = new URLSearchParams(window.location.search);
    var tag = params.get("tag");
    var category = params.get("category");
    var subcategory = params.get("subcategory");
    if (!tag && !category && !subcategory) return;

    var normalizedTag = tag ? tag.toLowerCase() : "";
    var normalizedCategory = category ? category.toLowerCase() : "";
    var normalizedSubcategory = subcategory ? subcategory.toLowerCase() : "";
    var visibleCount = 0;
    var items = postList.querySelectorAll("li[data-tags]");
    Array.prototype.forEach.call(items, function (item) {
      var rawTags = item.getAttribute("data-tags") || "";
      var tags = rawTags.split("|");
      var rawCategory = (item.getAttribute("data-category") || "").toLowerCase();
      var rawSubcategory = (item.getAttribute("data-subcategory") || "").toLowerCase();
      var tagMatched = !normalizedTag || tags.indexOf(normalizedTag) !== -1;
      var categoryMatched = !normalizedCategory || rawCategory === normalizedCategory;
      var subcategoryMatched = !normalizedSubcategory || rawSubcategory === normalizedSubcategory;
      var matched = tagMatched && categoryMatched && subcategoryMatched;
      item.hidden = !matched;
      if (matched) visibleCount += 1;
    });

    if (filterNotice) {
      filterNotice.hidden = false;
      var labels = [];
      if (tag) labels.push("#" + tag);
      if (category) labels.push(getMessage("search.filter_category_prefix") + ":" + category);
      if (subcategory) labels.push(getMessage("search.filter_subcategory_prefix") + ":" + subcategory);
      filterNotice.textContent = getMessage("search.filter_prefix") + " " + labels.join(" + ") + " (" + visibleCount + ")";
    }
  }

  buildToc();
  syncPostsSubnav();
  filterPostsByQuery();
})();
