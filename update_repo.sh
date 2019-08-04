#!/bin/bash
echo '```' >> log
set -x
aws s3 sync --quiet --exclude "*" --include repodata --include RPMS "$S3SYNC_FROM" repo 2>&1 |tee -a log
createrepo --update ./repo  2>&1 |tee -a log
find repo/RPMS -type f -mtime -10 -ls |tee -a log
aws s3 sync --no-progress --delete repo/repodata "$S3SYNC_FROM/repodata"  2>&1 |tee -a log
echo '```' >> log
aws cloudfront create-invalidation --distribution-id "$CF_DISTRIID" --paths "$CF_PATH"

curl -XPOST -H 'Content-type: application/json' --data "{\"text\": $(cat log|python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}" "$SLACK_URL"
