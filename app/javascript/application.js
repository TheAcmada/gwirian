  window.addEventListener("pageshow", function (event) {
    if (event.persisted) {
      document.dispatchEvent(new Event("htmx:afterSwap"));
    }
  });

  document.addEventListener("htmx:configRequest", function(event) {
    event.detail.headers["X-Timezone"] = Intl.DateTimeFormat().resolvedOptions().timeZone;
  });

  document.body.addEventListener("htmx:responseError", function(event) {
    console.log(event.detail);
    if (event.detail.xhr.status === 422) {
      event.preventDefault();
      let target = event.detail.target;
      target.innerHTML = event.detail.xhr.responseText;
    }
    else if (event.detail.xhr.status === 403) {
      event.preventDefault();
      const html = event.detail.xhr.responseText;
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, "text/html");
      const message = doc.body.textContent?.trim() || "Oh no! You are not allowed to do that.";
      showError(message);
    }
    else if (event.detail.xhr.status === 500) {
      event.preventDefault();
      showError(window.I18n?.error?.something_went_wrong || "Oops! Something went wrong. Please try again or contact support if the problem persists.");
    }
  });

  /**
   * Get the key for the scroll position in session storage
   * @returns {string}
   */
  function getScrollKey() {
    return window.location.pathname + '_scrollY';
  }

  /**
   * Save the scroll position in session storage when the page is swapped
   */
  document.body.addEventListener('htmx:beforeSwap', function(evt) {
    sessionStorage.setItem(getScrollKey(), window.scrollY);
  });

  /**
   * Restore the scroll position from session storage when the page is swapped
   */
  document.body.addEventListener('htmx:afterSwap', function(evt) {
    const scrollY = sessionStorage.getItem(getScrollKey());
    htmx.config.scrollIntoViewOnBoost = false;
    if (scrollY !== null) {
      window.scrollTo(0, parseInt(scrollY, 10));
      sessionStorage.removeItem(getScrollKey());
    }
    initializeDynamicFeatures();
  });

  // Alpine-powered HTML <dialog> confirmation
  function showConfirmation(question) {
    return new Promise((resolve) => {
      const dlg = document.getElementById("confirmDialog");
      if (!dlg) { resolve({ isConfirmed: confirm(question) }); return; }
      const msg = dlg.querySelector("[data-confirm-message]");
      const btnYes = dlg.querySelector("[data-confirm-yes]");
      const btnCancel = dlg.querySelector("[data-confirm-cancel]");
      msg.textContent = question;

      const cleanup = () => {
        btnYes.removeEventListener("click", onYes);
        btnCancel.removeEventListener("click", onCancel);
        dlg.close();
      };
      const onYes = () => { cleanup(); resolve({ isConfirmed: true }); };
      const onCancel = () => { cleanup(); resolve({ isConfirmed: false }); };
      btnYes.addEventListener("click", onYes, { once: true });
      btnCancel.addEventListener("click", onCancel, { once: true });
      dlg.showModal();
    });
  }

  function showNotice(message) {
    Alpine.store("notifications").noticeMessage = message;
    Alpine.store("notifications").showNotice = true;
    setTimeout(
      () => (Alpine.store("notifications").showNotice = false),
      5000
    );
  }

  function showAlert(message) {
    Alpine.store("notifications").alertMessage = message;
    Alpine.store("notifications").showAlert = true;
    setTimeout(
      () => (Alpine.store("notifications").showAlert = false),
      5000
    );
  }

  function showError(message) {
    Alpine.store("notifications").errorMessage = message;
    Alpine.store("notifications").showError = true;
    setTimeout(
      () => (Alpine.store("notifications").showError = false),
      5000
    );
  }

  function initializeDynamicFeatures() {
    tippy('[title]', {
      content(reference) {
        const title = reference.getAttribute('title');
        reference.removeAttribute('title');
        return title;
      },
      allowHTML: true,
      placement: 'top'
    });
  }


  initializeDynamicFeatures();

  // Make variables available globally
  window.showConfirmation = showConfirmation;
  window.showNotice = showNotice;
  window.showAlert = showAlert;
  window.showError = showError;
