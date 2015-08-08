{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
include:
  - makina-projects.{{cfg.name}}.include.seafile

{{cfg.name}}-service-launch:
  service.running:
    - name: seafile-daemons
    - enable: True
    - watch:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-after


