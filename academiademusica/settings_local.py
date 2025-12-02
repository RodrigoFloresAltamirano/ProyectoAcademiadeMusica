# settings_local.py
from .settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',  # Usa SQLite para desarrollo
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

SECRET_KEY = 'clave_temporal_para_desarrollo'
DEBUG = True