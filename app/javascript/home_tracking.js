import ahoy from 'ahoy.js'

document.addEventListener('DOMContentLoaded', function() {
  // Track "Start now" button for paper applications
  const startNowButton = document.getElementById('start-now');
  if (startNowButton) {
    startNowButton.addEventListener('click', function() {
      ahoy.track("Paper Application Started", {
        button: "start-now",
        page: "home",
        action: "process_paper_application"
      });
    });
  }

  // Track "Look up" button for online applications
  const lookupForm = document.querySelector('form[action*="home_online_search"]');
  if (lookupForm) {
    const lookupButton = lookupForm.querySelector('input[type="submit"]');
    if (lookupButton) {
      lookupButton.addEventListener('click', function() {
        ahoy.track("Online Application Lookup", {
          button: "look-up",
          page: "home",
          action: "lookup_online_application"
        });
      });
    }
  }

  // Track "Search" button for completed applications
  const searchForm = document.querySelector('form[action*="home_completed_search"]');
  if (searchForm) {
    const searchButton = searchForm.querySelector('input[type="submit"]');
    if (searchButton) {
      searchButton.addEventListener('click', function() {
        ahoy.track("Application Search", {
          button: "search",
          page: "home",
          action: "search_applications"
        });
      });
    }
  }
});
