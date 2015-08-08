{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

{{cfg.name}}-configs-before:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-configs-pre:
  mc_proxy.hook: []

{% for config, tdata in data.configs.items() %}
{% set target = tdata.get('target', '{0}/{1}'.format(data.app_root, config)) %}
{% if target not in data.pre_5_configs %}
{{cfg.name}}-{{config}}-conf:
  file.managed:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch:
      - mc_proxy: {{cfg.name}}-configs-pre
    - defaults:
        project: "{{cfg.name}}"
        cfg: "{{cfg.name}}"
    - source: {{ tdata.get(
          'source',
          'salt://makina-projects/{0}/files/{1}'.format(
           cfg.name, config))}}
    - makedirs: {{tdata.get('makedirs', True)}}
    - name: "{{target}}"
    - user: {{tdata.get('user', cfg.user)}}
    - group: {{tdata.get('group', cfg.group)}}
    - mode: {{tdata.get('mode', 750)}}
    {% if  data.get('template', 'jinja') %}
    - template:  {{ data.get('template', 'jinja') }}
    {% endif %}
{% endif %}
{% endfor %}

{% if data.version >= "5" %}
{{cfg.name}}-pre-rm-4:
  file.absent:
    - names:
      {% for i in data.pre_5_configs %}
      - "{{i}}"
      {% endfor %}
    - watch:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-after
{% endif %}

{{cfg.name}}-configs-post:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-after

{{cfg.name}}-configs-after:
  mc_proxy.hook: []
