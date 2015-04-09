{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}

include:
  - makina-projects.{{cfg.name}}.task_layout

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
    - watch_in:
      - mc_proxy: {{cfg.name}}-download-proxy
