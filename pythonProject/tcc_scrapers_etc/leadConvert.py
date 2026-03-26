import pandas as pd
import re
import PyPDF2
import os
import warnings

# Suppress PyPDF2 warnings
warnings.filterwarnings("ignore", category=PyPDF2.errors.PdfReadWarning)

# File path for the PDF file containing the OCR data
file_path = "C:/AST/Antino/leads.pdf"

# Get the directory of the input PDF
output_dir = os.path.dirname(file_path)


# Function to extract text from PDF
def extract_text_from_pdf(file_path):
    try:
        with open(file_path, "rb") as file:
            reader = PyPDF2.PdfReader(file, strict=False)
            text = ""
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
            print(f"Successfully extracted text from PDF: {file_path}")
            return text
    except FileNotFoundError:
        print(f"Error: PDF file not found at {file_path}. Please check the path and try again.")
        exit(1)
    except Exception as e:
        print(f"Error extracting text from PDF: {e}")
        exit(1)


# Read the text from the PDF
text = extract_text_from_pdf(file_path)


# Function to clean text (remove unwanted headers, footers, and OCR artifacts)
def clean_text(text):
    lines = text.splitlines()
    cleaned_lines = []
    for line in lines:
        line = line.strip()
        # Skip headers, footers, and irrelevant lines
        if line in ["TIECON", "2025", "TIECON 2025", "Antino", "Lead Retrieval Results:",
                    "Powered by Eheod.gop.com", "Lhe, Virtual Hybrid Event Technology"]:
            continue
        if line:
            cleaned_lines.append(line)
    return "\n".join(cleaned_lines)


# Clean the input text
cleaned_text = clean_text(text)

# Save cleaned text to a file for debugging
text_output_path = os.path.join(output_dir, "extracted_text.txt")
with open(text_output_path, "w", encoding="utf-8") as f:
    f.write(cleaned_text)
print(f"Cleaned text saved to: {text_output_path}")

# Print first 2000 characters of cleaned text for debugging
print("\nFirst 2000 characters of cleaned text:")
print(cleaned_text[:2000])
print("\nEnd of cleaned text preview\n")

# Define regex pattern for email validation
email_pattern = r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"

# Initialize list to store records
records = []
current_record = {}
debug_records = []

# Split text into lines and process each line
lines = cleaned_text.splitlines()
for line in lines:
    line = line.strip()
    if not line:
        continue
    # Check if the line is a name (no colon, not a timestamp)
    if ":" not in line and not re.match(r"(April|May)\s+\d{1,2},\s+2025", line):
        if current_record:
            # Save the previous record if it has at least a Name and Email
            if current_record.get("Name") and current_record.get("Email"):
                records.append(current_record)
                debug_records.append(str(current_record))
        # Start a new record
        current_record = {
            "Name": line,
            "Organization": "",
            "Title": "",
            "Email": "",
            "Website": "",
            "LinkedIn": ""
        }
    else:
        # Handle labeled fields
        if line.startswith("Organization:"):
            current_record["Organization"] = line.replace("Organization: ", "").strip()
        elif line.startswith("Title:"):
            current_record["Title"] = line.replace("Title: ", "").strip()
        elif line.startswith("Email:"):
            email = line.replace("Email: ", "").strip()
            if re.match(email_pattern, email):
                current_record["Email"] = email
        elif line.startswith("Website:"):
            current_record["Website"] = line.replace("Website: ", "").strip()
        elif line.startswith("Linkedln:") or line.startswith("LinkedIn:"):
            current_record["LinkedIn"] = line.replace("Linkedln: ", "").replace("LinkedIn: ", "").strip()

# Append the last record if it has at least a Name and Email
if current_record.get("Name") and current_record.get("Email"):
    records.append(current_record)
    debug_records.append(str(current_record))

# Save parsed records to a debug file
debug_output_path = os.path.join(output_dir, "parsed_records.txt")
with open(debug_output_path, "w", encoding="utf-8") as f:
    for record in debug_records:
        f.write(f"{record}\n\n")
print(f"Parsed records saved to: {debug_output_path}")

# Create DataFrame
columns = ["Name", "Organization", "Title", "Email", "Website", "LinkedIn"]
df = pd.DataFrame(records, columns=columns)


# Clean and standardize data
def clean_dataframe(df):
    # Standardize Name (title case, handle missing values)
    df["Name"] = df["Name"].fillna("").str.title()

    # Replace "N/A" or missing organization with blank
    df["Organization"] = df["Organization"].fillna("").replace("N/A", "").str.strip()

    # Clean Title (remove extra spaces, standardize case, handle missing values)
    df["Title"] = df["Title"].fillna("").str.strip().str.title()

    # Clean Email (lowercase, handle missing values)
    df["Email"] = df["Email"].fillna("").str.lower().str.strip()

    # Clean other fields (handle missing values)
    for col in ["Website", "LinkedIn"]:
        df[col] = df[col].fillna("").str.strip()

    # Fix common OCR errors
    df["Title"] = df["Title"].replace("Maneging", "Managing")
    df["Title"] = df["Title"].replace("Senio Manager R&D", "Senior Manager R&D")
    df["Title"] = df["Title"].replace("Coo & Co-Founder", "COO & Co-Founder")
    df["Title"] = df["Title"].replace("Imvestments", "Investments")

    return df


df = clean_dataframe(df)

# Save to Excel or CSV in the same directory as the input PDF
output_file = os.path.join(output_dir, "leads_output.xlsx")
csv_output = os.path.join(output_dir, "leads_output.csv")
try:
    import openpyxl

    df.to_excel(output_file, index=False, engine="openpyxl")
    print(f"Excel file created: {output_file}")
except ImportError:
    print("Error: 'openpyxl' module not found. Saving as CSV instead.")
    df.to_csv(csv_output, index=False)
    print(f"CSV file created: {csv_output}")
    print("To save as Excel, install openpyxl with: pip install openpyxl")

print(f"Total records processed: {len(df)}")