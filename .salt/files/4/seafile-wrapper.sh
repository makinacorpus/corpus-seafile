#!/usr/bin/env bash
### BEGIN INIT INFO
# Provides:          seafile-daemons
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts sd
### END INIT INFO

# 
{% set cfg = salt['mc_project.get_configuration'](cfg) %}
cd "{{cfg.data.cur_ver_dir}}"
su "{{cfg.user}}" -c "./seafile.sh ${@}"
exit ${?}
# vim:set et sts=4 ts=4 tw=80:
