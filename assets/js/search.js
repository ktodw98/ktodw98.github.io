(function () {
  var input = document.getElementById("global-search-input");
  var results = document.getElementById("global-search-results");
  var searchButton = document.getElementById("global-search-button");
  var i18n = window.BlogI18n;
  if (!input || !results) return;

  var sourceUrl = input.getAttribute("data-search-json");
  var docs = [];
  var maxResults = 8;
  function t(key) {
    if (i18n && typeof i18n.t === "function") return i18n.t(key);
    return key;
  }

  var typeLabels = {
    article: "search.type_article",
    tutorial: "search.type_tutorial",
    "case-study": "search.type_case_study",
    log: "search.type_log",
    reference: "search.type_reference"
  };

  function escapeHtml(value) {
    return String(value || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function closeResults() {
    results.hidden = true;
    results.innerHTML = "";
  }

  function openResults() {
    results.hidden = false;
  }

  function render(list) {
    if (!input.value.trim()) {
      closeResults();
      return;
    }

    openResults();

    if (!list.length) {
      results.innerHTML = "<li class=\"search-empty\">" + escapeHtml(t("search.no_results")) + "</li>";
      return;
    }

    results.innerHTML = list
      .slice(0, maxResults)
      .map(function (post) {
        var tags = (post.tags || []).join(", ");
        var category = post.category_label ? String(post.category_label) : "";
        var badgeKey = typeLabels[post.type] || "search.type_article";
        var badge = t(badgeKey);
        return (
          "<li>" +
          "<a class=\"search-hit\" href=\"" + escapeHtml(post.url) + "\">" +
          "<span class=\"search-hit-title\">" + escapeHtml(post.title) + "</span>" +
          "<span class=\"search-hit-meta\">" +
          badge +
          (post.date ? " · " + escapeHtml(post.date) : "") +
          (category ? " · " + escapeHtml(category) : "") +
          "</span>" +
          (tags ? "<span class=\"search-hit-tags\">" + escapeHtml(tags) + "</span>" : "") +
          "</a>" +
          "</li>"
        );
      })
      .join("");
  }

  function normalize(value) {
    return String(value || "").toLowerCase();
  }

  function filter(query) {
    var keyword = normalize(query).trim();
    if (!keyword) {
      render(docs);
      return;
    }
    var filtered = docs.filter(function (post) {
      var haystack = [
        post.title,
        post.description,
        (post.tags || []).join(" "),
        post.category_id || "",
        post.category_label || "",
        post.type
      ]
        .join(" ")
        .toLowerCase();
      return haystack.indexOf(keyword) !== -1;
    });
    render(filtered);
  }

  fetch(sourceUrl)
    .then(function (response) {
      if (!response.ok) {
        throw new Error(t("search.load_error"));
      }
      return response.json();
    })
    .then(function (data) {
      docs = data;
      closeResults();
      input.addEventListener("input", function (event) {
        filter(event.target.value);
      });

      if (searchButton) {
        searchButton.addEventListener("click", function () {
          filter(input.value);
          input.focus();
        });
      }

      input.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
          event.preventDefault();
          filter(input.value);
          var first = results.querySelector("a.search-hit");
          if (first) {
            window.location.href = first.getAttribute("href");
          }
        }
      });

      input.addEventListener("focus", function () {
        if (input.value.trim()) {
          filter(input.value);
        }
      });

      document.addEventListener("click", function (event) {
        if (!event.target.closest(".search-shell")) {
          closeResults();
        }
      });

      document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
          closeResults();
        }
      });
    })
    .catch(function (error) {
      openResults();
      results.innerHTML = "<li class=\"search-empty\">" + escapeHtml(error.message) + "</li>";
    });
})();
