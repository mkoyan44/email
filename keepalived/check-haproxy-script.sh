#!/bin/bash

# Check if haproxy is running, return 1 if not.
# Used by keepalived to initiate a failover in case haproxy is down

HAPROXY_STATUS=$(/bin/ps ax | grep -w [h]aproxy)
if [ "$HAPROXY_STATUS" != "" ]
then
  exit 0
else
  logger "HAProxy is NOT running. Setting keepalived state to FAULT."
  exit 1
fi
