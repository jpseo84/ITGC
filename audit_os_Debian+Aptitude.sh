#!/bin/bash

###########################################################################
# ITGC Operating System (Linux) Evidence Collector 0.1                    #
# Copyright (C) 2023 Jupyo Seo                                            #
# This program is free software; you can redistribute it and/or modify    #
# it under the terms of the GNU General Public License as published by    #
# the Free Software Foundation; either version 3 of the License, or       #
# (at your option) any later version.                                     #
#                                                                         #
# This program is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of          #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
# GNU General Public License for more details.                            #
#                                                                         #
# You should have received a copy of the GNU General Public License along #
# with this program; if not, write to the Free Software Foundation, Inc., #
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.             #
###########################################################################

# Function to run the command and generate the chained hash
run_command() {
    command=$1
    previous_hash=$2
    output_file=$3

    # Get the result of the command
    result=$(eval $command)

    # Get the hostname
    hostname=$(hostname)

    # Get the current timestamp
    timestamp=$(date)

    # If there's a previous hash, prepend it to the current output
    if [ ! -z "$previous_hash" ]; then
        result="Previous Hash: $previous_hash\n$result"
    fi

    # Append the metadata to the result
    result="$result\n\nHostname: $hostname\nTimestamp: $timestamp"

    # Generate the hash for the current output
    current_hash=$(echo -e "$result" | sha256sum | awk '{print $1}')

    # Append the hash to the result
    result="$result\nHash: $current_hash"

    echo -e "$result" > $output_file

    echo $current_hash
}

commands=(
    "cat /etc/passwd"
    "cat /etc/login.defs"
    "cat /etc/group"
    "ls -l /etc/pam.d"
    "cat /etc/pam.d/common-auth" #Debian-specific (Password complexity)
    "cat /etc/pam.d/common-password" #Debian-specific (Password complexity)
    "cat /etc/pam.d/su" #Debian-specific (Superuser - wheel group)
    "sudo cat /etc/sudoers" #Debian-specific (Superuser - sudoers)
    "cat /var/log/apt/history.log"
    "echo 'Using birth time:' && find /home -maxdepth 1 -type d -exec stat -c '%n : %w' {} \;"
    "echo 'Using modification time:' && find /home -maxdepth 1 -type d -exec stat -c '%n : %y' {} \;"
    "echo 'Using change time:' && find /home -maxdepth 1 -type d -exec stat -c '%n : %z' {} \;"
)

previous_hash=""
final_output=""

for index in "${!commands[@]}"; do
    current_command=${commands[$index]}
    output_file="output_$(($index + 1)).txt"
    previous_hash=$(run_command "$current_command" "$previous_hash" "$output_file")
    final_output="$final_output$(cat $output_file)"
done

# Generate a final hash encompassing all outputs
final_hash=$(echo -e "$final_output" | sha256sum | awk '{print $1}')

echo "Final Hash: $final_hash"

# Save the final hash to a file
echo "Final Hash: $final_hash" > final_hash.txt