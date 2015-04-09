{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}

{{cfg.name}}-download-proxy:
  mc_proxy.hook: []

{{cfg.name}}-pre:
  file.symlink:
    - name: "{{data.pointer}}"
    - target: "{{data.cur_ver_dir}}"
    - onlyif: "test -e {{data.cur_ver_dir}}/setup-seafile.sh"
    - watch:
      - mc_proxy: {{cfg.name}}-download-proxy

{{cfg.name}}-pre1:
  file.symlink:
    - name: "{{data.pointer}}/seafile-data"
    - target: "{{data.seafile_data}}"
    - onlyif: "test -e {{data.cur_ver_dir}}/setup-seafile.sh"
    - watch:
      - mc_proxy: {{cfg.name}}-download-proxy
      - file: {{cfg.name}}-pre

{{cfg.name}}-pre2:
  file.symlink:
    - name: "{{data.pointer}}/seahub-data"
    - target: "{{data.seahub_data}}"
    - onlyif: "test -e {{data.cur_ver_dir}}/setup-seafile.sh"
    - watch:
      - mc_proxy: {{cfg.name}}-download-proxy
      - file: {{cfg.name}}-pre

{{cfg.name}}-pre3:
  cmd.run:
    - name: mv "{{data.pointer}}/seahub/media/avatars" "{{data.seahub_data}}/avatars"
    - user: "{{cfg.user}}"
    - watch:
      - mc_proxy: {{cfg.name}}-download-proxy
      - file: {{cfg.name}}-pre
      - file: {{cfg.name}}-pre1
      - file: {{cfg.name}}-pre2
    - onlyif: test -d "{{data.pointer}}/seahub/media/avatars" && test ! -h "{{data.pointer}}/seahub/media/avatars"
  file.symlink:
    - name: "{{data.pointer}}/seahub/media/avatars"
    - target: "{{data.seahub_data}}/avatars"
    - watch:
      - mc_proxy: {{cfg.name}}-download-proxy
      - cmd: {{cfg.name}}-pre3
      - file: {{cfg.name}}-pre2
      - file: {{cfg.name}}-pre1

{% for template, tdata in {
    'seahub/seahub/dsm.py': {},
    'config.py': {
      'dest': '{0}/{1}'.format(
          data.pointer, 'seahub_settings.py')
    },
    'ccnet/seafile.ini': {},
    'ccnet/ccnet.conf': {},
    'conf/seafdav.conf': {},
    'seafile.conf': {
      'dest': '{0}/{1}'.format(
          data.seafile_data, 'seafile.conf')
    }
}.items() %}
{{cfg.name}}-{{template}}-conf:
  file.managed:
    - watch_in:
      - mc_proxy: {{cfg.name}}-config-proxy
    - watch:
      - mc_proxy: {{cfg.name}}-download-proxy
      - file: {{cfg.name}}-pre3
      - file: {{cfg.name}}-pre1
      - file: {{cfg.name}}-pre2
      - file: {{cfg.name}}-pre
    - defaults:
        project: "{{cfg.name}}"
        cfg: "{{cfg.name}}"
    - source: {{ tdata.get(
          'source',
          'salt://makina-projects/{0}/files/{1}'.format(
          cfg.name, template))}}
    - makedirs: true
    - name: {{ tdata.get(
      'dest',
      '{0}/{1}'.format(data.pointer, template))}}
    - user: {{tdata.get('user', cfg.user)}}
    - group: {{tdata.get('group', cfg.group)}}
    - mode: {{tdata.get('mode', 750)}}
    {% if  data.get('template', 'jinja') %}
    - template:  {{ data.get('template', 'jinja') }}
    {% endif %}
{% endfor %}

{{cfg.name}}-config-proxy:
  mc_proxy.hook: []

