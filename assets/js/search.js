(function () {
  var input = document.getElementById("global-search-input");
  var results = document.getElementById("global-search-results");
  var searchButton = document.getElementById("global-search-button");
  if (!input || !results) return;

  var sourceUrl = input.getAttribute("data-search-json");
  var docs = [];
  var maxResults = 8;

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
      results.innerHTML = "<li class=\"search-empty\">No matching results.</li>";
      return;
    }

    results.innerHTML = list
      .slice(0, maxResults)
      .map(function (post) {
        var tags = (post.tags || []).join(", ");
        var badge = post.type === "note" ? "Note" : "Post";
        return (
          "<li>" +
          "<a class=\"search-hit\" href=\"" + escapeHtml(post.url) + "\">" +
          "<span class=\"search-hit-title\">" + escapeHtml(post.title) + "</span>" +
          "<span class=\"search-hit-meta\">" + badge + (post.date ? " · " + escapeHtml(post.date) : "") + "</span>" +
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
        throw new Error("Failed to load search index.");
      }
      return response.json();
    })
    .then(function (data) {
      docs = data;
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
