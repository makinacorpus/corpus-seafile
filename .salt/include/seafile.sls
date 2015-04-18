{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

include:
  - makina-projects.{{cfg.name}}.include.configs

{{cfg.name}}-pointer:
  file.symlink:
    - name: "{{data.pointer}}"
    - target: "{{data.cur_ver_dir}}"
    - onlyif: "test -e {{data.cur_ver_dir}}/setup-seafile.sh"
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

# for python module resoluton (abspath vs symlink)
{{cfg.name}}-pre4:
  file.symlink:
    - names:
      - "{{data.cur_ver_dir}}/seahub_settings.py"
      - "{{data.app_download_root}}/seahub_settings.py"
    - target: "{{data.cur_ver_dir}}/seahub/seahub_settings.py"
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-thirdpart:
  cmd.run:
    - cwd: "{{data.cur_ver_dir}}/seahub/thirdpart"
    - name: |
            set -e
            if [ ! -e ../salt.thirdpart ];then
              mkdir -pv  ../salt.thirdpart
            fi
            ls -1 | while read f;do
              sync=""
              if echo "${f}" | egrep -vq "gunicorn.*|.pth|.egg|.py$";then
                sync="x"
              fi
              if [ "x${sync}" != "x" ];then
                if [ -d "${f}" ];then
                  rsync -a --delete "${f}/" "../salt.thirdpart/${f}/"
                else
                  rsync -a --delete "${f}" "../salt.thirdpart/${f}"
                fi
              fi
            done
    - user: {{cfg.user}}
    - use_vt: true
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{% for i in ['logs', 'pids', 'seafile-data', 'seahub-data'] %}
{# survives & handle path upgrades #}
{{cfg.name}}-logdirnodir-{{i}}:
  file.absent:
    - name: "{{data.app_download_root}}/{{i}}"
    - onlyif: |
              set -e
              test -d "{{data.app_download_root}}/{{i}}"
              test ! -h "{{data.app_download_root}}/{{i}}"
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-logsdir-{{i}}:
  file.symlink:
    - names:
      {% if i in ['logs'] %}
      - /var/log/seafile-{{cfg.name}}
      {% endif%}
      - "{{data.app_download_root}}/{{i}}"
    - target: "{{cfg.data_root}}/{{i}}"
    - watch:
      - file: {{cfg.name}}-logdirnodir-{{i}}
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-logdir-{{i}}:
  file.directory:
    - name: "{{cfg.data_root}}/{{i}}"
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - mode: 750
    - watch:
      - file: {{cfg.name}}-logsdir-{{i}}
      - file: {{cfg.name}}-logdirnodir-{{i}}
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre
      - cmd: {{cfg.name}}-pre3
      - file: {{cfg.name}}-ccnet-key
{% endfor %}

{{cfg.name}}-pre2c:
  file.symlink:
    - name: "{{data.searoot}}"
    - target: "{{data.app_download_root}}"
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-pre3:
  cmd.run:
    - name: mv "{{data.cur_ver_dir}}/seahub/media/avatars" "{{cfg.data_root}}/seahub-data/avatars"
    - user: "{{cfg.user}}"
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre
    - onlyif: |
              set -e
              test -d "{{data.cur_ver_dir}}/seahub/media/avatars"
              test ! -e "{{cfg.data_root}}/seahub-data/avatars"
  file.absent:
    - name: "{{data.cur_ver_dir}}/seahub/media/avatars"
    - onlyif: |
              set -e
              test ! -h "{{data.cur_ver_dir}}/seahub/media/avatars"
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
      - cmd: {{cfg.name}}-pre3
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-pre3bis:
  file.symlink:
    - name: "{{data.cur_ver_dir}}/seahub/media/avatars"
    - target: "{{cfg.data_root}}/seahub-data/avatars"
    - watch:
      - cmd: {{cfg.name}}-pre3
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-pre5:
  cmd.run:
    - name: rsync -a "{{data.cur_ver_dir}}/seahub/media/avatars" "{{cfg.data_root}}/seafile-data/library-template/"
    - user: "{{cfg.user}}"
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
      - file: {{cfg.name}}-pre3bis
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre
    - onlyif: test ! -e "{{cfg.data_root}}/seafile-data/library-template/"

{{cfg.name}}-ccnet:
  file.directory:
    - name: "{{data.app_download_root}}/ccnet"
    - user: "{{cfg.user}}"
    - makedirs: true
    - group: "{{cfg.group}}"
    - mode: "750"
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-ccnet-key:
  file.symlink:
    - name: "{{data.app_download_root}}/ccnet/mykey.peer"
    - target: "{{cfg.data_root}}/mykey.peer"
    - watch:
      - file: {{cfg.name}}-ccnet
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre
  cmd.run:
    - name: |
            LD_LIBRARY_PATH="{{data.pointer}}/seafile/lib/:{{data.pointer}}/seafile/lib64" "{{data.pointer}}/seafile/bin/ccnet-init" -c ccnet.tmp -H {{data.domain}} -n foo
            cp ccnet.tmp/mykey.peer "{{cfg.data_root}}/mykey.peer"
            rm -rf ccnet.tmp
    - target: "{{cfg.data_root}}/seahub-data/avatars"
    - onlyif: |
              set -e
              test ! -e "{{cfg.data_root}}/mykey.peer"
              test -h ccnet/mykey.peer
    - cwd: "{{data.app_download_root}}"
    - user: {{cfg.user}}
    - use_vt: true
    - watch:
      - file: {{cfg.name}}-ccnet-key
      - mc_proxy: {{cfg.name}}-configs-before
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-service:
  # modified version that support status
  file.symlink:
    - name: /etc/init.d/seafile-daemons
    - target: {{data.searoot}}/seafile-server-latest/seafile-status-wrapper.sh
    - watch:
      - mc_proxy: {{cfg.name}}-configs-before
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-service-launch:
  service.running:
    - name: seafile-daemons
    - enable: True
    - watch:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-after
