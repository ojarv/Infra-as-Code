# h6 - Miniproject
Tämän projektin ideana on provisioida Windows 11 -käyttöjärjestelmä määrittelemilläni asennuksilla ja asetuksilla käyttäen Salttia. Windows 11 -orjana toimii Vagrantilla tehty virtuaalikone [Vagrantfile_Windows](/Assets/h6/Vagrantfile_Windows). Tämän luonnin olen käsitellyt tehtävässä [h6](/h6.md).

Asennuksia:
* Firefox (pkg.installed)
* Notepad++ (pkg.installed)
* NanaZip (cmd.run, idempotenttina)

Määrityksiä:
* Firefoxin asetuksia ja laajennosten asennus
* Dark mode
* Show File Extensions
* Taskbar

## Package manager
Aluksi yritetään saada Firefoxin asennus [Saltin Windows package managerilla](https://docs.saltproject.io/en/latest/topics/windows/windows-package-manager.html) toimimaan.

Ohjeistuksen mukaan siis, lähdetään ensimmäiseksi määrittelemään tarvittavat repot masterille:

#### salt-run winrepo.update_git_repos
```console
vagrant@master:~$ sudo salt-run winrepo.update_git_repos
[WARNING ] Attempt to run a shell command with what may be an invalid shell! Check to ensure that the shell </usr/sbin/nologin> is valid for this user.
...
[ERROR   ] Command 'git' failed with return code: 128
[ERROR   ] stderr: fatal: could not create leading directories of '/srv/salt/win/repo/salt-winrepo_git': Permission denied
[ERROR   ] retcode: 128
[ERROR   ] Clone failed: fatal: could not create leading directories of '/srv/salt/win/repo/salt-winrepo_git': Permission denied
[WARNING ] Attempt to run a shell command with what may be an invalid shell! Check to ensure that the shell </usr/sbin/nologin> is valid for this user.
...
[ERROR   ] Command 'git' failed with return code: 128
[ERROR   ] stderr: fatal: could not create work tree dir '/srv/salt/win/repo-ng/salt-winrepo-ng_git': Permission denied
[ERROR   ] retcode: 128
[ERROR   ] Clone failed: fatal: could not create work tree dir '/srv/salt/win/repo-ng/salt-winrepo-ng_git': Permission denied
https://github.com/saltstack/salt-winrepo-ng.git:
    False
https://github.com/saltstack/salt-winrepo.git:
    False
```

Tässä törmäsin oikeuksien kanssa ongelmiin. Päädyin vianselvittelyn jälkeen manuaalisesti kopioimaan kyseisen repon kansioon ```/srv/salt/win/repo-ng/```

#### git clone https://github.com/saltstack/salt-winrepo-ng.git
```console
vagrant@master:/srv/salt/win/repo-ng$ sudo git clone https://github.com/saltstack/salt-winrepo-ng.git
Cloning into 'salt-winrepo-ng'...
remote: Enumerating objects: 11955, done.
remote: Counting objects: 100% (322/322), done.
remote: Compressing objects: 100% (162/162), done.
remote: Total 11955 (delta 167), reused 279 (delta 157), pack-reused 11633
Receiving objects: 100% (11955/11955), 3.14 MiB | 13.62 MiB/s, done.
Resolving deltas: 100% (6417/6417), done.
vagrant@master:/srv/salt/win/repo-ng$ ls
salt-winrepo-ng
```

Tämän jälkeen päivittelin Win11 orjan tietokannan.

```console
vagrant@master:/srv/salt/win/repo-ng$ sudo salt Win* pkg.refresh_db
Win11.mshome.net:
    ----------
    failed:
        0
    success:
        311
    total:
        311
```

Testataan toiminta.

### salt "W*" pkg.install 'firefox_x64'
```console
vagrant@master:/srv/salt/win/repo-ng$ sudo salt "W*" pkg.install 'firefox_x64'
Win11.mshome.net:
    ----------
    Mozilla Maintenance Service:
        ----------
        new:
            120.0
        old:
    firefox_x64:
        ----------
        new:
            120.0
        old:
```

Asennus onnistui ja orjan puolella näkyy asennus onnistuneesti.

## Salt State File
### SALT.STATES.PKG
Seuraavaksi luodaan Salt state file provisiointia varten ja lisätään aluksi muutaman ohjelman asennus. [SALT.STATES.PKG](https://docs.saltproject.io/en/latest/ref/states/all/salt.states.pkg.html)

#### ```/srv/salt/winpro/init.sls```
```yaml
install:
  pkg.installed:
    - pkgs:
      - "firefox_x64"
      - "npp_x64"
```

Testauksen jälkeen voin todeta, että tämä toimi oletetusti ja yllättävän nopeasti.

### SALT.STATES.REG
 Haluttujen asetusten konfigurointia. Käytän tässä apuna Saltin Windows rekisterin editointi ominaisuutta [SALT.STATES.REG](https://docs.saltproject.io/en/latest/ref/states/all/salt.states.reg.html).

* Firefoxin asettaminen oletusselaimeksi osottautui hankalaksi, tai ainakaan en löytänyt kovin järkevää ratkaisua tähän.

Tässä oli paljon määrittelyjä, mutta esimerkiksi määritellään kaksi laajennosta Firefoxiin, [uBlock Origin](https://github.com/gorhill/uBlock#ublock-origin) ja [Dark Reader](https://darkreader.org/). Tämä onnistuu rekisteriarvoihin lisäämällä ([Lähde](https://admx.help/?Category=Firefox)). Alla Saltin tila konfiguraatio.

### [init.sls](/Assets/h7/init.sls)
```yaml
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
```

## Provisiointi

Pohja: Windows ja Hyper-V asennettuna.

Hostilla samassa kansiossa:
* [Vagrantfile](/Assets/h7/Vagrantfile)
* [master_ip.ps1](/Assets/h7/master_ip.ps1)
* [init.sls](/Assets/h7/init.sls)
* [jinja.sls](/Assets/h7/jinja.sls)
* [./Taskbar](/Assets/h7/Taskbar/)
  * [SetTaskbar.ps1](/Assets//h7/Taskbar/SetTaskbar.ps1)
  * ja muut...
```console
$ vagrant up
$ vagrant ssh master
$ sudo salt-key -A
$ sudo salt '*' pkg.refresh_db
$ sudo salt '*' state.apply winpro
```

### [Vagrantfile](/Assets/h7/Vagrantfile)
Tässä luodaan ja provisioidaan Debian-pohjainen Herra ja Windows-pohjainen orja Saltilla. Tarvittattavat konfiguraatiot ja tiedostot kopioidaan tässä Herralle ja orjalle sekä asennetaan Salt.

```ruby
$master = <<-MASTER
sudo curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/debian/11/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg
echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/11/amd64/latest bullseye main" | sudo tee /etc/apt/sources.list.d/salt.list
sudo apt-get -qq update
sudo apt-get -qqy install salt-master
sudo systemctl restart salt-master
sudo git clone https://github.com/saltstack/salt-winrepo-ng.git /srv/salt/win/repo-ng
MASTER

Vagrant.configure("2") do |config|
	config.vm.synced_folder ".", "/vagrant", disabled: true
	config.vm.define "master", primary: true do |master|
		master.vm.box = "generic/debian12"
		master.vm.hostname = "master"
		master.vm.provision :shell, inline: $master
		master.vm.provider "hyperv" do |h|
			h.linked_clone = true
			h.cpus = 6
			h.maxmemory = 1536
			h.memory = 512
			h.vmname = "master"
		end
	
		master.vm.provision "file",
			source: "./init.sls",
			destination: "/tmp/sls/init.sls",
			run: "always"

		master.vm.provision "file",
			source: "./jinja.sls",
			destination: "/tmp/sls/jinja.sls",
			run: "always"

		master.vm.provision "shell",
			inline: "sudo mkdir -p /srv/salt/winpro && sudo cp -R /tmp/sls/. /srv/salt/winpro/",
			run: "always"
			
		master.trigger.after :up do |t|
			t.run = {inline: './master_ip.ps1'}
			t.only_on = "master"
		end
	end


	config.vm.define "win11", primary: true do |win11|
		win11.vm.box = "gusztavvargadr/windows-11"
		win11.vm.hostname = "Win11"
		win11.vm.provider "hyperv" do |h|
			h.linked_clone = true
			h.cpus = 6
			h.maxmemory = 8096
			h.memory = 2048
			h.vmname = "Win11"
		end
		
		win11.vm.provision "file",
			source: "./minion",
			destination: "C:/ProgramData/Salt Project/Salt/conf/minion",
			run: "always"
			
		win11.vm.provision "shell",
			inline: 'Invoke-WebRequest -Uri "https://repo.saltproject.io/windows/Salt-Minion-Latest-Py3-AMD64-Setup.exe" -OutFile "C:/tmp/setup.exe"; Start-Process C:/tmp/setup.exe /S; slmgr.vbs /ato',
			run: "once"

		win11.vm.provision "file",
			source: "./Taskbar",
			destination: "C:/tmp",
			run: "once"
	end
end
```

### [master_ip.ps1](/Assets/h7/master_ip.ps1)
Tämä liittyy purkkafiksiini sille, että Vagrant ei tue kovin hyvin vielä verkkojen määrittelyä Hyper-V:n kanssa. Esitelty ensimmäisen kerran tehtävässä [h2](/h2.md). Eli lyhyesti, luo Saltin ```minion``` -konfiguraatio tiedoston masterin IP osoitteella aina ```$ Vagrant up``` -komennon yhteydessä, joka samalla kopioidaan Vagrantin konfiguraatiossa orjille.

```powershell
$IP = Get-VMNetworkAdapter -VMName master | Select -ExpandProperty IPAddresses
Set-Content -Path ./minion -Value "master: ${IP}"
```

### [init.sls](/Assets/h7/init.sls)
Tässä on Salt-tilan ```winpro``` ensimmäinen tiedosto, tässä asennetaan Windows-orjalle Firefox, Notepad++ sekä NanaZip. Näiden lisäksi Firefoxille asetetaan muutamat asetukset ja asennetaan kaksi laajennosta uBlockOrigin ja Dark Reader. Lopuksi viitataan Windowsin asetuksia määrittelevään Saltin state tiedostoon (SLS) sekä tehtäväpalkin asetteluskriptiin.

```yaml
### /srv/salt/winpro/init.sls

### Install apps // Firefox, Notepad++ & NanaZip

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
```

### [jinja.sls](/Assets/h7/jinja.sls)
Tässä määritellään muutama rekisteriarvo käyttäen hyväksi jinjaa, [pohjan lähde](https://github.com/saltstack/salt/issues/64258#issuecomment-1545384343). Tämä siksi, koska halutaan asettaa nämä arvot kirjautuneen käyttäjän ```Vagrant``` HKEY_CURRENT_USER alle, jotta tulee voimaan.
* Tumma teema päälle
* Säädetään tehtäväpalkki vasempaan reunaan
* Laitetaan tunnettujen tiedostotyyppien päätteet näkymään

```jinja
### /srv/salt/winpro/jinja.sls

{% for user in salt['user.list_users']() %}
  {% if user not in ("DefaultAccount", "Guest", "WDAGUtilityAccount") %}
    {% set sid = salt['user.getUserSid'](user) %}
    {% if sid in salt['reg.list_keys']("HKEY_USERS") %}
DarkMode1:
  reg.present:
    - name: HKEY_USERS\{{ sid }}\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize
    - vname: SystemUsesLightTheme
    - vtype: REG_DWORD
    - vdata: 0

DarkMode2:
  reg.present:
    - name: HKEY_USERS\{{ sid }}\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize
    - vname: AppsUseLightTheme
    - vtype: REG_DWORD
    - vdata: 0

TaskbarAlignmentLeft:
  reg.present:
    - name: HKEY_USERS\{{ sid }}\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    - vname: TaskbarAl
    - vdata: 0
    - vtype: REG_DWORD

ShowFileExtensions:
  reg.present:
    - name: HKEY_USERS\{{ sid }}\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    - vname: HideFileExt
    - vdata: 0
    - vtype: REG_DWORD
    {% endif %}
  {% endif %}
{% endfor %}
```

### [/Taskbar](/Assets/h7/Taskbar/)
Tämä kansio sisältää skriptin työkalupalkin pikakuvakkeiden asettamiseen, ei ole hirveän kaunis ratkaisu, mutta toimii. Eli työkalupalkiin kiinnitetään Firefox, Notepad++ ja NanaZip. [init.sls](/Assets/h7/init.sls) laukaisee tämän viimeisenä, mutta jostain syystä en saanut sitä idempotentiksi, eli tämä ajetaan aina ```winpro``` -tilan ajossa. Ei vaikuta muuten kuin, että jos käyttäjä kiinnittää muita sovelluksia työkalupalkkiin, niin ne häviää tämän ajon jälkeen.

#### [/Taskbar/SetTaskbar.ps1](/Assets/h7/Taskbar/SetTaskbar.ps1)
```powershell
# Remove existing shortcuts
Remove-Item -Path "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" -Force -Recurse

# Copy new shortcuts
Copy-Item -Path "C:\tmp\Taskbar\Shorcuts\*" -Destination "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\" -Force

# Import registry settings
reg import "C:\tmp\Taskbar\Taskbar.reg"

# Restart explorer
Stop-Process -Name explorer -Force
Start-Process explorer

# Remove checkfile
Remove-Item -Path C:\tmp\Taskbar\notconfigured
```

### Kuvitus lähtötilanteesta
![Alku](/Assets/h7/alku.png)

### Kuvitus lopputilanteesta
![Loppu](/Assets/h7/loppu.png)

## Tehtävänanto

https://terokarvinen.com/2023/configuration-management-2023-autumn/