#!/usr/bin/env sh
echo starting wait
while ! cat $WAITFOR ; do sleep 1; echo sleep waitingz for file ; done
echo found $WAITFOR
cat $WAITFOR
sleep 60
