#!/bin/bash
/sbin/vgcfgbackup
INSTANCE_ID=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
LV_DEVICES=`/sbin/lvdisplay --maps | grep "Physical volume" | awk '{print $3}'`
LV_VOLUME=`lvdisplay  | grep "LV Name" | awk '{print $3}'`
echo "Instance: " $INSTANCE_ID
echo "* Suspending LVM.."
/sbin/dmsetup suspend $LV_VOLUME
for DEVICE in $LV_DEVICES
do
	DEVICE_LETTER_ID=`echo ${DEVICE:${#DEVICE} - 1}`
	echo " * $DEVICE "-> /dev/sd"$DEVICE_LETTER_ID"
	DEVICE_VOL_ID=`ec2-describe-instances $INSTANCE_ID | grep "/dev/sd$DEVICE_LETTER_ID" | awk '{print $3}'`
	ec2-create-snapshot -d "$(hostname)-lvm-$(basename "$DEVICE")" $DEVICE_VOL_ID
done
echo "* Resuming LVM.."
/sbin/dmsetup resume $LV_VOLUME
