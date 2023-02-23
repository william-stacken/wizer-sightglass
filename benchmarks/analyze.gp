#!/usr/bin/env gnuplot

result_folder = "_results/latest"
targets = "__compilation __instantiation __execution __full_compilation __full_instantiation"
titles = "Compilation Instantiation Execution \"TTI from Compilation\" \"TTI from Instantiation\""

set terminal pngcairo dashed
set datafile separator ","
set fit logfile '/dev/null'

set title "Wasmtime CPU cycles on aarch64"
#set output sprintf("%s/%s", result_folder, "wasmtime_aarch64").'.png'
set xlabel "CPU Cycles (Baseline)"
set ylabel "CPU Cycles (Optimized)"
set xrange [0:]
set yrange [0:]
#set logscale x
#set logscale y
set key left top

#plot x notitle

do for [i=1:words(targets)] {
    target = sprintf("%s/%s", result_folder, word(targets, i))
    bestfit(x) = a + b*x

    set output target.'.png'

    fit bestfit(x) target.'.csv' using 9:14 via a, b
    plot target.'.csv' using 9:14:10:15 with xyerrorbars title word(titles, i), \
        bestfit(x) title sprintf("%fx + %f", b, a), \
        x notitle dashtype 2 linetype 1 linecolor rgb "#999999"
}
