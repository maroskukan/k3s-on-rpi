#!/usr/bin/env bash

cpu=$(</sys/class/thermal/thermal_zone0/temp)

echo "GPU $(vcgencmd measure_temp | cut -d '=' -f2)"
echo "CPU $((cpu/1000))'C"