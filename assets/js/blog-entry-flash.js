(function () {
  if (typeof window === "undefined") {
    return;
  }

  var search = window.location.search;
  if (!search || search.length <= 1) {
    return;
  }

  var params;
  try {
    params = new URLSearchParams(search);
  } catch (error) {
    return;
  }

  if (!params.has("entry")) {
    return;
  }

  var originalUrl = window.location.href;
  params.delete("entry");

  var remaining = params.toString();
  var cleanUrl =
    window.location.pathname +
    (remaining ? "?" + remaining : "") +
    window.location.hash;

  try {
    window.history.replaceState({}, "", cleanUrl);
  } catch (error) {
    // Non-blocking: ignore history failures (e.g. in privacy modes).
  }

  var flash = document.createElement("section");
  flash.className = "flash-message";
  flash.setAttribute("role", "status");
  flash.setAttribute("aria-live", "polite");

  var intro = document.createElement("strong");
  intro.textContent = "Heads up:";

  var message = document.createElement("p");
  message.appendChild(intro);
  message.appendChild(
    document.createTextNode(" Entry-based blog URLs are no longer supported. "),
  );

  var requestedLabel = document.createElement("span");
  requestedLabel.className = "flash-label";
  requestedLabel.textContent = "Requested URL:";

  var requestedValue = document.createElement("code");
  requestedValue.textContent = originalUrl;

  var referrerLabel = document.createElement("span");
  referrerLabel.className = "flash-label";
  referrerLabel.textContent = "Referrer:";

  var referrerValue = document.createElement("code");
  referrerValue.textContent = document.referrer || "Unavailable";

  var guidance = document.createElement("p");
  guidance.appendChild(
    document.createTextNode(
      "Please refresh or update that link so it points to the current permalink, or ask the site owner to do so.",
    ),
  );

  message.appendChild(requestedLabel);
  message.appendChild(requestedValue);
  message.appendChild(document.createTextNode(" "));
  message.appendChild(referrerLabel);
  message.appendChild(referrerValue);

  flash.appendChild(message);
  flash.appendChild(guidance);

  var container = document.getElementById("content");
  if (container) {
    container.prepend(flash);
  } else {
    document.body.prepend(flash);
  }

  var focusTarget = flash.querySelector("strong");
  if (focusTarget && typeof focusTarget.focus === "function") {
    focusTarget.setAttribute("tabindex", "-1");
    focusTarget.focus();
  }
})();
