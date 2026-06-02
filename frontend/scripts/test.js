const fs = require("fs");
const path = require("path");

const html = fs.readFileSync(path.join(__dirname, "..", "src", "index.html"), "utf8");
for (const id of ["api-status", "db-status", "version"]) {
  if (!html.includes(`id="${id}"`)) {
    throw new Error(`Missing status element: ${id}`);
  }
}

console.log("frontend tests passed");
