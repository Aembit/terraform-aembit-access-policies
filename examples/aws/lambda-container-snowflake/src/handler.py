import snowflake.connector
import pandas as pd
import os

def execute_query(connection, query):
    cursor = connection.cursor()
    cursor.execute(query)
    result = cursor.fetchall()
    columns = [column[0] for column in cursor.description]
    df = pd.DataFrame(result, columns=columns)
    return df

def lambda_handler(event, context):
    # Retrieve the necessary Snowflake connection parameters from the environment
    account = os.environ["SNOWFLAKE_ACCOUNT"]
    username = os.environ["SNOWFLAKE_USERNAME"]
    host = os.environ["SNOWFLAKE_HOST"]
    warehouse = os.environ["SNOWFLAKE_WAREHOUSE"]
    database = os.environ["SNOWFLAKE_DATABASE"]
    schema = os.environ["SNOWFLAKE_SCHEMA"]
    query = os.environ["SNOWFLAKE_QUERY"]
    connection = None
    result = None

    try:
        # Connect to Snowflake
        print("Connecting to Snowflake")
        connection = snowflake.connector.connect(
            account=account,
            user=username,
            host=host,
            authenticator="oauth",
            token="this is not a valid token",
            warehouse=warehouse,
            database=database,
            schema=schema
        )
    except Exception as err:
        error_response = {
            "type": type(err).__name__,
            "message": str(err),
        }
        print("Connection error:", error_response)
        raise Exception(error_response)

    # Execute a sample query
    try:
        print("Querying Snowflake")
        result = execute_query(connection, query)
    except Exception as err: 
        error_response = {
            "type": type(err).__name__,
            "message": str(err),
        }
        print("Query error:", error_response)
        raise Exception(error_response)

    # Return the processed result
    print(result.to_dict())
    return result.to_dict()
