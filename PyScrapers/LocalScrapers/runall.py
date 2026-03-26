import os
import subprocess
import time

# Define the paths
source_folder = r"C:\AST\GitHub\opnt\PyScrapers\LocalScrapers"
output_folder = r"C:\Users\atambe\PycharmProjects\ASTNewsConsol"
consolidated_output_file = os.path.join(output_folder, "outall.sql")


# Function to run all .py files except the runall.py
def run_python_scripts():
    # List all files in the source folder
    for file_name in os.listdir(source_folder):
        if file_name.endswith(".py") and file_name != "runall.py":
            script_path = os.path.join(source_folder, file_name)
            print(f"Running script: {file_name}")
            subprocess.run(["python", script_path], check=True)


# Function to consolidate .sql files into one
def consolidate_sql_files():
    with open(consolidated_output_file, 'w', encoding='utf-8') as out_file:
        for file_name in os.listdir(output_folder):
            if file_name.endswith(".sql"):
                sql_file_path = os.path.join(output_folder, file_name)
                print(f"Consolidating file: {file_name}")
                try:
                    with open(sql_file_path, 'r', encoding='utf-8') as in_file:
                        # Read and append the content of each .sql file
                        out_file.write(in_file.read())
                        out_file.write("\n")  # Add a newline between SQL contents
                except UnicodeDecodeError:
                    print(f"Could not read {file_name} due to encoding issues.")


# Function to check if the latest .sql file is older than 12 hours
def is_files_older_than_12_hours():
    latest_timestamp = 0
    for file_name in os.listdir(output_folder):
        if file_name.endswith(".sql"):
            sql_file_path = os.path.join(output_folder, file_name)
            file_timestamp = os.path.getmtime(sql_file_path)
            latest_timestamp = max(latest_timestamp, file_timestamp)

    current_timestamp = time.time()
    # 12 hours in seconds = 12 * 60 * 60
    if current_timestamp - latest_timestamp >= 12 * 60 * 60:
        return True
    return False


# Function to delete all .sql files in the output folder
def delete_sql_files():
    for file_name in os.listdir(output_folder):
        if file_name.endswith(".sql"):
            sql_file_path = os.path.join(output_folder, file_name)
            os.remove(sql_file_path)
            print(f"Deleted file: {file_name}")


def main():
    if is_files_older_than_12_hours():
        print("Output files are older than 12 hours, deleting and re-running scripts.")
        delete_sql_files()  # Delete old .sql files
        run_python_scripts()  # Re-run the .py scripts
    else:
        print("Output files are recent, skipping script execution.")

    consolidate_sql_files()  # Step 2: Consolidate the SQL files


if __name__ == "__main__":
    main()
