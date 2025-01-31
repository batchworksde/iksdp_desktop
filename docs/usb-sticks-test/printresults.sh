#!/bin/bash

for file in *.json; do
  jq --arg filename "$file" '.jobs[] | {filename: $filename, jobname: .jobname, iops_read: .read.iops, runtime_read: .read.runtime, iops_write: .write.iops, runtime_write: .write.runtime}' "$file"
done

