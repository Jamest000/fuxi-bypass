#!/system/bin/sh
MODDIR=${0%/*}

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# 1. Load Kprobe screen-on bypass module if not loaded
if [ -f "$MODDIR/fuxi_unblank_bypass.ko" ]; then
    grep -q "^fuxi_unblank_bypass " /proc/modules || insmod "$MODDIR/fuxi_unblank_bypass.ko" 2>/dev/null
fi

# 2. Continuous daemon to lock full-speed charging & disable thermal/aging limits
while true; do
    USB_ONLINE=$(cat /sys/class/power_supply/usb/online 2>/dev/null)
    STATUS=$(cat /sys/class/power_supply/battery/status 2>/dev/null)

    if [ "$USB_ONLINE" = "1" ] || [ "$STATUS" = "Charging" ]; then
        echo 1 > /sys/class/qcom-battery/thermal_remove 2>/dev/null
        echo 0 > /sys/class/qcom-battery/restrict_chg 2>/dev/null
        echo 0 > /sys/class/qcom-battery/restrict_cur 2>/dev/null
        echo 0 > /sys/class/qcom-battery/smart_batt 2>/dev/null
        echo 0 > /sys/class/qcom-battery/smart_chg 2>/dev/null
        echo 0 > /sys/class/qcom-battery/night_charging 2>/dev/null
        echo 100 > /sys/class/qcom-battery/fake_cycle 2>/dev/null
        echo 12200 > /sys/class/qcom-battery/mtbf_current 2>/dev/null
        echo 0 > /sys/class/power_supply/battery/charge_control_limit 2>/dev/null
    fi
    sleep 2
done
