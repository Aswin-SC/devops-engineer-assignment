const fs = require("fs");
const path = require("path");

const source = path.join(__dirname, "..", "src");
const target = path.join(__dirname, "..", "dist");
fs.rmSync(target, { recursive: true, force: true });
fs.mkdirSync(target, { recursive: true });

for (const file of fs.readdirSync(source)) {
  const content = fs.readFileSync(path.join(source, file));
  fs.writeFileSync(path.join(target, file), content);
}

console.log("frontend build complete");
