import pyodbc

SERVER = "localhost,1434"
DATABASE = "CatalogoDB"
USERNAME = "sa"
PASSWORD = "GuachaloWeb2026!"
DRIVER = "{ODBC Driver 18 for SQL Server}"

CONNECTION_STRING = (
    f"DRIVER={DRIVER};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    f"UID={USERNAME};"
    f"PWD={PASSWORD};"
    "TrustServerCertificate=yes;"
)

def get_db_connection():
    conn = pyodbc.connect(CONNECTION_STRING)
    try:
        yield conn
    finally:
        conn.close()