#!/bin/bash
sum=0; 
count=0;
max=0;
sitemax=""
thr=1048576
sites="=========================================\nAyBU Sites with more than $(($thr/1024)) kB of mem:\n========================================="

function process_site() 
{
	[ ! -d $dir ] && continue
	mem=$(cat $dir/memory.usage_in_bytes)
	sum=$(( $sum + $mem ))
	count=$(( $count +1 ))
	[ $mem -gt $max ] && sitemax=$dir && max=$mem
	[ $mem -gt $thr ] && sites="$sites\n$dir : $(($mem / 1024))kB [$(($mem / 1024 / 1024))MB]"
}

pushd /sys/fs/cgroup/memory/sites/aybu &>/dev/null
for dir in *;
do
	process_site
done

sites="$sites\n=========================================\nOthers:\n========================================="
pushd /sys/fs/cgroup/memory/sites/ &>/dev/null
for dir in *
do
	[[ $dir == "aybu" ]] && continue
	process_site
done
popd &>/dev/null
popd &>/dev/null

echo "$count sites use $(( $sum / 1024))kB of ram [$(( $sum / 1024 / 1024 ))MB]"
echo "Highest utilization from $sitemax"
echo -e $sites
