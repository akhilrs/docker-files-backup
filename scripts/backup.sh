#!/bin/sh

set -e

if [ "${SOURCE_DIR}" = "**None**" ]; then
  echo "You need to set the SOURCE_DIR environment variable."
  exit 1
fi

KEEP_DAYS=${BACKUP_KEEP_DAYS}
KEEP_WEEKS=`expr $(((${BACKUP_KEEP_WEEKS} * 7) + 1))`
KEEP_MONTHS=`expr $(((${BACKUP_KEEP_MONTHS} * 31) + 1))`

#Initialize dirs
mkdir -p "${BACKUP_DIR}/daily/" "${BACKUP_DIR}/weekly/" "${BACKUP_DIR}/monthly/"


BASE_DIR=$(basename "${SOURCE_DIR}")


#Initialize filename vers
DFILE="${BACKUP_DIR}/daily/${BASE_DIR}-`date +%Y%m%d-%H%M%S`.tar.gz"
WFILE="${BACKUP_DIR}/weekly/${BASE_DIR}-`date +%G%V`.tar.gz"
MFILE="${BACKUP_DIR}/monthly/${BASE_DIR}-`date +%Y%m`.tar.gz"
  

echo "Compressing files from ${SOURCE_DIR}..."
tar -zcvf "${DFILE}" "${SOURCE_DIR}"


#Copy (hardlink) for each entry
ln -vf "${DFILE}" "${WFILE}"
ln -vf "${DFILE}" "${MFILE}"
#Clean old files
echo "Cleaning older than ${KEEP_DAYS} days"
find "${BACKUP_DIR}/daily" -maxdepth 1 -mtime +${KEEP_DAYS} -name "${BASE_DIR}-*.tar.gz" -exec rm -rf '{}' ';'
find "${BACKUP_DIR}/weekly" -maxdepth 1 -mtime +${KEEP_WEEKS} -name "${BASE_DIR}-*.tar.gz" -exec rm -rf '{}' ';'
find "${BACKUP_DIR}/monthly" -maxdepth 1 -mtime +${KEEP_MONTHS} -name "${BASE_DIR}-*.tar.gz" -exec rm -rf '{}' ';'

echo "Created backup file."

# Executing python script for uploading backup file to cloud.
if [ "${CLOUD_BACKUP}" = "True" ]; then
  if [ "${CLOUD_PROVIDER}" = "Azure" ]; then
    python3 azblob_async.py ${DFILE}
  elif [ "${CLOUD_PROVIDER}" = "AWS" ]; then
    python3 aws_async.py ${DFILE}
  fi
fi
