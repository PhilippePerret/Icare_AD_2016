# encoding: UTF-8
raise_unless_admin

OFFLINE || page.add_javascript(PATH_MODULE_JS_SNIPPETS)
Admin.require_module 'mailing'
