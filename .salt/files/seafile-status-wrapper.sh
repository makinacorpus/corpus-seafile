#!/usr/bin/env bash
{% set cfg = salt['mc_project.get_configuration'](cfg) %}
cd "{{cfg.data.cur_ver_dir}}"
su "{{cfg.user}}" -c "./seafile-status.sh ${@}"
exit ${?}
# vim:set et sts=4 ts=4 tw=80:
