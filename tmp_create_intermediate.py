import snowflake.connector
import yaml
from pathlib import Path

profile = yaml.safe_load(Path(r'C:\Users\kheza\.dbt\profiles.yml').read_text())['first_project']['outputs']['dev']
conn = snowflake.connector.connect(
    user=profile['user'],
    password=profile['password'],
    account=profile['account'],
    warehouse=profile['warehouse'],
    role=profile['role'],
    database=profile['database'],
    schema=profile['schema'],
)
cur = conn.cursor()
try:
    cur.execute('create database if not exists INTERMEDIATE')
    cur.execute('create schema if not exists INTERMEDIATE.TAXI')
    print('Created or confirmed INTERMEDIATE database and TAXI schema')
finally:
    cur.close()
    conn.close()
