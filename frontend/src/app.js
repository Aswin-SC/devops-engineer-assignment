const apiBaseUrl = window.API_BASE_URL || "/api";

async function refreshStatus() {
  const apiStatus = document.querySelector("#api-status");
  const dbStatus = document.querySelector("#db-status");
  const version = document.querySelector("#version");

  try {
    const response = await fetch(`${apiBaseUrl}/status`);
    if (!response.ok) {
      throw new Error(`API returned ${response.status}`);
    }
    const data = await response.json();
    apiStatus.textContent = data.api;
    dbStatus.textContent = data.database;
    version.textContent = data.version;
  } catch (error) {
    apiStatus.textContent = "unavailable";
    dbStatus.textContent = "unknown";
    version.textContent = "unknown";
  }
}

refreshStatus();
setInterval(refreshStatus, 10000);
