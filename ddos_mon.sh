#!/bin/bash

# Define the sets of ports to be monitored
AMPLIFIED_PORTS1="19,53,123,161,37,111,137,389,445"
AMPLIFIED_PORTS2="500,514,520,1900,2049,2086,2087"
AMPLIFIED_PORTS3="3478,5060,11211"

# Convert the comma-separated lists to space-separated lists
PORTS1=${AMPLIFIED_PORTS1//,/ }
PORTS2=${AMPLIFIED_PORTS2//,/ }
PORTS3=${AMPLIFIED_PORTS3//,/ }

# Create a tcpdump expression for each port
EXPR1=$(for port in $PORTS1; do echo -n "port $port or "; done)
EXPR2=$(for port in $PORTS2; do echo -n "port $port or "; done)
EXPR3=$(for port in $PORTS3; do echo -n "port $port or "; done)

# Combine all the expressions and remove the trailing 'or '
EXPR="${EXPR1}${EXPR2}${EXPR3}"
EXPR=${EXPR%or }

# Run tcpdump with the constructed expression, stopping after 10000 packets
tcpdump -ni wg0 -c 10000 "$EXPR"
