# coding: utf-8

"""
FILE: aws_async.py
DESCRIPTION:
    This sample demonstrates common container operations including list blobs, create a container,
    set metadata etc.
USAGE:
    python aws_async.py <filename>
    Set the environment variables with your own values before running the sample:
    1) AWS_ACCESS_KEY - AWS Access key
    2) AWS_SECRET_KEY - AWS Secret key for accessing aws services
    3) AWS_S3_BUCKET - AWS S3 bucket name for storing the objects
"""

import asyncio
import aiobotocore
import os
from pathlib import Path
import sys

class AWSS3Async(object):
    ACCESS_KEY = os.getenv("AWS_ACCESS_KEY", None)
    SECRET_KEY = os.getenv('AWS_SECRET_KEY', None)
    AWS_S3_BUCKET = os.getenv('AWS_S3_BUCKET', None)
    AWS_S3_SUB_FOLDER = os.getenv('AWS_S3_SUB_FOLDER', 'backups')
    REGION = os.getenv('AWS_REGION', None)
    SOURCE_FILE = None

    def __init__(self, file):
        self.SOURCE_FILE = file

    async def upload_file_to_s3(self):
        
        file_name = Path(self.SOURCE_FILE).name
        file_s3_abs_path = "{sub_folder}/{file_name}".format(
            sub_folder=self.AWS_S3_SUB_FOLDER,
            file_name=file_name
        )

        session = aiobotocore.get_session()
        async with session.create_client('s3', region_name=self.REGION, aws_secret_access_key=self.SECRET_KEY, aws_access_key_id=self.ACCESS_KEY) as client:
            try:
                with open(self.SOURCE_FILE, "rb") as data:

                    await client.put_object(Bucket=self.AWS_S3_BUCKET,
                                        Key=file_s3_abs_path,
                                        Body=data)
            except ResourceExistsError:
                print("Blob with name {} already exists.".format(filename))



async def main():
    file_path = sys.argv[1]
    aws_client = AWSS3Async(file=file_path)
    await aws_client.upload_file_to_s3()


if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())