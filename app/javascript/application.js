  window.addEventListener("pageshow", function (event) {
    if (event.persisted) {
      document.dispatchEvent(new Event("htmx:afterSwap"));
    }
  });

  document.addEventListener("htmx:configRequest", function(event) {
    event.detail.headers["X-Timezone"] = Intl.DateTimeFormat().resolvedOptions().timeZone;
  });

  document.body.addEventListener("htmx:responseError", function(event) {
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

  // G-nav: "G then letter" for project nav (Linear-style). Only when project bar is present.
  (function () {
    let gNavTimeout = null;

    function isEditableTarget(el) {
      if (!el || !el.closest) return false;
      const tag = el.tagName && el.tagName.toLowerCase();
      if (tag === "input" || tag === "textarea") return true;
      if (el.isContentEditable) return true;
      return false;
    }

    document.addEventListener("keydown", function (e) {
      if (isEditableTarget(document.activeElement)) return;

      const bar = document.getElementById("project-nav-bar");
      const key = (e.key || "").toLowerCase();

      if (gNavTimeout !== null) {
        clearTimeout(gNavTimeout);
        gNavTimeout = null;
        if (key === "d" || key === "f" || key === "h" || key === "s") {
          e.preventDefault();
          if (!bar || !bar.dataset) return;
          const url =
            key === "d" ? bar.dataset.dashboardUrl :
            key === "f" ? bar.dataset.featuresUrl :
            key === "h" ? bar.dataset.historyUrl :
            bar.dataset.settingsUrl;
          if (url) window.location.href = url;
        } else if (key === "p" && document.body.dataset.prevFeatureUrl) {
          e.preventDefault();
          window.location.href = document.body.dataset.prevFeatureUrl;
        } else if (key === "n" && document.body.dataset.nextFeatureUrl) {
          e.preventDefault();
          window.location.href = document.body.dataset.nextFeatureUrl;
        }
        return;
      }

      if ((key === "g" && !e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) && bar) {
        e.preventDefault();
        gNavTimeout = setTimeout(function () {
          gNavTimeout = null;
        }, 1200);
      }
    });
  })();

  // Command palette (Ctrl+K) – Alpine.js component used by Shared::CommandPaletteComponent
  document.addEventListener("alpine:init", () => {
    Alpine.data("commandPalette", () => ({
      open: false,
      query: "",
      staticItems: [],
      searchResults: [],
      selectedIndex: 0,
      loading: false,
      searchUrl: null,
      csrfToken: "",
      debounceTimer: null,
      shortcuts: [],
      metaShortcuts: [],

      get items() {
        const q = this.query.trim().toLowerCase();
        if (!q) {
          return this.staticItems;
        }
        const words = q.split(/\s+/).filter(Boolean);
        const filtered = this.staticItems.filter((item) => {
          const title = (item.title || "").toLowerCase();
          const keywords = (item.keywords || "").toLowerCase();
          const text = `${title} ${keywords}`;
          return words.every((w) => text.includes(w));
        });
        return filtered.concat(this.searchResults);
      },

      initFromDataset() {
        try {
          const raw = this.$el.dataset.config;
          if (!raw) return;
          const config = JSON.parse(raw);
          this.searchUrl = config.searchUrl || null;
          this.staticItems = config.staticItems || [];
          this.csrfToken = config.csrfToken || "";
          this.shortcuts = config.shortcuts || [];
          this.metaShortcuts = config.metaShortcuts || [];
        } catch (e) {
          this.staticItems = [];
        }
      },

      runSearch() {
        clearTimeout(this.debounceTimer);
        const q = this.query.trim();
        if (!q) {
          this.searchResults = [];
          this.loading = false;
          this.selectedIndex = 0;
          return;
        }
        if (this.searchUrl) {
          this.loading = true;
          this.debounceTimer = setTimeout(() => {
            fetch(`${this.searchUrl}?q=${encodeURIComponent(q)}`, {
              method: "GET",
              headers: { "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" }
            })
              .then((res) => res.ok ? res.json() : { results: [] })
              .then((data) => {
                this.searchResults = data.results || [];
                this.selectedIndex = 0;
              })
              .catch(() => { this.searchResults = []; })
              .finally(() => { this.loading = false; });
          }, 300);
        } else {
          this.searchResults = [];
          this.loading = false;
        }
        this.$nextTick(() => {
          this.selectedIndex = Math.min(this.selectedIndex, Math.max(0, this.items.length - 1));
        });
      },

      selectResult(item) {
        if (!item || !item.url) return;
        if (item.method === "post") {
          fetch(item.url, {
            method: "POST",
            redirect: "manual",
            headers: {
              "X-CSRF-Token": this.csrfToken,
              "Accept": "text/html",
              "Content-Type": "application/x-www-form-urlencoded",
              "X-Requested-With": "XMLHttpRequest"
            }
          })
            .then((res) => {
              const loc = res.headers.get("Location");
              if (res.type === "opaqueredirect" || (res.status >= 300 && res.status < 400) || loc) {
                window.location.href = loc || res.url || item.url;
              } else {
                window.location.href = item.url;
              }
            })
            .catch(() => { window.location.href = item.url; });
        } else {
          window.location.href = item.url;
        }
      },

      typeBadge(type) {
        return { feature: "Feature", scenario: "Scenario", command: "Command", nav: "Go to" }[type] || type;
      }
    }));
  });

  // Make variables available globally
  window.showConfirmation = showConfirmation;
  window.showNotice = showNotice;
  window.showAlert = showAlert;
  window.showError = showError;
