(function () {
  var input = document.getElementById("search-input");
  var results = document.getElementById("search-results");
  if (!input || !results) return;

  var sourceUrl = input.getAttribute("data-search-json");
  var posts = [];

  function render(list) {
    if (!list.length) {
      results.innerHTML = "<li>No matching posts.</li>";
      return;
    }

    results.innerHTML = list
      .map(function (post) {
        var tags = (post.tags || []).join(", ");
        return (
          "<li class=\"card\">" +
          "<h3><a href=\"" + post.url + "\">" + post.title + "</a></h3>" +
          "<p class=\"meta\">" + post.date + (tags ? " · " + tags : "") + "</p>" +
          "<p>" + post.description + "</p>" +
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
      render(posts);
      return;
    }
    var filtered = posts.filter(function (post) {
      var haystack = [
        post.title,
        post.description,
        (post.tags || []).join(" ")
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
      posts = data;
      render(posts);
      input.addEventListener("input", function (event) {
        filter(event.target.value);
      });
    })
    .catch(function (error) {
      results.innerHTML = "<li>" + error.message + "</li>";
    });
})();
