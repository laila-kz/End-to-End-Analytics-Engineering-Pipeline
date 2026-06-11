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
    cur.execute('show databases')
    dbs = [row[1] for row in cur.fetchall()]
    print('DATABASES:', sorted(dbs))
    cur.execute("select database_name from information_schema.databases where database_name ilike 'INTERMEDIATE'")
    print('INTERMEDIATE exists:', cur.fetchone())
finally:
    cur.close()
    conn.close()
