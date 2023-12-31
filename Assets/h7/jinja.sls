### /srv/salt/winpro/jinja.sls
### Credits: https://github.com/saltstack/salt/issues/64258#issuecomment-1545384343

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

HideSearchBox:
  reg.present:
    - name: HKEY_USERS\{{ sid }}\SOFTWARE\Microsoft\Windows\CurrentVersion\Search
    - vname: SearchboxTaskbarMode
    - vdata: 0
    - vtype: REG_DWORD

TurnOffTaskView:
  reg.present:
    - name: HKEY_USERS\{{ sid }}\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    - vname: ShowTaskViewButton
    - vdata: 0
    - vtype: REG_DWORD

TurnOffWidgets:
  reg.present:
    - name: HKEY_USERS\{{ sid }}\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    - vname: TaskbarDa
    - vdata: 0
    - vtype: REG_DWORD

TurnOffChat:
  reg.present:
    - name: HKEY_USERS\{{ sid }}\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    - vname: TaskbarMn
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
