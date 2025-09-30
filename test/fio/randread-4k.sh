#!/bin/bash
set -e

# Declare variable
TEST_SHELL_FILE=${BASH_SOURCE##*/}
TEST_NAME=${TEST_SHELL_FILE%.*}
TEST_DIRECTORY=/tmp/${TEST_NAME}
OUTPUT_FILE=/var/log/fio/${TEST_NAME}.log

# Clear legacy test data.
[ -d ${TEST_DIRECTORY} ] && rm -rf ${TEST_DIRECTORY} || true
mkdir ${TEST_DIRECTORY}
[ -e ${OUTPUT_FILE} ] && rm ${OUTPUT_FILE} || true

fio \
  --name=${TEST_NAME} \
  --directory=${TEST_DIRECTORY} \
  --rw=randread \
  --size=500m \
  --io_size=10g \
  --blocksize=4k \
  --fsync=1 \
  --iodepth=1 \
  --direct=1 \
  --numjobs=1 \
  --runtime=60 \
  --group_reporting \
  --output=${OUTPUT_FILE}
