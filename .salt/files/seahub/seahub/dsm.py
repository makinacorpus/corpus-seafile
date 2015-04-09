#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, division,  print_function
__docformat__ = 'restructuredtext en'

{%- set cfg = salt['mc_project.get_configuration'](cfg) %}
{%- set data = cfg.data %}
import sys

sys.path.append(
    '{{data.cur_ver_dir}}/seafile/lib64/python2.6/site-packages',
)

from {{data.SEAFILE_DJANGO_SETTINGS_MODULE}} import *
# vim:set et sts=4 ts=4 tw=80:
