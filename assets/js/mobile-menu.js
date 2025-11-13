/**
 * Mobile Menu - Vanilla JavaScript replacement for jQuery mobileMenu plugin
 * Converts navigation <ul> to <select> dropdown on mobile devices
 */
(function() {
  'use strict';

  function initKeyboardNavigation(navUl) {
    if (!navUl) {
      return;
    }

    navUl.setAttribute('role', 'menubar');

    function applyRoles() {
      const links = navUl.querySelectorAll('a');
      links.forEach(function(link) {
        link.setAttribute('role', 'menuitem');
        if (link.parentElement) {
          link.parentElement.setAttribute('role', 'none');
        }
      });
    }

    function getLinks() {
      return Array.from(navUl.querySelectorAll('a'));
    }

    applyRoles();

    navUl.addEventListener('keydown', function(event) {
      const target = event.target;

      if (!(target instanceof HTMLElement) || target.tagName.toLowerCase() !== 'a') {
        return;
      }

      const links = getLinks();
      const currentIndex = links.indexOf(target);

      if (currentIndex === -1) {
        return;
      }

      let nextIndex = null;

      switch (event.key) {
        case 'ArrowRight':
        case 'ArrowDown':
          nextIndex = (currentIndex + 1) % links.length;
          break;
        case 'ArrowLeft':
        case 'ArrowUp':
          nextIndex = (currentIndex - 1 + links.length) % links.length;
          break;
        case 'Home':
          nextIndex = 0;
          break;
        case 'End':
          nextIndex = links.length - 1;
          break;
        default:
          return;
      }

      if (nextIndex !== null && links[nextIndex]) {
        event.preventDefault();
        links[nextIndex].focus();
      }
    });
  }

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
      initKeyboardNavigation(navUl);
    }
  });
})();

