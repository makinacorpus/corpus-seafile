{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
include:
  - makina-projects.{{cfg.name}}.include.configs
  - makina-projects.{{cfg.name}}.include.seafile
