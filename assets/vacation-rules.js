(function(root, factory){
  var rules = factory();
  if(typeof module === "object" && module.exports) module.exports = rules;
  if(root) root.AnacooVacationRules = rules;
})(typeof window !== "undefined" ? window : globalThis, function(){
  "use strict";

  var SHOP_TIME_ZONE = "Asia/Singapore";
  var BLACKOUT_START = "2026-10-03";
  var BLACKOUT_END = "2026-10-10";
  var REOPEN_DAY = "2026-10-11";
  var RELOCATION_ANNOUNCEMENT_START = "2026-11-01";

  function isBlackoutDate(day){
    return typeof day === "string" && day >= BLACKOUT_START && day <= BLACKOUT_END;
  }

  // Only the historic October closure is blocked; Singapore requests remain open.
  function isUnavailableDate(day){
    return isBlackoutDate(day);
  }

  function addDays(day, amount){
    var parts = day.split("-");
    var moved = new Date(Date.UTC(+parts[0], +parts[1] - 1, +parts[2] + amount));
    return moved.getUTCFullYear() + "-" + String(moved.getUTCMonth() + 1).padStart(2, "0") + "-" + String(moved.getUTCDate()).padStart(2, "0");
  }

  function nextBookableDay(day){
    while(isBlackoutDate(day)) day = addDays(day, 1);
    return day;
  }

  function businessDay(date){
    var parts = {};
    new Intl.DateTimeFormat("en-CA", {
      timeZone:SHOP_TIME_ZONE, year:"numeric", month:"2-digit", day:"2-digit"
    }).formatToParts(date).forEach(function(part){ parts[part.type] = part.value; });
    return parts.year + "-" + parts.month + "-" + parts.day;
  }

  function shouldShowAnnouncement(date, dismissed){
    // Keep the relocation notice available after the JB location closes.
    return !dismissed && businessDay(date) >= RELOCATION_ANNOUNCEMENT_START;
  }

  return Object.freeze({
    SHOP_TIME_ZONE:SHOP_TIME_ZONE,
    BLACKOUT_START:BLACKOUT_START,
    BLACKOUT_END:BLACKOUT_END,
    REOPEN_DAY:REOPEN_DAY,
    RELOCATION_ANNOUNCEMENT_START:RELOCATION_ANNOUNCEMENT_START,
    isUnavailableDate:isUnavailableDate,
    isBlackoutDate:isBlackoutDate,
    addDays:addDays,
    nextBookableDay:nextBookableDay,
    businessDay:businessDay,
    shouldShowAnnouncement:shouldShowAnnouncement
  });
});
