#!/bin/bash

# Ask the user for the server and client IP
read -p "Enter your server IP: " SERVER_IP  # Store the server IP provided by the user
read -p "Enter your client IP: " CLIENT_IP  # Store the client IP provided by the user

# Ask user if they want to add or delete the rules
read -p "Do you want to add or delete the rules? (add/delete): " USER_ACTION  # Store the action provided by the user

# Specify your WAN interface
INTERFACE="enp1s0"  # Define the network interface being used

# Check if action is add or delete
if [[ "$USER_ACTION" == "add" ]]; then  # If the user wants to add rules
    ACTION='-A'  # Set ACTION to -A (Append)
elif [[ "$USER_ACTION" == "delete" ]]; then  # If the user wants to delete rules
    ACTION='-D'  # Set ACTION to -D (Delete)
else
    echo "Invalid action. Please enter 'add' or 'delete'."  # If an invalid action is provided, print an error and exit
    exit 1
fi

# Drop known amplified UDP source ports (split into multiple rules due to 15 ports limit per rule)
AMPLIFIED_PORTS1="19,53,123,161,37,111,137,389,445"  # Define first set of ports to be blocked
AMPLIFIED_PORTS2="500,514,520,1900,2049,2086,2087"  # Define second set of ports to be blocked
AMPLIFIED_PORTS3="3478,5060,11211"  # Define third set of ports to be blocked

# Add or delete INPUT rules to drop packets from specified UDP source ports
iptables $ACTION FORWARD -p udp -d $CLIENT_IP -m multiport --sports $AMPLIFIED_PORTS1 -j DROP
iptables $ACTION FORWARD -p udp -d $CLIENT_IP -m multiport --sports $AMPLIFIED_PORTS2 -j DROP
iptables $ACTION FORWARD -p udp -d $CLIENT_IP -m multiport --sports $AMPLIFIED_PORTS3 -j DROP

# GTA V UDP Ports
# Add or delete DNAT rule for the specified UDP ports
iptables -t nat $ACTION PREROUTING -p udp -i $INTERFACE -m multiport --dports 6672,61455:61458 -j DNAT --to-destination $CLIENT_IP

# Add or delete FORWARD rule to allow specified UDP ports through firewall
iptables $ACTION FORWARD -p udp -d $CLIENT_IP -m multiport --dports 6672,61455:61458 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
