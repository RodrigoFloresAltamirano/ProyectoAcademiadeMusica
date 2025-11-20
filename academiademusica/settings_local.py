SECRET_KEY = 'django-insecure-^4by)28+n4c9&c(e#3=i)c4!l0vs@ow32v!@^95c23fgmnpcp9'

DATABASES = {
    'default': {
        'ENGINE': 'mssql',
        'NAME': 'Academia_Musica',#Database name
        'USER': 'admin',#(no se debe subir a github)
        'PASSWORD': 'DerEisendrache8',#(no se debe subir a github)
        'HOST': 'ROYPC\\SQLEXPRESSP1',#Server name#(no se debe subir a github)
        #'PORT': '',
        'OPTIONS': {
            'driver': 'ODBC Driver 17 for SQL Server',
            'Trusted_Connection': 'yes',
        },
    }
}