document.addEventListener("DOMContentLoaded", function () {
  var input = document.getElementById("claims-search");
  var emptyMessage = document.getElementById("claims-search-empty");

  if (!input || !emptyMessage) {
    return;
  }

  var claimRows = Array.prototype.slice.call(
    document.querySelectorAll(".claims-availability tr[data-claim-index]")
  );
  var groups = {};

  claimRows.forEach(function (row) {
    var index = row.getAttribute("data-claim-index");
    groups[index] = groups[index] || [];
    groups[index].push(row);
  });

  function isFuzzyMatch(value, query) {
    var position = 0;

    for (var index = 0; index < value.length && position < query.length; index += 1) {
      if (value[index] === query[position]) {
        position += 1;
      }
    }

    return position === query.length;
  }

  input.addEventListener("input", function () {
    var query = input.value.toLowerCase().replace(/\s+/g, "");
    var matches = 0;

    Object.keys(groups).forEach(function (index) {
      var rows = groups[index];
      var claim = rows[0].querySelector(".claims-availability__claim");
      var value = claim.textContent.toLowerCase().replace(/\s+/g, "");
      var isMatch = !query || isFuzzyMatch(value, query);

      rows.forEach(function (row) {
        row.hidden = !isMatch;
      });

      if (isMatch) {
        matches += 1;
      }
    });

    emptyMessage.hidden = matches !== 0;
  });
});