{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}
{{cfg.name}}-download:
  archive.extracted:
    - source: "{{data.app_url}}"
    - source_hash: "{{data.app_url_hash}}"
    - name: "{{cfg.data_root}}/server_{{data.version}}"
    - archive_format: "{{data.app_url_archive_format}}"
    - tar_options: "{{data.app_url_tar_opts}}"
    - user: "{{cfg.user}}"
    - group: "{{cfg.group}}"
    - onlyif: '{{data.app_archive_test_exists}}'

{{cfg.name}}-pre:
  file.symlink:
    - name: "{{data.pointer}}"
    - target: "{{data.cur_ver_dir}}"
    - onlyif: "test -e {{data.cur_ver_dir}}/setup-seafile.sh"
    - watch:
      - archive: {{cfg.name}}-download

{{cfg.name}}-pre1:
  file.symlink:
    - name: "{{data.pointer}}/seafile-data"
    - target: "{{data.seafile_data}}"
    - onlyif: "test -e {{data.cur_ver_dir}}/setup-seafile.sh"
    - watch:
      - archive: {{cfg.name}}-download
      - file: {{cfg.name}}-pre

{{cfg.name}}-pre2:
  file.symlink:
    - name: "{{data.pointer}}/seahub-data"
    - target: "{{data.seahub_data}}"
    - onlyif: "test -e {{data.cur_ver_dir}}/setup-seafile.sh"
    - watch:
      - archive: {{cfg.name}}-download
      - file: {{cfg.name}}-pre

{{cfg.name}}-pre3:
  cmd.run:
    - name: mv "{{data.pointer}}/seahub/media/avatars" "{{data.seahub_data}}/avatars"
    - user: "{{cfg.user}}"
    - watch:
      - archive: {{cfg.name}}-download
      - file: {{cfg.name}}-pre
      - file: {{cfg.name}}-pre1
      - file: {{cfg.name}}-pre2
    - onlyif: test -d "{{data.pointer}}/seahub/media/avatars" && test ! -h "{{data.pointer}}/seahub/media/avatars"
  file.symlink:
    - name: "{{data.pointer}}/seahub/media/avatars"
    - target: "{{data.seahub_data}}/avatars"
    - watch:
      - archive: {{cfg.name}}-download
      - cmd: {{cfg.name}}-pre3
      - file: {{cfg.name}}-pre2
      - file: {{cfg.name}}-pre1

{% for template, tdata in {
    'config.py': {
      'dest': '{0}/{1}'.format(
          data.pointer, 'seahub_settings.py')
    },
    'ccnet/seafile.ini': {},
    'conf/seafdav.conf': {},
    'seafile.conf': {
      'dest': '{0}/{1}'.format(
          data.seafile_data, 'seafile.conf')
    }
}.items() %}
{{cfg.name}}-{{template}}-conf:
  file.managed:
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
