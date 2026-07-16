#!/bin/bash

cpu_usage=$(top -bn1 | grep "%Cpu(s):" | cut -d ',' -f 4 | awk '{print 100 - $1}')
read total_memory used_memory free_memory <<< "$(free -h | awk '/Mem:/ {print $2, $3, $4}')"
read used_memory_percent free_memory_percent <<< "$(free -b | awk '/Mem:/ {printf "%.1f %.1f", $3/$2*100, $4/$2*100}')"
read total_disk used_disk free_disk <<< "$(df -h / | awk 'NR==2 {print $2, $3, $4, $5}')"
read used_disk_percent free_disk_percent <<< "$(df -B1 / | awk 'NR==2 {
    used_pct = $3 / $2 * 100 
    free_pct = $4 / $2 * 100
    printf "%.1f %.1f", used_pct, free_pct
}')"

echo "===== Server Performance Stats ====="
echo

echo "# CPU Usage"
echo "Total: $cpu_usage%"
echo

echo "# Memory Usage"
echo "Total: $total_memory"
echo "Used: $used_memory (${used_memory_percent}%)"
echo "Free: $free_memory (${free_memory_percent}%)"
echo

echo "# Disk Usage"
echo "Total: $total_disk"
echo "Used: $used_disk (${used_disk_percent}%)"
echo "Free: $free_disk (${free_disk_percent}%)"
echo

echo "# Top 5 processes by CPU usage"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6
echo 

echo "# Top 5 processes by memory usage"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -6
echo
