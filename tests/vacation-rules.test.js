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

test("next bookable day skips all or part of the historic October blackout", () => {
  assert.equal(rules.nextBookableDay("2026-10-02"), "2026-10-02");
  assert.equal(rules.nextBookableDay("2026-10-03"), "2026-10-11");
  assert.equal(rules.nextBookableDay("2026-10-08"), "2026-10-11");
  assert.equal(rules.nextBookableDay("2026-10-11"), "2026-10-11");
});

test("relocation announcement starts 1 November in Kuala Lumpur time and remains after the move", () => {
  assert.equal(rules.businessDay(new Date("2026-10-31T15:59:59Z")), "2026-10-31");
  assert.equal(rules.businessDay(new Date("2026-10-31T16:00:00Z")), "2026-11-01");
  assert.equal(rules.shouldShowAnnouncement(new Date("2026-10-31T15:59:59Z"), false), false);
  assert.equal(rules.shouldShowAnnouncement(new Date("2026-10-31T16:00:00Z"), false), true);
  assert.equal(rules.shouldShowAnnouncement(new Date("2026-12-01T16:00:00Z"), false), true);
  assert.equal(rules.shouldShowAnnouncement(new Date("2026-12-01T16:00:00Z"), true), false);
});

test("last Johor Bahru service date remains eligible, December dates do not", () => {
  assert.equal(rules.LAST_JB_SERVICE_DAY, "2026-11-30");
  assert.equal(rules.isUnavailableDate("2026-11-29"), false);
  assert.equal(rules.isUnavailableDate("2026-11-30"), false);
  assert.equal(rules.isUnavailableDate("2026-12-01"), true);
  assert.equal(rules.isUnavailableDate("2027-01-01"), true);
  assert.equal(rules.isUnavailableDate(""), false);
  assert.equal(rules.isUnavailableDate("2026-10-05"), true);
  assert.equal(rules.nextBookableDay("2026-11-30"), "2026-11-30");
  assert.equal(rules.nextBookableDay("2026-12-01"), null);
});

test("page wires the relocation rule into calendar invalidation and final booking defense", () => {
  const html = fs.readFileSync(path.join(__dirname, "..", "index.html"), "utf8");
  assert.match(html, /!open \|\| day < open \|\| blackout \? " disabled"/);
  assert.match(html, /dEl\.value < firstOpenDay\(floor\) \|\| isUnavailableDate\(dEl\.value\)/);
  assert.match(html, /btn\.addEventListener\("click"[\s\S]*?e\.preventDefault\(\)/);
  assert.match(html, /sessionStorage\.setItem\("anacoo-relocation-2026-dismissed"/);
  assert.match(html, /id="vacationTitle"[^>]*data-zh=[^>]*data-ms=/);
  assert.match(html, /30 November 2026/);
  assert.match(html, /2026年11月30日/);
  assert.match(html, /isUnavailableDate\(d\)/);
  for(const language of ["en", "zh", "ms"]) {
    assert.match(html, new RegExp(`data-${language}="[^"]+"`));
  }
  assert.match(html, /role="dialog" aria-modal="true"/);
});
