# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=TheOneMemory
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=X00T
device.name2=X00TD
device.name3=ASUS_X00T
device.name4=ASUS_X00TD
device.name5=ASUS_X00TDA
supported.versions=9.0 - 11.0
supported.patchlevels=2018-04 -
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

# Mount partitions as rw
mount /system;
mount /vendor;
mount -o remount,rw /system;
mount -o remount,rw /vendor;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin;
chown -R root:root $ramdisk/*;

## AnyKernel boot install
dump_boot;

# begin ramdisk changes

#Remove old kernel stuffs from ramdisk
ui_print "Remove old script..."
rm -rf $ramdisk/init.special_power.sh
rm -rf $ramdisk/init.darkonah.rc
rm -rf $ramdisk/init.spectrum.rc
rm -rf $ramdisk/init.spectrum.sh
rm -rf $ramdisk/init.boost.rc
rm -rf $ramdisk/init.trb.rc
rm -rf $ramdisk/init.azure.rc
rm -rf $ramdisk/init.PBH.rc
rm -rf $ramdisk/init.Pbh.rc
rm -rf $ramdisk/init.overdose.rc
rm -rf $ramdisk/init.forcedt2w.rc

# init.rc
backup_file init.rc;
remove_line init.rc "import /init.darkonah.rc";
remove_line init.rc "import /init.spectrum.rc";
remove_line init.rc "import /init.boost.rc";
remove_line init.rc "import /init.trb.rc"
remove_line init.rc "import /init.azure.rc"
remove_line init.rc "import /init.PbH.rc"
remove_line init.rc "import /init.Pbh.rc"
remove_line init.rc "import /init.overdose.rc"
replace_string init.rc "cpuctl cpu,timer_slack" "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";

# end ramdisk changes

# begin EAS patch changes
if [ ! -e "/vendor/etc/powerhint.json" ]; then
    ui_print " " "Hmm...HMP rom installed"
    ui_print "Installing EAS PerfHAL..."
    rm -rf /data/adb/modules/SDM660PerfHAL;
    cp -rf $home/tools/SDM660PerfHAL /data/adb/modules/SDM660PerfHAL;
else
    ui_print " " "You installed EAS rom"
    ui_print "So install EAS PerHal no required"
fi
# end EAS patch changes

write_boot;
## end boot install


# shell variables
#block=vendor_boot;
#is_slot_device=1;
#ramdisk_compression=auto;
#patch_vbmeta_flag=auto;

# reset for vendor_boot patching
#reset_ak;


## AnyKernel vendor_boot install
#split_boot; # skip unpack/repack ramdisk since we don't need vendor_ramdisk access

#flash_boot;
## end vendor_boot install

## end install
