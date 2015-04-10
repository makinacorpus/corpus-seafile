{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

include:
  - makina-projects.{{cfg.name}}.include.configs

{{cfg.name}}-pointer:
  file.symlink:
    - name: "{{data.pointer}}"
    - target: "{{data.cur_ver_dir}}"
    - onlyif: "test -e {{data.cur_ver_dir}}/setup-seafile.sh"
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
      - file: {{cfg.name}}-pointer
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-pre1:
  file.symlink:
    - name: "{{data.pointer}}/seafile-data"
    - target: "{{data.seafile_data}}"
    - watch:
      - file: {{cfg.name}}-pointer
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-thirdpart:
  cmd.run:
    - cwd: "{{data.cur_ver_dir}}/seahub/thirdpart"
    - name: |
            set -e
            set -x
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
      - file: {{cfg.name}}-pre1
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-pre2:
  file.symlink:
    - name: "{{data.pointer}}/seahub-data"
    - target: "{{data.seahub_data}}"
    - watch:
      - file: {{cfg.name}}-pre1
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-pre3:
  cmd.run:
    - name: mv "{{data.pointer}}/seahub/media/avatars" "{{data.seahub_data}}/avatars"
    - user: "{{cfg.user}}"
    - watch:
      - file: {{cfg.name}}-pre2
    - onlyif: |
              set -e
              test -d "{{data.pointer}}/seahub/media/avatars"
              test ! -e "{{data.seahub_data}}/avatars"
  file.absent:
    - name: "{{data.pointer}}/seahub/media/avatars"
    - watch:
      - cmd: {{cfg.name}}-pre3
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre

{{cfg.name}}-pre3bis:
  file.symlink:
    - name: "{{data.pointer}}/seahub/media/avatars"
    - target: "{{data.seahub_data}}/avatars"
    - watch:
      - cmd: {{cfg.name}}-pre3
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre
