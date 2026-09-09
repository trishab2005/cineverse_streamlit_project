import mysql.connector
import pandas as pd

DB_CONFIG = {
    "host": "localhost",
    "user": "scott",
    "password": "tiger",
    "database": "cineverse"
}

def get_connection():
    return mysql.connector.connect(**DB_CONFIG)

def query_df(sql, params=None):
    conn = get_connection()
    try:
        return pd.read_sql(sql, conn, params=params)
    finally:
        conn.close()

def execute(sql, params=None):
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute(sql, params or ())
        conn.commit()
        return cur.rowcount
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()

def call_procedure(name, args):
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.callproc(name, args)
        rows=[]
        cols=[]
        for result in cur.stored_results():
            rows = result.fetchall()
            cols = result.column_names
        return pd.DataFrame(rows, columns=cols)
    finally:
        cur.close()
        conn.close()
