#!/usr/bin/env gnuplot

# https://gnuplot.sourceforge.net/demo_5.2/nonlinear1.html

result_folder = "_results/latest"
targets = "__full_compilation"
titles = "\"CPTI from Compilation\""

tick_number=50
X_min=0
X_max=1.7E7
X_break=1.36E6
X_unbreak=1.6E7
X_axis_gap=8E4
X_delta=(X_max-X_min) / tick_number
Y_min=X_min
Y_max=X_max
Y_break=X_break
Y_unbreak=X_unbreak
Y_axis_gap=X_axis_gap
Y_delta=(Y_max-Y_min) / tick_number

fx(x) = (x <= X_break) ? x : (x < X_unbreak) ? NaN : (x - (X_unbreak - X_break) + X_axis_gap)
gx(x) = (x <= X_break) ? x : (x < X_break + X_axis_gap) ? NaN : (x + (X_unbreak - X_break) - X_axis_gap)

fy(y) = (y <= Y_break) ? y : (y < Y_unbreak) ? NaN : (y - (Y_unbreak - Y_break) + Y_axis_gap)
gy(y) = (y <= Y_break) ? y : (y < Y_break + Y_axis_gap) ? NaN : (y + (Y_unbreak - Y_break) - Y_axis_gap)

set nonlinear x via fx(x) inverse gx(x)
set nonlinear y via fy(y) inverse gy(y)

set terminal pngcairo dashed noenhanced
set datafile separator ","
set fit logfile '/dev/null'

set xlabel "CPU Cycles (Baseline)"
set ylabel "CPU Cycles (Pre-initialized)"

set xrange [X_min:X_max] noreverse writeback
set xtics rotate by -90 nomirror
set xtics X_delta

set yrange [Y_min:Y_max] noreverse writeback
set ytics Y_delta

set key left top
set size square

set arrow 10 from X_break, 0, 0 to X_unbreak, 0, 0 nohead front nofilled linecolor -3 linewidth 2.000 dashtype solid
set arrow 11 from X_break, 0, 0 length graph 0.01 angle 50 nohead front nofilled linewidth 2.000 dashtype solid
set arrow 12 from X_break, 0, 0 length graph -0.01 angle 50 nohead front nofilled linewidth 2.000 dashtype solid
set arrow 13 from X_unbreak, 0, 0 length graph 0.01 angle 50 nohead front nofilled linewidth 2.000 dashtype solid
set arrow 14 from X_unbreak, 0, 0 length graph -0.01 angle 50 nohead front nofilled linewidth 2.000 dashtype solid

set arrow 20 from 0, Y_break, 0 to 0, Y_unbreak, 0 nohead front nofilled linecolor -3 linewidth 2.000 dashtype solid
set arrow 21 from 0, Y_break, 0 length graph 0.01 angle 50 nohead front nofilled linewidth 2.000 dashtype solid
set arrow 22 from 0, Y_break, 0 length graph -0.01 angle 50 nohead front nofilled linewidth 2.000 dashtype solid
set arrow 23 from 0, Y_unbreak, 0 length graph 0.01 angle 50 nohead front nofilled linewidth 2.000 dashtype solid
set arrow 24 from 0, Y_unbreak, 0 length graph -0.01 angle 50 nohead front nofilled linewidth 2.000 dashtype solid

csv_get_cell(row,col,filename) = system('awk -F, ''{if (NR == '.row.') print $'.col.'}'' '.filename.'')
sightglass_arch(filename) = csv_get_cell(1,1,filename)
sightglass_engine(filename) = csv_get_cell(1,2,filename)
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
