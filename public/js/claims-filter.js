document.addEventListener("DOMContentLoaded", function () {
  var input = document.getElementById("claims-search");
  var profile = document.getElementById("claims-profile");
  var country = document.getElementById("claims-country");
  var countrySearch = document.getElementById("claims-country-search");
  var dropdown = document.getElementById("claims-country-dropdown");
  var selection = document.getElementById("claims-country-selection");
  var countryOptions = document.getElementById("claims-country-options");
  var countryEmpty = document.getElementById("claims-country-empty");
  var emptyMessage = document.getElementById("claims-search-empty");

  if (!input || !profile || !country || !countrySearch || !dropdown || !selection ||
      !countryOptions || !countryEmpty || !emptyMessage) {
    return;
  }

  var claimRows = Array.prototype.slice.call(
    document.querySelectorAll(".claims-availability tr[data-claim-index]")
  );
  var groups = {};
  var connectClaims = [
    "app",
    "account",
    "transaction_ip",
    "identification_mode",
    "ongoing_call",
    "name",
    "given_name",
    "family_name",
    "email",
    "email_verified",
    "phone_number",
    "phone_number_verified"
  ];

  claimRows.forEach(function (row) {
    var index = row.getAttribute("data-claim-index");
    groups[index] = groups[index] || [];
    groups[index].push(row);
  });

  Object.keys(groups).forEach(function (index) {
    groups[index][0].querySelectorAll(".claims-availability__status").forEach(function (cell) {
      cell.setAttribute("data-all-countries-value", cell.textContent);
    });
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

  function applyFilters() {
    var query = input.value.toLowerCase().replace(/\s+/g, "");
    var matches = 0;

    Object.keys(groups).forEach(function (index) {
      var rows = groups[index];
      var claim = rows[0].querySelector(".claims-availability__claim");
      var value = claim.textContent.toLowerCase().replace(/\s+/g, "");
      var claimName = (claim.querySelector("b:last-of-type") || claim).textContent.trim();
      var matchesProfile = profile.value !== "connect" || connectClaims.indexOf(claimName) !== -1;
      var isMatch = matchesProfile && (!query || isFuzzyMatch(value, query));

      rows[0].querySelectorAll(".claims-availability__status").forEach(function (cell) {
        if (country.value === "all") {
          cell.textContent = cell.getAttribute("data-all-countries-value");
          return;
        }

        var countryIndices = cell.getAttribute("data-country-indices").split(",");
        cell.textContent = countryIndices.indexOf(country.value) !== -1
          ? country.options[country.selectedIndex].textContent
          : "-";
      });

      rows.forEach(function (row) {
        row.hidden = !isMatch;
      });

      if (isMatch) {
        matches += 1;
      }
    });

    emptyMessage.hidden = matches !== 0;
  }

  function filterCountries() {
    var query = countrySearch.value.trim().toLowerCase();
    var matches = 0;
    var previousGroup = null;

    Array.prototype.forEach.call(countryOptions.querySelectorAll("button"), function (option) {
      var isMatch = option.textContent.toLowerCase().indexOf(query) !== -1;
      var item = option.parentNode;
      var group = item.getAttribute("data-country-group");
      item.hidden = !isMatch;
      item.classList.toggle("claims-availability__option--separator", isMatch && previousGroup !== null && group !== previousGroup);
      if (isMatch) {
        matches += 1;
        previousGroup = group;
      }
    });
    countryEmpty.hidden = matches !== 0;
  }

  country.hidden = true;
  dropdown.hidden = false;
  filterCountries();
  input.addEventListener("input", applyFilters);
  profile.addEventListener("change", applyFilters);
  countrySearch.addEventListener("input", filterCountries);
  dropdown.addEventListener("toggle", function () {
    if (dropdown.open) {
      countrySearch.focus();
    }
  });
  countryOptions.addEventListener("click", function (event) {
    var option = event.target.closest("button[data-country-value]");
    if (!option) {
      return;
    }

    country.value = option.getAttribute("data-country-value");
    selection.textContent = option.textContent;
    Array.prototype.forEach.call(countryOptions.querySelectorAll("button"), function (button) {
      button.setAttribute("aria-pressed", button === option ? "true" : "false");
    });
    countrySearch.value = "";
    filterCountries();
    dropdown.open = false;
    selection.focus();
    applyFilters();
  });
  document.addEventListener("click", function (event) {
    if (dropdown.open && !dropdown.contains(event.target)) {
      dropdown.open = false;
    }
  });
  dropdown.addEventListener("keydown", function (event) {
    if (event.key === "Escape" && dropdown.open) {
      dropdown.open = false;
      selection.focus();
    }
  });
});