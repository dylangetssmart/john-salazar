import re

def remove_comments(sql_content):
    """Remove SQL comments from the content."""
    # Remove block comments (/* ... */)
    sql_content = re.sub(r'/\*.*?\*/', '', sql_content, flags=re.DOTALL)
    # Remove inline comments (-- ...)
    sql_content = re.sub(r'--.*', '', sql_content)
    return sql_content

def extract_tables(sql_content):
    # Remove comments from the SQL content
    sql_content = remove_comments(sql_content)

    source_tables = set()
    target_tables = set()

    # Regex patterns
    insert_pattern = re.compile(r"INSERT INTO\s+([^\s(]+)", re.IGNORECASE)
    from_pattern = re.compile(r"FROM\s+([^\s(]+)", re.IGNORECASE)
    update_pattern = re.compile(r"UPDATE\s+([^\s]+)", re.IGNORECASE)
    merge_pattern = re.compile(r"MERGE INTO\s+([^\s]+)", re.IGNORECASE)

    # Extract targets
    target_tables.update(insert_pattern.findall(sql_content))
    target_tables.update(merge_pattern.findall(sql_content))
    target_tables.update(update_pattern.findall(sql_content))

    # Extract sources
    source_tables.update(from_pattern.findall(sql_content))

    return list(source_tables), list(target_tables)