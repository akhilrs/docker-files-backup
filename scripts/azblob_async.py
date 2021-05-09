# coding: utf-8

"""
FILE: azblob_async.py
DESCRIPTION:
    This sample demonstrates common container operations including list blobs, create a container,
    set metadata etc.
USAGE:
    python azblob_async.py <filename>
    Set the environment variables with your own values before running the sample:
    1) AZURE_SA_CONNECTION_STRING - the connection string to your storage account
    2)AZURE_SA_CONTAINER - container name for storing blobs
"""

import asyncio
import os
import sys

from azure.core.exceptions import ResourceExistsError
from azure.storage.blob import BlobType


class AZContainerAsync(object):
    CONNECTION_STRING = os.getenv("AZURE_SA_CONNECTION_STRING", None)
    CONTAINER_NAME = os.getenv('AZURE_SA_CONTAINER', None)
    BLOB_TYPE = BlobType.BlockBlob
    SOURCE_FILE = None

    def __init__(self, file):
        self.SOURCE_FILE = file

    async def upload_file_to_blob(self):
        # Instantiate a BlobServiceClient using a connection string
        from azure.storage.blob.aio import BlobServiceClient
        blob_service_client = BlobServiceClient.from_connection_string(self.CONNECTION_STRING)

        async with blob_service_client:
            # Instantiate a ContainerClient
            container_client = blob_service_client.get_container_client(self.CONTAINER_NAME)

            try:
                await container_client.create_container()
            except ResourceExistsError:
                print("Container already exists.")

            path, filename = os.path.split(self.SOURCE_FILE)
            # [START upload_blob_to_container]
            try:
                with open(self.SOURCE_FILE, "rb") as data:
                    blob_client = await container_client.upload_blob(name=filename, data=data, blob_type=self.BLOB_TYPE)
            except ResourceExistsError:
                print("Blob with name {} already exists.".format(filename))


async def main():
    file_path = sys.argv[1]
    az_sa_client = AZContainerAsync(file=file_path)
    await az_sa_client.upload_file_to_blob()


if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())