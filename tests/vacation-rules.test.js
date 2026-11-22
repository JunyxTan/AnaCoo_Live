const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const rules = require("../assets/vacation-rules.js");

test("old October holiday stays blocked but Singapore appointments stay available", () => {
  for(let d=3; d<=10; d++) assert.equal(rules.isUnavailableDate("2026-10-" + String(d).padStart(2,"0")), true);
  assert.equal(rules.SHOP_TIME_ZONE,"Asia/Singapore");
  assert.equal(rules.isUnavailableDate("2026-10-11"),false);
  assert.equal(rules.isUnavailableDate("2026-11-30"),false);
  assert.equal(rules.isUnavailableDate("2026-12-01"),false);
  assert.equal(rules.isUnavailableDate("2027-01-01"),false);
  assert.equal(rules.nextBookableDay("2026-10-08"),"2026-10-11");
  assert.equal(rules.nextBookableDay("2026-12-01"),"2026-12-01");
});

test("relocation announcement follows the Singapore time zone and dismissal", () => {
  assert.equal(rules.businessDay(new Date("2026-10-31T15:59:59Z")),"2026-10-31");
  assert.equal(rules.businessDay(new Date("2026-10-31T16:00:00Z")),"2026-11-01");
  assert.equal(rules.shouldShowAnnouncement(new Date("2026-11-23T01:00:00Z"),false),true);
  assert.equal(rules.shouldShowAnnouncement(new Date("2026-11-23T01:00:00Z"),true),false);
});

test("website updates address, number, Google Maps, dates and Singapore-only pricing", () => {
  const html=fs.readFileSync(path.join(__dirname,"..","index.html"),"utf8");
  assert.match(html,/Blk 536, Ang Mo Kio Avenue 10, Singapore 560536/);
  assert.match(html,/maps\.app\.goo\.gl\/PVJZiyb9aBDiPNxw7\?g_st=ic/);
  assert.match(html,/https:\/\/wa\.me\/6587857890/);
  assert.match(html,/var WA = "6587857890"/);
  assert.match(html,/isUnavailableDate\(d\)/);
  assert.match(html,/sessionStorage\.setItem\("anacoo-relocation-2026-dismissed"/);
  assert.match(html,/role="dialog" aria-modal="true"/);
  assert.doesNotMatch(html,/R&amp;F Princess Cove, Block A7-1, Johor Bahru/);
  assert.doesNotMatch(html,/60123608968|1\.4592273|1\.4590,103\.7679|LAST_JB_SERVICE_DAY/);
  assert.doesNotMatch(html,/>RM\d+/);
});
