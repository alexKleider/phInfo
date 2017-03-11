# File: local_settings.py
# Customized settings.
# These are largely to allow the book server to be run side by side with
# other content (specifically the Rachel content server.)

STATIC_URL = '/library/static/'
FORCE_SCRIPT_NAME = '/library'
LOGIN_REDIRECT_URL = FORCE_SCRIPT_NAME

DEBUG = True
TIME_ZONE = 'America/Los_Angeles'
