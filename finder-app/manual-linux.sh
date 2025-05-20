
#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

CURRENT_DIR=$(pwd)
OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

sudo apt-get install libgmp-dev

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    make mrproper
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} allyesconfig
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
fi

echo "Adding the Image in outdir"
cp /tmp/aeld/linux-stable/arch/arm64/boot/Image ${OUTDIR}
echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
else
    cd busybox
fi

# TODO: Make and install busybox
make defconfig
make ARCH=${ARCH} CROSS=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install


# TODO: Add library dependencies to rootfs
cp /usr/aarch64-linux-gnu/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
cp /usr/aarch64-linux-gnu/lib/libm.so.6 ${OUTDIR}/rootfs/lib
cp /usr/aarch64-linux-gnu/lib/libresolv.so.2 ${OUTDIR}/rootfs/lib
cp /usr/aarch64-linux-gnu/lib/libc.so.6 ${OUTDIR}/rootfs/lib
cp /usr/aarch64-linux-gnu/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib64
cp /usr/aarch64-linux-gnu/lib/libm.so.6 ${OUTDIR}/rootfs/lib64
cp /usr/aarch64-linux-gnu/lib/libresolv.so.2 ${OUTDIR}/rootfs/lib64
cp /usr/aarch64-linux-gnu/lib/libc.so.6 ${OUTDIR}/rootfs/lib64


# TODO: Make device nodes
cd ${OUTDIR}
sudo rm -f ./dev/null
sudo rm -f ./dev/console
sudo mknod ./dev/null c 1 3
sudo chmod 666 ./dev/null
sudo mknod ./dev/console c 5 1
sudo chmod 600 ./dev/console
sudo chown root:tty ./dev/console


# TODO: Clean and build the writer utility
cd $CURRENT_DIR
make clean
make

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp ./writer ${OUTDIR}/rootfs/home/
cp ./finder.sh ${OUTDIR}/rootfs/home/
cp ./finder-test.sh ${OUTDIR}/rootfs/home/
cp ./writer.sh ${OUTDIR}/rootfs/home/
cp ./autorun-qemu.sh ${OUTDIR}/rootfs/home/
mkdir ${OUTDIR}/rootfs/home/conf
cp ./conf/assignment.txt ${OUTDIR}/rootfs/home/conf/
cp ./conf/username.txt ${OUTDIR}/rootfs/home/conf/
 

# TODO: Chown the root directory
sudo chown -R marko:marko ${OUTDIR}

# TODO: Create initramfs.cpio.gz
cd "$OUTDIR/rootfs"
find . | cpio -H newc -ov --owner marko:marko > ${OUTDIR}/initramfs.cpio
gzip -f ${OUTDIR}/initramfs.cpio
