import ahoy from 'ahoy.js'

// Generic click tracking for the entire application
document.addEventListener('DOMContentLoaded', function() {

  // Helper function to get application ID from the page
  function getApplicationId() {
    const wrapper = document.getElementById('wrapper');
    return wrapper ? wrapper.dataset.applicationId : null;
  }

  // Helper function to get the current page context
  function getPageContext() {
    const path = window.location.pathname;
    const pageName = path.split('/').filter(Boolean).join('_') || 'home';
    const applicationId = getApplicationId();

    const context = {
      page: pageName,
      url: path
    };

    // Only add application_id if it exists
    if (applicationId) {
      context.application_id = applicationId;
    }

    return context;
  }

  // Helper function to get text content from an element
  function getElementText(element) {
    // Try to get button text, value, or aria-label
    return element.textContent?.trim() ||
           element.value ||
           element.getAttribute('aria-label') ||
           element.getAttribute('title') ||
           'unknown';
  }

  // Helper function to get form context
  function getFormContext(element) {
    const form = element.closest('form');
    if (form) {
      return {
        form_action: form.action,
        form_method: form.method,
        form_id: form.id || null
      };
    }
    return {};
  }

  // Track button clicks (submit buttons, regular buttons)
  document.addEventListener('click', function(event) {
    const target = event.target;

    // Handle submit buttons and regular buttons
    if (target.matches('button, input[type="submit"], input[type="button"], .govuk-button')) {
      const eventData = {
        element_type: 'button',
        button_text: getElementText(target),
        button_id: target.id || null,
        button_class: target.className || null,
        ...getPageContext(),
        ...getFormContext(target)
      };

      ahoy.track('Button Click', eventData);
    }

    // Handle links (but not submit buttons styled as links)
    else if (target.matches('a') && !target.matches('.govuk-button')) {
      const eventData = {
        element_type: 'link',
        link_text: getElementText(target),
        link_href: target.href,
        link_id: target.id || null,
        link_class: target.className || null,
        ...getPageContext()
      };

      ahoy.track('Link Click', eventData);
    }
  });

  // Track radio button changes
  document.addEventListener('change', function(event) {
    const target = event.target;

    if (target.matches('input[type="radio"]')) {
      const label = document.querySelector(`label[for="${target.id}"]`);
      const labelText = label ? label.textContent.trim() : null;

      const eventData = {
        element_type: 'radio',
        radio_name: target.name,
        radio_value: target.value,
        radio_label: labelText,
        radio_id: target.id || null,
        ...getPageContext(),
        ...getFormContext(target)
      };

      ahoy.track('Radio Selection', eventData);
    }

    // Track checkbox changes
    else if (target.matches('input[type="checkbox"]')) {
      const label = document.querySelector(`label[for="${target.id}"]`);
      const labelText = label ? label.textContent.trim() : null;

      const eventData = {
        element_type: 'checkbox',
        checkbox_name: target.name,
        checkbox_value: target.value,
        checkbox_checked: target.checked,
        checkbox_label: labelText,
        checkbox_id: target.id || null,
        ...getPageContext(),
        ...getFormContext(target)
      };

      ahoy.track('Checkbox Change', eventData);
    }

    // Track select dropdown changes
    else if (target.matches('select')) {
      const selectedOption = target.options[target.selectedIndex];

      const eventData = {
        element_type: 'select',
        select_name: target.name,
        select_value: target.value,
        select_text: selectedOption ? selectedOption.text : null,
        select_id: target.id || null,
        ...getPageContext(),
        ...getFormContext(target)
      };

      ahoy.track('Select Change', eventData);
    }
  });

  // Optional: Track form submissions
  document.addEventListener('submit', function(event) {
    const form = event.target;

    const eventData = {
      element_type: 'form',
      form_action: form.action,
      form_method: form.method,
      form_id: form.id || null,
      ...getPageContext()
    };

    ahoy.track('Form Submit', eventData);
  });
});
