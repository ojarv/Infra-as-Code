### /srv/salt/winpro/init.sls

### Install apps

install:
  pkg.installed:
    - pkgs:
      - "firefox_x64"
      - "npp_x64"

install_NanaZip:
  cmd.run:
    - name: Add-AppxPackage -Path https://github.com/M2Team/NanaZip/releases/download/2.0.450/40174MouriNaruto.NanaZip_2.0.450.0_gnj4mf6z9tkrc.msixbundle
    - unless: "if (Get-AppxPackage | Where-Object { $_.PackageFamilyName -eq '40174MouriNaruto.NanaZip_gnj4mf6z9tkrc' }) { exit 0 } else { exit 1 }"
    - runas: Vagrant
    - shell: powershell


### Firefox Extensions

firefox_uBO:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\Extensions\Install
    - vname: "1"
    - vdata: https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi
    - vtype: REG_SZ

firefox_DarkReader:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\Extensions\Install
    - vname: "2"
    - vdata: https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi
    - vtype: REG_SZ


### Firefox settings

previous-session:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\Homepage
    - vname: StartPage
    - vdata: previous-session
    - vtype: REG_SZ

DisableTelemetry:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox
    - vname: DisableTelemetry
    - vdata: "1"
    - vtype: REG_DWORD

bookmark1_0:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\Bookmarks\1
    - vname: URL
    - vdata: https://terokarvinen.com/
    - vtype: REG_SZ

bookmark1_1:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\Bookmarks\1
    - vname: Title
    - vdata: TeroKarvinen.com
    - vtype: REG_SZ

bookmark1_2:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\Bookmarks\1
    - vname: Placement
    - vdata: toolbar
    - vtype: REG_SZ

PromptForDownloadLocation:
  reg.present:
    - name: HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox
    - vname: PromptForDownloadLocation
    - vdata: 1
    - vtype: REG_DWORD


### Windows settings

include:
  - winpro.jinja

### Idempotence not working, runs always
C:\tmp\Taskbar\SetTaskbar.ps1:
  cmd.run:
    - onlyif:
      - file.exists:
        - name: C:/tmp/Taskbar/notconfigured
    - runas: Vagrant
    - shell: powershell