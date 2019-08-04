#!/bin/bash
curl -sS -X POST -H 'Content-type: application/json' --data '{"text":"start createrepo"}' "$SLACK_URL"
set -x
mkdir -p ./repo
aws s3 sync --no-progress "$S3SYNC_FROM/repodata" ./repo/repodata
aws s3 sync --no-progress "$S3SYNC_FROM/RPMS" ./repo/RPMS
(
set -x
find repo/RPMS -type f -mtime -10 -ls
createrepo --update ./repo
aws s3 sync --no-progress --delete repo/repodata "$S3SYNC_FROM/repodata"
) 2>&1 |tee -a log
aws cloudfront create-invalidation --distribution-id "$CF_DISTRIID" --paths "$CF_PATH"
cat << EOS > data
end createrepo
\`\`\`
$(cat log)
\`\`\`
EOS
cat << EOS > log
{ "text": $(cat data|python -c 'import json,sys; print(json.dumps(sys.stdin.read()))') }
EOS
curl -XPOST -H 'Content-type: application/json' -d @log "$SLACK_URL"
rm -rf log data
