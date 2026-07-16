#!/bin/bash

# Solution 1. awk + sort
echo Top 5 IP addresses with the most requests:
awk '{ count[$1]++ } END {
    for (ip in count) 
        print ip, count[ip]
}' nginx-access.log | sort -k2,2nr | head -n5 | awk '{ printf "%s - %d requests\n", $1, $2 }'
echo

# Solution 2. cut + sort + uniq
echo Top 5 most requested paths:
cut -d' ' -f7 nginx-access.log | sort | uniq -c | sort -nr | head -n5 | awk '{ printf "%s - %d requests\n", $2, $1 }'
echo

# Solution 3. awk (match, substr) + sort
echo Top 5 response status codes:
awk '
{
    if (match($0, /" [0-9][0-9][0-9] /)) {
        code = substr($0, RSTART + 2, 3)
        count[code]++
    }
} 
END {
    for (code in count)
        print code, count[code]
}
' nginx-access.log | sort -k2,2nr | head -n5 | awk '{ printf "%s - %d requests\n", $1, $2 }'
echo

# # Solution 4. awk (split) + sort
echo Top 5 user agents:
awk '{
    split($0, parts, "\"")
    count[parts[6]]++
}
END {
    for (agent in count)
        print count[agent], agent
}' nginx-access.log | sort -nr | head -n5 | 
awk '{     
    count = $1
    $1 = ""
    sub(/^ /, "")
    printf "%s - %d requests\n", $0, count
}'
