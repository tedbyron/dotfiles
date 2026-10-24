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
user_pref("zen.haptic-feedback.enabled", false);

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
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.warnOnQuitShortcut", false);
user_pref("dom.gamepad.enabled", false);
user_pref("font.name.monospace.x-western", "Curlio");
user_pref("font.name.sans-serif.x-western", "Inter");
user_pref("font.name.serif.x-western", "Libre Baskerville");
user_pref("full-screen-api.macos-native-full-screen", false);
user_pref("full-screen-api.warning.timeout", 0);
user_pref("layout.css.visited_links_enabled", false);
user_pref("reader.parse-on-load.enabled", false);
