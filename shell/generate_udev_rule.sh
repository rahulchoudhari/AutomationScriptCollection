#!/bin/bash
 MTYP=`dmidecode -t1 | grep "Product Name" | awk '{print $3}'`
 if [ "$MTYP" != "VMware" ]
 then
    if [ $# -eq 0 ]
    then
        echo
        echo "INFO: SERVER IS **PHYSICAL** MACHINE"
        echo
        echo "Please pass the file name as argument which contain list of mpath/wwn : Example"
        echo
        echo "cat /tmp/mpath.list"
        echo "mpathxy"
        echo "OR"
        echo "123475405jsd92382349032"
        echo
        echo "Then run the script: bash generate_udev_for_asm.sh /tmp/asmdisk"
        exit
    fi
    read -p "Enter username to own the device : " user
    read -p "Enter groupname to own the device : " group
    echo
    for mpath in `cat $1`
    do
        /sbin/multipath -ll | grep -w $mpath | awk '{print $3}' >> /tmp/mpath.devicemapper
    done
    echo "+++Please paste following in /etc/udev/rules.d/99-oracle-asmdevices.rules+++"
    echo
    for dm in `cat /tmp/mpath.devicemapper`
    do
        echo "KERNEL==\"dm-*\",ENV{DM_UUID}==\"`udevadm info --query=all --path=/devices/virtual/block/$dm | grep DM_UUID |awk -F '=' '{print $2}'`\",OWNER=\"$user\",GROUP=\"$group\",MODE=\"0660\" "
    done
    echo
    echo "Once file is updated, then Run following command:"
    echo
    echo "/sbin/udevadm control -reload-rules"
    echo "/sbin/udevadm trigger -type=devices -action=change"
    > /tmp/mpath.devicemapper
else
    if [ $# -eq 0 ]
    then
        echo
        echo "INFO: SERVER IS **VIRTUAL** MACHINE"
        echo
        echo "Please pass the file name as argument which contain list of \"DISKNAME\" \"DISKALIAS\" : Example "
        echo
        echo "cat /tmp/asmdisk"
        echo "sdlm DATA_DISK1"
        echo "sdll REDO_DISK1"
        echo
        echo "Then run the script: bash generate_udev_for_asm.sh /tmp/asmdisk"
        exit
    fi
    read -p "Enter username to own the device : " user
    read -p "Enter groupname to own the device : " group
    echo
    echo "+++Please paste following in /etc/udev/rules.d/99-oracle-asmdevices.rules+++"
    echo
    for sdev in `awk '{print $1}' $1`
    do
        echo "KERNEL==\"sd*\", SUBSYSTEM==\"block\", ENV{DEVTYPE}==\"disk\", ENV{ID_SERIAL}==\"`udevadm info --query=all --name=$sdev | grep ID_SERIAL= | awk -F '=' '{print $2}'`\", SYMLINK+=\"oracleasm/disks/`grep -w $sdev /tmp/path | awk '{print $2}'`\", OWNER=\"$user\", GROUP=\"$group\", MODE=\"0660\" "
    done
    echo
    echo "Once file is updated, then Run following command:"
    echo
    echo "/sbin/udevadm control -reload-rules"
    echo "/sbin/udevadm trigger -type=devices -action=change"
fi
