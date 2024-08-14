#!/bin/sh

MODULES="scull hello faulty"

is_loaded() {
    module=$1
    lsmod | grep "$module" &> /dev/null
}

create_device_nodes() {
    module=$1
    if [ "$module" != "hello" ]; then
        device=$module
        major=$(awk "\$2==\"$module\" {print \$1}" /proc/devices)
        if [ -z "$major" ]; then
            echo "Failed to get major number for $module"
            exit 1
        fi
        if [ ! -e /dev/$device ]; then
            echo "Creating /dev/$device with major number $major"
            mknod /dev/$device c $major 0
        else
            echo "/dev/$device node already exists"
        fi
    fi
}

load_modules() {
    for module in $MODULES; do
        if is_loaded "$module"; then
            echo "$module is loaded"
        else
            echo "Loading $module"
            modprobe "$module"
            if [ $? -ne 0 ]; then
                echo "Problem loading $module"
                exit 1
            else
                echo "$module loaded successfully"
            fi
            create_device_nodes "$module"
        fi
    done
}

unload_modules() {
    for module in $MODULES; do
        if is_loaded "$module"; then
            echo "Unloading $module"
            modprobe -r "$module"
            if [ $? -ne 0 ]; then
                echo "Problem unloading $module"
                exit 1
            else
                echo "$module unloaded successfully"
            fi
            if [ "$module" != "hello" ]; then
                rm -f /dev/$module
            fi
        else
            echo "$module already unloaded"
        fi
    done
}

case "$1" in
    start)
        load_modules
        ;;
    stop)
        unload_modules
        ;;
    restart)
        unload_modules
        load_modules
        ;;
    status)
        for module in $MODULES; do
            if lsmod | grep "$module" &> /dev/null; then
                echo "$module loaded"
            else
                echo "$module not loaded"
            fi
        done
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0