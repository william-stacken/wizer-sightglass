#!/usr/bin/env gnuplot

result_folder = "_results/latest"
targets = "__compilation __instantiation __execution __full_compilation __full_instantiation"
titles = "Compilation Instantiation Execution \"TTI from Compilation\" \"TTI from Instantiation\""

set terminal pngcairo dashed
set datafile separator ","
set fit logfile '/dev/null'

set xlabel "CPU Cycles (Baseline)"
set ylabel "CPU Cycles (Pre-initialized)"
set xrange [0:]
set yrange [0:]
set key left top
set size square

csv_get_cell(row,col,filename) = system('awk -F, ''{if (NR == '.row.') print $'.col.'}'' '.filename.'')
sightglass_arch(filename) = csv_get_cell(1,1,filename)
sightglass_engine(filename) = csv_get_cell(1,2,filename)
#sightglass_benchmark(filename) = csv_get_cell(1,3,filename)
sightglass_metric(filename) = csv_get_cell(1,5,filename)

do for [i=1:words(targets)] {
    target = sprintf("%s/%s", result_folder, word(targets, i))
    target_csv = sprintf("%s.csv", target)
    bestfit(x) = b*x

    set title sprintf("%s %s on %s", sightglass_engine(target_csv), sightglass_metric(target_csv), sightglass_arch(target_csv))
    set output target.'.png'

    fit bestfit(x) target.'.csv' using 9:14 via b
    plot x notitle linecolor rgb "#DDDDDD", \
        bestfit(x) title sprintf("%fx", b) dashtype 2 linetype 1 linecolor rgb "#4444DD", \
        target_csv using 9:14:10:15 with xyerrorbars title word(titles, i), \
        '' using 9:14:3 with labels offset 0,2 notitle
}
