from os import environ
SESSION_CONFIG_DEFAULTS = dict(real_world_currency_per_point=1, participation_fee=0)
SESSION_CONFIGS = [dict(name='MLAMonthly', num_demo_participants=None, app_sequence=['MLAMonthly']), dict(name='MLAMonthlyInfo', num_demo_participants=None, app_sequence=['MLAMonthlyInfo']), dict(name='MLAFiveYearly', num_demo_participants=None, app_sequence=['MLAFiveYearly']), dict(name='MLAFiveYearlyInfo', num_demo_participants=None, app_sequence=['MLAFiveYearlyInfo']), dict(name='Main_Experiment', num_demo_participants=None, app_sequence=['MLAMonthly', 'MLAMonthlyInfo', 'MLAFiveYearly', 'MLAFiveYearlyInfo'], info_treatment=True, frequency_treatment=True)]
LANGUAGE_CODE = 'en'
REAL_WORLD_CURRENCY_CODE = 'USD'
USE_POINTS = True
DEMO_PAGE_INTRO_HTML = ''
PARTICIPANT_FIELDS = []
SESSION_FIELDS = []
ROOMS = [dict(name='NoInfoPilot', display_name='NoInfoPilot'), dict(name='Experiment', display_name='investment_experiment'), dict(name='Room_1', display_name='Room_1'), dict(name='Room_2', display_name='Room_2'), dict(name='Room_3', display_name='Room_3'), dict(name='Room_4', display_name='Room_4')]

ADMIN_USERNAME = 'admin'
# for security, best to set admin password in an environment variable
ADMIN_PASSWORD = environ.get('OTREE_ADMIN_PASSWORD')

SECRET_KEY = 'blahblah'

# if an app is included in SESSION_CONFIGS, you don't need to list it here
INSTALLED_APPS = ['otree']


