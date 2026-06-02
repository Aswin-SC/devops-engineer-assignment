const fs = require("fs");
const path = require("path");

const files = ["src/index.html", "src/app.js", "src/styles.css"];
for (const file of files) {
  const fullPath = path.join(__dirname, "..", file);
  if (!fs.existsSync(fullPath)) {
    throw new Error(`Missing required file: ${file}`);
  }
}

const app = fs.readFileSync(path.join(__dirname, "..", "src", "app.js"), "utf8");
if (!app.includes("/status")) {
  throw new Error("Frontend must call the backend status endpoint.");
}

console.log("frontend lint passed");
