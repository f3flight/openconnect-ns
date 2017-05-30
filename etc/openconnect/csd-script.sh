#!/bin/bash

function run_curl
{
curl \
--insecure \
--user-agent "AnyConnect Windows $ver" \
--header "X-Transcend-Version: 1" \
--header "X-Aggregate-Auth: 1" \
--header "X-AnyConnect-Platform: $plat" \
--cookie "sdesktop=$token" \
"$@"
}

set -e

host=https://$CSD_HOSTNAME
plat=win
ver=3.1.10010
token=$CSD_TOKEN

run_curl --data-ascii @- "$host/+CSCOE+/sdesktop/scan.xml?reusebrowser=1" <<-END
endpoint.policy.location="corplaptop";
END

exit 0
