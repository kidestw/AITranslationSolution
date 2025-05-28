import logging
import os
import json
import requests
import azure.functions as func
from azure.storage.blob import BlobServiceClient

# Environment variables
TRANSLATOR_KEY = os.environ["TRANSLATOR_KEY"]
TRANSLATOR_REGION = os.environ["TRANSLATOR_REGION"]
STORAGE_CONNECTION_STRING = os.environ["AzureWebJobsStorage"]

def main(inputblob: func.InputStream, outputblob: func.Out[str], logblob: func.Out[str]):

    logging.info(f"Processing file: {inputblob.name}")

    try:
        # Read content from blob
        input_text = inputblob.read().decode('utf-8')

        # Get container and blob name
        container_name, blob_name = inputblob.name.split('/', 1)

        # Get blob metadata to determine language
        blob_service_client = BlobServiceClient.from_connection_string(STORAGE_CONNECTION_STRING)
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
        metadata = blob_client.get_blob_properties().metadata
        target_language = metadata.get('language', 'fr')

        # Prepare translation request
        translate_url = f"https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to={target_language}"
        headers = {
            'Ocp-Apim-Subscription-Key': TRANSLATOR_KEY,
            'Ocp-Apim-Subscription-Region': TRANSLATOR_REGION,
            'Content-type': 'application/json'
        }
        body = [{'text': input_text}]
        
        # Call the translator API
        response = requests.post(translate_url, headers=headers, json=body)
        response.raise_for_status()
        result = response.json()
        translated_text = result[0]['translations'][0]['text']

        # Output translated text
        outputblob.set(translated_text)

        # Log success
        log_message = f"Translated from {inputblob.name} to {target_language} successfully."
        logblob.set(log_message)
        logging.info(log_message)

    except Exception as e:
        error_message = f"Translation failed for {inputblob.name}: {str(e)}"
        logblob.set(error_message)
        logging.error(error_message)
