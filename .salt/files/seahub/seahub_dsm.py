#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, division,  print_function
__docformat__ = 'restructuredtext en'

{%- set cfg = salt['mc_project.get_configuration'](cfg) %}
{%- set data = cfg.data %}
import sys
import os

[sys.path.append(i) for i in [
    '{{data.cur_ver_dir}}/seahub/salt.thirdpart',
    '{{data.cur_ver_dir}}/seafile/lib64/python2.6/site-packages',
    '{{data.cur_ver_dir}}/seafile/lib64/python2.7/site-packages'
]]
os.environ['CCNET_CONF_DIR'] = "{{data.searoot}}/ccnet"
os.environ['SEAFILE_CONF_DIR'] = "{{data.searoot}}/seafile-data"
os.environ['LD_LIBRARY_PATH'] = ":".join(
    [
        "{{data.cur_ver_dir}}/seafile/lib64",
        "{{data.cur_ver_dir}}/seafile/lib"
    ] + os.environ.get('LD_LIBRARY_PATH', '').split(':'))
from seahub_settings import *
from {{data.SEAFILE_DJANGO_SETTINGS_MODULE}} import *
from seahub_settings_2 import *
# vim:set et sts=4 ts=4 tw=80:
