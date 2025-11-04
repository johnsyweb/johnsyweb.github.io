/**
 * Mobile Menu - Vanilla JavaScript replacement for jQuery mobileMenu plugin
 * Converts navigation <ul> to <select> dropdown on mobile devices
 */
(function() {
  'use strict';

  function createMobileMenu(navUl, options) {
    const switchWidth = options.switchWidth || 480;
    const topOptionText = options.topOptionText || 'Menu';
    const prependTo = options.prependTo || 'body';
    
    let selectElement = null;
    let selectId = 'mobile-menu-' + Date.now();

    function isMobile() {
      return window.innerWidth < switchWidth;
    }

    function createSelect() {
      if (selectElement) {
        return selectElement;
      }

      selectElement = document.createElement('select');
      selectElement.id = selectId;
      selectElement.className = 'mnav';
      selectElement.setAttribute('aria-label', 'Main navigation');

      // Add top option if specified
      if (topOptionText) {
        const topOption = document.createElement('option');
        topOption.value = '';
        topOption.textContent = topOptionText;
        selectElement.appendChild(topOption);
      }

      // Convert list items to options
      const listItems = navUl.querySelectorAll('li');
      listItems.forEach(function(li) {
        const link = li.querySelector('a');
        if (link) {
          const option = document.createElement('option');
          option.value = link.getAttribute('href');
          option.textContent = link.textContent.trim();
          selectElement.appendChild(option);
        }
      });

      // Handle navigation
      selectElement.addEventListener('change', function() {
        const selectedUrl = this.value;
        if (selectedUrl) {
          window.location.href = selectedUrl;
        }
      });

      return selectElement;
    }

    function updateMenu() {
      const mobile = isMobile();
      const existingSelect = document.querySelector('#' + selectId);

      if (mobile) {
        // Show mobile menu, hide regular nav
        if (!existingSelect) {
          const select = createSelect();
          const targetElement = document.querySelector(prependTo);
          if (targetElement) {
            targetElement.insertBefore(select, targetElement.firstChild);
          }
        }
        if (existingSelect) {
          existingSelect.style.display = 'block';
        }
        navUl.style.display = 'none';
      } else {
        // Hide mobile menu, show regular nav
        if (existingSelect) {
          existingSelect.style.display = 'none';
        }
        navUl.style.display = '';
      }
    }

    // Initial setup
    updateMenu();

    // Handle window resize
    let resizeTimeout;
    window.addEventListener('resize', function() {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(updateMenu, 100);
    });
  }

  // Initialize when DOM is ready
  window.addEventListener('DOMContentLoaded', function() {
    const navUl = document.querySelector('#sidebar nav ul');
    if (navUl) {
      createMobileMenu(navUl, {
        topOptionText: 'Menu',
        prependTo: '#sidebar nav',
        switchWidth: 480
      });
    }
  });
})();

