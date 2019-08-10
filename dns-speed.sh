#!/bin/bash
# Title:        dns-speed.sh
# Author:       Luis Enrique Pineda @caniculari
# Description:  Test the DNS resolution time from several DNS servers

name="linux.org"
temp_file="/tmp/dns-speed.tmp"

# Create a temporary file to store the results
if [ -f $temp_file ]; then
    rm $temp_file
fi
touch $temp_file

# Test the dns servers listed on the dns-list.txt file
while read i; do
    sum=0
    for n_attempt in $(seq 1 3); do
        dns=`echo $i | awk -F ',' '{print $1}'`
        ip=`echo $i | awk -F ',' '{print $2}'`
        response=`dig +timeout=1 @$ip $name | grep 'Query time' | awk '{print $4}'`
        if [ -z "$response"  ]; then
            echo $dns $ip "not responding"
            break;
        else
            printf "%s" $dns
            printf "\t%s\t" $ip
            printf "%s msec\n" $response

            sum=$((sum + response))


        fi
        if [ "$n_attempt" -eq "3" ]; then
            echo $((sum/3)) msec $dns $ip  >>$temp_file
        fi
    done
done <dns-list.txt

# Print your fastest DNS
printf "\n===---Top Ten Fastest DNS---===\n"
sort -g $temp_file | head -n 10
rm $temp_file

