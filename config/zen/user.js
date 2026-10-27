// Copied into Zen's default profile by users/ted/modules/firefox.nix

// Apply Firefox themes (Zen ignores them by default)
user_pref("zen.theme.disable-lightweight", false);

// Load userChrome.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

user_pref("zen.watermark.enabled", false);
user_pref("zen.urlbar.replace-newtab", true);
user_pref("zen.urlbar.wait-to-clear", 0);
user_pref("zen.workspaces.open-new-tab-if-last-unpinned-tab-is-closed", true);
user_pref("zen.view.show-background-tab-toast", false);
user_pref("zen.view.compact.toolbar-flash-popup", false);
user_pref("zen.view.show-clear-tabs-button", false);
user_pref("zen.view.show-newtab-button-top", false);
user_pref("zen.haptic-feedback.enabled", false);
user_pref("zen.urlbar.behavior", "float");
user_pref("zen.view.compact.enable-at-startup", false);
user_pref("zen.tabs.show-newtab-vertical", false);
user_pref("zen.tabs.select-recently-used-on-close", false);
user_pref("zen.tabs.ctrl-tab.ignore-essential-tabs", true);
user_pref("zen.workspaces.continue-where-left-off", true);
user_pref("privacy.userContext.enabled", false);

// Better Find Bar mod (zen-mods-export.json)
user_pref("theme-better_find_bar-enable_custom_background", true);
user_pref("theme.better_find_bar.custom_background", "#282828");
user_pref("theme.better_find_bar.textbox_width", "300");
user_pref("theme.better_find_bar.hide_match_diacritics", "hide_immediately");
user_pref("theme.better_find_bar.hide_whole_words", "hide_immediately");
user_pref("theme.better_find_bar.instant_animations", true);

// Use system DNS, which the NextDNS app encrypts, instead of Zen's own DoH
user_pref("network.trr.mode", 5);

// From modules/nixos/firefox.nix, minus prefs Zen already sets or locks
// (telemetry, Normandy, search suggestions) and Linux-only ones

// Policies, as prefs
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);
user_pref("signon.rememberSignons", false);

user_pref("accessibility.typeaheadfind.flashBar", 0);
user_pref("breakpad.reportURL", "");
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.backspace_action", 0);
user_pref("browser.display.background_color.dark", "#282828");
user_pref("browser.newtabpage.activity-stream.feeds.system.topsites", false);
user_pref("browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts", false);
user_pref("browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned", "");
user_pref("browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines", "");
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.system.showSponsored", false);
user_pref("browser.newtabpage.pinned", "[]");
user_pref("browser.startup.homepage", "chrome://browser/content/blanktab.html");
user_pref("browser.theme.dark-private-windows", false);
user_pref("browser.toolbars.bookmarks.showOtherBookmarks", false);
user_pref("browser.toolbars.bookmarks.visibility", "always");
user_pref("browser.urlbar.showSearchSuggestionsFirst", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.warnOnQuitShortcut", false);
user_pref("dom.gamepad.enabled", false);
user_pref("font.name.monospace.x-western", "Curlio");
user_pref("font.name.sans-serif.x-western", "Inter");
user_pref("font.name.serif.x-western", "Libre Baskerville");
user_pref("full-screen-api.macos-native-full-screen", false);
user_pref("full-screen-api.warning.timeout", 0);
user_pref("layout.css.visited_links_enabled", false);
user_pref("layout.spellcheckDefault", 0);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("network.prefetch-next", false);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("reader.parse-on-load.enabled", false);
