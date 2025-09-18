import os
import logging
from generate_runlist import generate_runlist

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# File Handler (logs everything INFO and above)
logs_dir = "_logs"
if not os.path.exists(logs_dir):
    os.makedirs(logs_dir)
    
file_handler = logging.FileHandler(os.path.join(logs_dir, "generate_runlist.log"))
file_handler.setLevel(logging.INFO)
file_formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(filename)s - %(funcName)s - %(lineno)d - %(message)s")
file_handler.setFormatter(file_formatter)

# Console Handler (only ERROR and above)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.ERROR)
console_formatter = logging.Formatter("%(levelname)s - %(filename)s - %(funcName)s - %(lineno)d - %(message)s")
console_handler.setFormatter(console_formatter)

# Attach handlers
logger.addHandler(file_handler)
logger.addHandler(console_handler)

def handle_generate_runlist(sql_dir):
    """
    Generate a _runlist.txt file in every directory that contains .sql files.

    Args:
        sql_dir (str): Path to the 'sql' directory.
    """
    for dirpath, _, filenames in os.walk(sql_dir):
        # Skip directories that start with an underscore
        if any(part.startswith("_") for part in dirpath.split(os.sep)):
            continue

        # Filter out .sql files
        sql_files = [f for f in filenames if f.lower().endswith(".sql")]

        if sql_files:
            try:
                generate_runlist(dirpath)  # writes _runlist.txt in the same directory
                logger.info(f"Generated _runlist.txt in {dirpath}")
            except Exception as e:
                logger.error(f"Error generating runlist in {dirpath}: {e}")

if __name__ == "__main__":
    # Define the root directories for SQL files
    sql_dirs = [
        r'litify\conversion',  # Path to the Litify conversion directory
        r'needles\conversion'  # Path to the Needles conversion directory
    ]

    # Iterate over each directory and generate README.md files
    for sql_dir in sql_dirs:
        if os.path.exists(sql_dir):
            logger.info(f"Processing directory: {sql_dir}")
            handle_generate_runlist(sql_dir)
        else:
            logger.warning(f"Directory does not exist: {sql_dir}")
