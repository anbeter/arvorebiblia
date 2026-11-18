import os
from contextlib import contextmanager

import psycopg2
import psycopg2.extras
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))


def dsn() -> dict:
    return dict(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("DB_NAME", "arvorebiblia"),
        user=os.getenv("DB_USER", "arvorebiblia"),
        password=os.getenv("DB_PASSWORD", ""),
    )


@contextmanager
def cursor():
    conn = psycopg2.connect(**dsn(), cursor_factory=psycopg2.extras.RealDictCursor)
    try:
        with conn:
            with conn.cursor() as cur:
                yield cur
    finally:
        conn.close()
