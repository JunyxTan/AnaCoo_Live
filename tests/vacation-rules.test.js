const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const rules = require("../assets/vacation-rules.js");

test("every holiday date is blocked and adjacent dates remain eligible", () => {
  for(let day = 3; day <= 10; day++) {
    assert.equal(rules.isBlackoutDate(`2026-10-${String(day).padStart(2, "0")}`), true);
  }
  assert.equal(rules.isBlackoutDate("2026-10-02"), false);
  assert.equal(rules.isBlackoutDate("2026-10-11"), false);
  assert.equal(rules.isBlackoutDate(""), false);
});

test("next bookable day skips all or part of the blackout", () => {
  assert.equal(rules.nextBookableDay("2026-10-02"), "2026-10-02");
  assert.equal(rules.nextBookableDay("2026-10-03"), "2026-10-11");
  assert.equal(rules.nextBookableDay("2026-10-08"), "2026-10-11");
  assert.equal(rules.nextBookableDay("2026-10-11"), "2026-10-11");
});

test("announcement cutoff follows Kuala Lumpur time with an injectable date", () => {
  assert.equal(rules.businessDay(new Date("2026-10-10T15:59:59Z")), "2026-10-10");
  assert.equal(rules.businessDay(new Date("2026-10-10T16:00:00Z")), "2026-10-11");
  assert.equal(rules.shouldShowAnnouncement(new Date("2026-10-10T15:59:59Z"), false), true);
  assert.equal(rules.shouldShowAnnouncement(new Date("2026-10-10T16:00:00Z"), false), false);
  assert.equal(rules.shouldShowAnnouncement(new Date("2026-10-01T00:00:00Z"), true), false);
});

test("page wires the shared rule into calendar invalidation and final booking defense", () => {
  const html = fs.readFileSync(path.join(__dirname, "..", "index.html"), "utf8");
  assert.match(html, /day < open \|\| blackout \? " disabled"/);
  assert.match(html, /dEl\.value < firstOpenDay\(floor\) \|\| isVacationBlackout\(dEl\.value\)/);
  assert.match(html, /btn\.addEventListener\("click"[\s\S]*?e\.preventDefault\(\)/);
  assert.match(html, /sessionStorage\.setItem\("anacoo-vacation-2026-dismissed"/);
  for(const language of ["en", "zh", "ms"]) {
    assert.match(html, new RegExp(`data-${language}="[^"]+"`));
  }
  assert.match(html, /role="dialog" aria-modal="true"/);
});
