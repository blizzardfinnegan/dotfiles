
set --local hostName (uname -n)
set --local diskSpace (df -Ph --total | awk '/total/ {print $4"B";}' | tr -d '\n')
set --local memoryUsed (free -h --si | awk '/Mem/ {print $6"B";}')
set --local cpuUsage (top -bn1 | awk '/Cpu/ {print $2}')
set --local distroName (cat /etc/os-release | awk '/PRETTY/ {gsub("PRETTY_NAME=",""); gsub("GNU/Linux ","");print}' | tr -d '"')

echo "=====================================================
 - Hostname..................: $hostName
 - Distro....................: $distroName
 - Total Disk Space Free.....: $diskSpace
 - Memory used...............: $memoryUsed
 - CPU usage.................: $cpuUsage%
=====================================================
"
