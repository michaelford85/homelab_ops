from googleapiclient.discovery import build
from google.oauth2 import service_account
from googleapiclient.http import MediaFileUpload
import sys
import os

SCOPES = ['https://www.googleapis.com/auth/drive']
SERVICE_ACCOUNT_FILE = 'service_account.json'

def authenticate():
    creds = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
    return creds

def upload_file(file_path, parent_folder_id):
    creds = authenticate()
    service = build('drive', 'v3', credentials=creds)

    # Extract file name from path
    file_name = os.path.basename(file_path)

    file_metadata = {
        'name': file_name,
        'parents': [parent_folder_id]
    }

    file = service.files().create(
        body=file_metadata,
        media_body=file_path,
        fields='id'
    ).execute()
        
    

    # print('File ID: %s' % file.get('id'))

# Check if both file path and parent folder ID are provided
if len(sys.argv) > 2:
    file_path = sys.argv[1]
    parent_folder_id = sys.argv[2]
    upload_file(file_path, parent_folder_id)
else:
    print("Please provide both the file path and the parent folder ID as command line arguments.")

