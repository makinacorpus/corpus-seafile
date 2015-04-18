#!/usr/bin/env python
import os
import importlib
mod_ = os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'seahub_dsm')
from django.conf import settings
settings.configure()
importlib.import_module(mod_)
import ccnet
ccnet_dir = os.environ['CCNET_CONF_DIR']
rpc_client = ccnet.CcnetThreadedRpcClient(ccnet.ClientPool(ccnet_dir))
EMAIL = os.environ['SEAFILE_USER']
PASSWORD = os.environ['SEAFILE_PASSWORD']
_user = None
user = rpc_client.get_emailuser(EMAIL)
if not _user:
    _user = rpc_client.add_emailuser(EMAIL, PASSWORD, 1, 1)
user = rpc_client.get_emailuser(EMAIL)
if not _user:
    raise Exception('not created {0}'.format(user))
udata = user._dict
update_roles = False
change_password = rpc_client.validate_emailuser(EMAIL, PASSWORD) != 0
if not (udata['is_staff'] and udata['is_active']):
    update_roles = True
if change_password or update_roles:
    rmv = rpc_client.remove_emailuser(EMAIL)
    _user = rpc_client.add_emailuser(EMAIL, PASSWORD, 1, 1)
