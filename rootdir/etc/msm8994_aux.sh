#!/system/bin/sh +v

A53GOV=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
if [ $A53GOV = "interactive" ]; then
	# governor settings for A53
	echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
	echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
	echo "20000 960000:40000 1248000:30000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
	echo 95 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
	echo 25000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
	echo 864000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
	echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
	echo "80 768000:95 864000:99" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
	echo 5000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
	echo 5000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
	echo 80000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
	echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/align_windows
	echo 80000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration
fi

# bring online cpu4
echo 1 > /sys/devices/system/cpu/cpu4/online

A57GOV=`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor`
if [ $A57GOV = "interactive" ]; then
	# governor settings for A57
	echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
	echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
	echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
	echo "20000 1400000:40000 1700000:20000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
	echo 90 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
	echo 25000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
	echo 960000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
	echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
	echo "90 864000:95 1500000:70" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
	echo 10000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
	echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
	echo 80000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
	echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/align_windows
	echo 80000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration
fi

IBOOST=`cat /sys/module/cpu_boost/parameters/boost_ms`
if [ $IBOOST = "0" ]; then
	# input boost settings
	echo 20 > /sys/module/cpu_boost/parameters/boost_ms
	echo "0:864000 1:864000 2:864000 3:864000 4:960000 5:960000 6:960000 7:960000" > /sys/module/cpu_boost/parameters/input_boost_freq
	echo 500 > /sys/module/cpu_boost/parameters/input_boost_ms
	echo Y > /sys/module/cpu_boost/parameters/load_based_syncs
	echo 15 > /sys/module/cpu_boost/parameters/migration_load_threshold
	echo Y > /sys/module/cpu_boost/parameters/sched_boost_on_input
	echo 1344000 > /sys/module/cpu_boost/parameters/sync_threshold
	echo 1 > /sys/module/cpu_boost/parameters/wakeup_boost
	echo 1 > /sys/module/cpu_boost/parameters/sysctl_thermal_aware_scheduling
fi

# HMP Background migration
echo 9 > /proc/sys/kernel/sched_upmigrate_min_nice
echo 90 > /proc/sys/kernel/sched_downmigrate
echo 60 > /proc/sys/kernel/sched_small_task
echo 30 > /proc/sys/kernel/sched_init_task_load

# ensure at least one little core is online
lcores=( 0 1 2 3 -1 )
# tune governors for little cores
for lcore in ${lcores[@]}; do
        [ "$lcore" == "-1" ] && break
        if [ -e "/sys/devices/system/cpu/cpu${lcore}/cpufreq" ]; then
		echo 5 > /sys/devices/system/cpu/cpu${lcore}/sched_mostly_idle_nr_run
		echo 60 > /sys/devices/system/cpu/cpu${lcore}/sched_mostly_idle_load
		echo 960000 > /sys/devices/system/cpu/cpu${lcore}/sched_mostly_idle_freq
		echo 0 > /sys/devices/system/cpu/cpu${lcore}/sched_prefer_idle
		break
        fi
done

# ensure at least one big core is online
bcores=( 4 5 6 7 -1 )
# tune governors for big cores
for bcore in ${bcores[@]}; do
        [ "$bcore" == "-1" ] && break
        if [ -e "/sys/devices/system/cpu/cpu${bcore}/cpufreq" ]; then
		echo 3 > /sys/devices/system/cpu/cpu${bcore}/sched_mostly_idle_nr_run
		echo 20 > /sys/devices/system/cpu/cpu${bcore}/sched_mostly_idle_load
		echo 0 > /sys/devices/system/cpu/cpu${bcore}/sched_mostly_idle_freq
		echo 0 > /sys/devices/system/cpu/cpu${bcore}/sched_prefer_idle
        break
        fi
done

