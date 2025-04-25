{ pkgs }:
{
  enable = true;

  # https://mozilla.github.io/policy-templates
  policies = {
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    DisablePocket = true;
    DisableProfileImport = true;
    DisableProfileRefresh = true;
    DisableTelemetry = true;
    DontCheckDefaultBrowser = true;
    NewTabPage = false;
    NoDefaultBookmarks = true;
    PasswordManagerEnabled = false;
    StartDownloadsInTempDirectory = true;
    UserMessaging = {
      ExtensionRecommendations = false;
      SkipOnboarding = true;
    };
  };

  preferences = {
    "accessibility.typeaheadfind.flashBar" = 0;
    "app.normandy.api_url" = "";
    "app.normandy.enabled" = false;
    "beacon.enabled" = false;
    "breakpad.reportURL" = "";
    "browser.aboutConfig.showWarning" = false;
    "browser.backspace_action" = 0;
    "browser.compactmode.show" = true;
    "browser.display.background_color.dark" = "#282828";
    "browser.newtabpage.activity-stream.feeds.system.topsites" = false;
    "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
    "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";
    "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.system.showSponsored" = false;
    "browser.newtabpage.pinned" = "[]";
    "browser.search.suggest.enabled" = false;
    "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
    "browser.tabs.crashReporting.sendReport" = false;
    "browser.tabs.tabmanager.enabled" = false;
    "browser.toolbars.bookmarks.showOtherBookmarks" = false;
    "browser.toolbars.bookmarks.visibility" = "always";
    "browser.urlbar.suggest.recentsearches" = false;
    "browser.urlbar.trimURLs" = false;
    "browser.warnOnQuitShortcut" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "dom.gamepad.enabled" = false;
    "extensions.activeThemeID" = "{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}";
    "extensions.htmlaboutaddons.recommendations.enabled" = false;
    "extensions.pocket.enabled" = false;
    "font.name.monospace.x-western" = "Curlio";
    "font.name.sans-serif.x-western" = "Inter";
    "font.name.serif.x-western" = "Libre Baskerville";
    "full-screen-api.warning.timeout" = 0;
    "gfx.x11-egl.force-enabled" = true;
    "layout.css.visited_links_enabled" = false;
    "media.hardware-video-decoding.force-enabled" = true;
    "reader.parse-on-load.enabled" = false;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.server" = "";
    "toolkit.telemetry.unified" = false;
  };

  wrapperConfig = {
    pipewireSupport = true;
  };
}
