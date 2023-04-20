# set terminal pngcairo  transparent enhanced font "arial,10" fontscale 1.0 size 600, 400 
# set output 'nonlinear1.1.png'
set border 3 front lt black linewidth 1.000 dashtype solid
unset key

X_break=100
X_unbreak=500
axis_gap = 25.0

set arrow 500 from X_break, graph 0, 0 to X_unbreak, graph 0, 0 nohead front nofilled linecolor -3 linewidth 2.000 dashtype solid
set arrow 501 from X_break, graph 0, 0 length graph 0.01 angle 75 nohead front nofilled linewidth 2.000 dashtype solid
set arrow 502 from X_break, graph 0, 0 length graph -0.01 angle 75 nohead front nofilled linewidth 2.000 dashtype solid
set arrow 503 from X_unbreak, graph 0, 0 length graph 0.01 angle 75 nohead front nofilled linewidth 2.000 dashtype solid
set arrow 504 from X_unbreak, graph 0, 0 length graph -0.01 angle 75 nohead front nofilled linewidth 2.000 dashtype solid
set style increment default
set style data lines
set xtics border in scale 1,0.5 nomirror rotate by -90  autojustify
set xtics  norangelimit 50
set ytics border in scale 1,0.5 nomirror norotate  autojustify
set title "A 'broken' x axis can be defined using 'set nonlinear x'" 
set xrange [ 15.0000 : 600.000 ] noreverse writeback
set autoscale xfixmin
set autoscale xfixmax
set x2range [ * : * ] noreverse writeback
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
set nonlinear x via f(x) inverse g(x) 
f(x) = (x <= X_break) ? x : (x < X_unbreak) ? NaN : (x - (X_unbreak - X_break) + axis_gap)
g(x) = (x <= X_break) ? x : (x < X_break + axis_gap) ? NaN : (x + (X_unbreak - X_break) - axis_gap)
## Last datafile plotted: "silver.dat"
plot 'silver.dat' with yerrorbars lw 2, '' with lines
