import sys
import os
import pandas as pd
from sqlalchemy import create_engine, URL
from sqlalchemy.exc import SQLAlchemyError
from dotenv import load_dotenv

# database connection parameters
load_dotenv(dotenv_path=os.path.join(os.getcwd(), ".env"))
DEFAULT_SERVER = "YOUR_SERVER_NAME_HERE"
DEFAULT_DATABASE = "YOUR_DATABASE_NAME_HERE"

server = os.getenv("SERVER", DEFAULT_SERVER)
database = os.getenv("SOURCE_DB", DEFAULT_DATABASE)
connection_url = URL.create(
    drivername="mssql+pyodbc",
    username="",
    password="",
    host=server,
    database=database,
    query={"driver": "ODBC Driver 17 for SQL Server"},
)

# db connection
try:
    engine = create_engine(connection_url)
    with engine.connect() as conn:
        print(f"     Successfully connected to {connection_url.host}")

except SQLAlchemyError as e:
    print(f"    Connection failed for {connection_url.host}: {e}")
    sys.exit(1)

# excel writer loop
directory = (
    os.path.dirname(os.path.abspath(__file__))
    if "__file__" in locals()
    else os.getcwd()
)

output_excel = os.path.join(directory, f"{os.path.basename(os.getcwd())} Needles Data Mapping.xlsx")
sql_files = [f for f in os.listdir(directory) if f.endswith(".sql")]

try:
    with pd.ExcelWriter(output_excel, engine="openpyxl") as writer:

        for file in sql_files:
            sql_file_path = os.path.join(directory, file)

            with open(sql_file_path, "r", encoding="utf-8") as f:
                sql_content = f.read()

            df = pd.read_sql_query(sql_content, con=engine)
            sheet_name = os.path.splitext(file)[0][:31]     # Excel sheet name max length is 31
            sheet_name = "".join(c for c in sheet_name if c not in r"[]*?/\:")      # Simple sanitization for Excel sheet names 
            
            df.to_excel(writer, sheet_name=sheet_name, index=False)
            
            print(f"     {file} written to sheet: {sheet_name}")

    print(f"     Data mapping spreadsheet created: {output_excel}")
except Exception as e:
    print(f"    Failed during Excel writing process: {e}")