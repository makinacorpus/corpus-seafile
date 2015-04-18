{% set cfg = opts.ms_project %}
{% macro set_env() %}
    - env:
      - DJANGO_SETTINGS_MODULE: "{{data.DJANGO_SETTINGS_MODULE}}"
{% endmacro %}

{% set data = cfg.data %}
{% for admins in data.get('admins', []) %}
{% for admin, adata in admins.items() %}
{% set f = data.app_root + '/salt_' + admin + '_password.sh' %}
superuser-{{cfg.name}}-{{admin}}:
  file.managed:
    - contents: |
        #!/usr/bin/env bash
        export DJANGO_SETTINGS_MODULE="{{data.DJANGO_SETTINGS_MODULE}}"
        export SEAFILE_USER="{{adata.mail}}"
        export SEAFILE_PASSWORD="{{adata.password}}"
        cd "{{data.app_root}}"
        cp -f "{{cfg.project_root}}/change_pw.py" change_pw.py
        . {{data.py_root}}/bin/activate
        python change_pw.py
    - template: jinja
    - mode: 700
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - name: "{{f}}"
  cmd.run:
    - name: {{f}}
    - cwd: {{data.app_root}}
    - user: {{cfg.user}}
    - watch:
      - file: superuser-{{cfg.name}}-{{admin}}
{%endfor %}
{%endfor %}
