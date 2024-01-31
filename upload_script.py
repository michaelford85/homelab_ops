from googleapiclient.discovery import build
from google.oauth2 import service_account
from googleapiclient.http import MediaFileUpload
import sys
import os
from googleapiclient.errors import HttpError
import time

SCOPES = ['https://www.googleapis.com/auth/drive']
SERVICE_ACCOUNT_FILE = 'service_account.json'

def authenticate():
    creds = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES)
    return creds

def upload_file(file_path, parent_folder_id, retries=5, backoff=1):
    creds = authenticate()
    service = build('drive', 'v3', credentials=creds)

    file_name = os.path.basename(file_path)

    file_metadata = {
        'name': file_name,
        'parents': [parent_folder_id]
    }

    media = MediaFileUpload(file_path, resumable=True)

    request = service.files().create(body=file_metadata, media_body=media, fields='id')

    response = None
    while response is None:
        try:
            print("Attempting to upload...")
            status, response = request.next_chunk()
            if status:
                print("Uploaded %d%%." % (status.progress() * 100))
        except HttpError as e:
            if e.resp.status in [404, 500, 502, 503, 504]:
                print("A retryable error occurred: %s" % e)
                if retries > 0:
                    retries -= 1
                    time.sleep(backoff)
                    backoff *= 2
                    continue
                else:
                    raise
            else:
                raise
        except Exception as e:
            print("An error occurred: %s" % e)
            raise

    print('File ID: %s' % response.get('id'))

# Check if both file path and parent folder ID are provided
if len(sys.argv) > 2:
    file_path = sys.argv[1]
    parent_folder_id = sys.argv[2]
    upload_file(file_path, parent_folder_id)
else:
    print("Please provide both the file path and the parent folder ID as command line arguments.")