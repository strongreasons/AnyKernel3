### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=TOM Kernel by Tiktodz @ github
do.devicecheck=0
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=/dev/block/platform/soc/c0c4000.sdhci/by-name/boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;
NO_BLOCK_DISPLAY=1;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

## Get Android version (DO NOT CHANGE)
# begin checker android version
android_ver="$(file_getprop /system/build.prop ro.build.version.release)"

# cleanup first
patch_cmdline "androidboot.version" ""

if [ ! -z "$android_ver" ]; then
	patch_cmdline "androidboot.version" "androidboot.version=$android_ver"
fi
#end checker android version

## Custom MIUI patch (DO NOT CHANGE)
# begin checker custom miui patch
cmdl_add() {
    local fh=$split_img/header
    local fhmod=$split_img/header.mod

    if ! grep "$1" ; then
        cat $fh | sed -E "s/cmdline=(.*)/cmdline=\1 $1/" > $fhmod
        mv $fhmod $fh
    fi
}

cmdl_rm() {
	local fh=$split_img/header
    local fhmod=$split_img/header.mod

    if grep "$1" $fh; then
        cat $fh | sed -E "s/ $1//" $fh > $fhmod
        mv $fhmod $fh
    fi
}

patch_mi() {
    # cleanup it first
    cmdl_rm msm_dsi.phyd_miui=1

    local vi=$(file_getprop /system/build.prop ro.system.build.version.incremental)
    if contains "$ZIPFILE" "miui.zip" || contains "$vi" "V13." || contains "$vi" "V14." ; then
        ui_print "MIUI is detected: $vi";
        ui_print "Enabling msm_dsi.phyd_miui for MIUI compatibility...";
        cmdl_add msm_dsi.phyd_miui=1
    fi
}
#end checker custom miui patch

write_boot; # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
## end boot install


## init_boot files attributes
#init_boot_attributes() {
#set_perm_recursive 0 0 755 644 $RAMDISK/*;
#set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
#} # end attributes

# init_boot shell variables
#BLOCK=init_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for init_boot patching
#reset_ak;

# init_boot install
#dump_boot; # unpack ramdisk since it is the new first stage init ramdisk where overlay.d must go

#write_boot;
## end init_boot install


## vendor_kernel_boot shell variables
#BLOCK=vendor_kernel_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for vendor_kernel_boot patching
#reset_ak;

# vendor_kernel_boot install
#split_boot; # skip unpack/repack ramdisk, e.g. for dtb on devices with hdr v4 and vendor_kernel_boot

#flash_boot;
## end vendor_kernel_boot install


## vendor_boot files attributes
#vendor_boot_attributes() {
#set_perm_recursive 0 0 755 644 $RAMDISK/*;
#set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
#} # end attributes

# vendor_boot shell variables
#BLOCK=vendor_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for vendor_boot patching
#reset_ak;

# vendor_boot install
#dump_boot; # use split_boot to skip ramdisk unpack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot

#write_boot; # use flash_boot to skip ramdisk repack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot
## end vendor_boot install

