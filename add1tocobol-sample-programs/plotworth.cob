       >>SOURCE FORMAT IS FIXED
      ******************************************************************
      * Author:    Brian Tiffin
      * Date:      29-July-2008 
      * Purpose:   Plot trig and a random income/expense/worth report 
      * Tectonics: requires access to gnuplot. http://www.gnuplot.info
      *            cobc -Wall -x plotworth.cob
      *     OVERWRITES ocgenplot.gp and ocgpdata.txt
      ******************************************************************
       identification division.
       program-id. plotworth.

       environment division.
       input-output section.
       file-control.
           select scriptfile
               assign to "ocgenplot.gp"
               organization is line sequential.
           select outfile
               assign to "ocgpdata.txt"
               organization is line sequential.
           select moneyfile
               assign to "ocgpdata.txt"
               organization is line sequential.

       data division.
       file section.
       fd scriptfile.
          01 gnuplot-command pic x(82).
       fd outfile.
          01 outrec.
             03 x-value   pic -zzzzzz9.99.
             03 filler    pic x.
             03 sin-value pic -zzzz9.9999.
             03 filler    pic x.
             03 cos-value pic -zzzz9.9999.
       fd moneyfile.
          01 moneyrec.
             03 timefield pic 9(8).
             03 filler    pic x.
             03 income    pic -zzzzzz9.99.
             03 filler    pic x.
             03 expense   pic -zzzzzz9.99.
             03 filler    pic x.
             03 networth  pic -zzzzzz9.99.

       working-storage section.
       01 angle   pic s9(7)v99.

       01 dates   pic 9(8).
       01 days    pic s9(9).
       01 worth   pic s9(9).
       01 amount  pic s9(9).

       01 gplot   pic x(80) value is 'gnuplot -persist ocgenplot.gp'. 
       01 result  pic s9(9).

       procedure division.

      * Create the script to plot sin and cos
       open output scriptfile.
       move "plot 'ocgpdata.txt' using 1:2 with lines title 'sin(x)'"
      - to gnuplot-command.
       write gnuplot-command.
       move "replot 'ocgpdata.txt' using 1:3 with lines title 'cos(x)'"
      - to gnuplot-command.
       write gnuplot-command.
       close scriptfile.
      
      * Create the sinoidal data
       open output outfile.
       move spaces to outrec.
       perform varying angle from -10 by 0.01
           until angle > 10
               move angle to x-value
               move function sin(angle) to sin-value
               move function cos(angle) to cos-value
               write outrec
       end-perform.
       close outfile.

      * Invoke gnuplot
       call "SYSTEM" using gplot
                     returning result.
       if result not = 0
           display "Problem: " result
           stop run returning result
       end-if.

      * Generate script to plot the random networth
       open output scriptfile.
       move "set xdata time" to gnuplot-command.
       write gnuplot-command.
       move 'set timefmt "%Y%m%d"' to gnuplot-command.
       write gnuplot-command.
       move 'set format x "%m"' to gnuplot-command.
       write gnuplot-command.
       move 'set title "Income and expenses"' to gnuplot-command.
       write gnuplot-command.
       move 'set xlabel "2008 / 2009"' to gnuplot-command.
       write gnuplot-command.
       move 'plot "ocgpdata.txt" using 1:2 with boxes title "Income"
      -' linecolor rgb "green"' to gnuplot-command.
       write gnuplot-command.
       move 'replot "ocgpdata.txt" using 1:3 with boxes title "Expense"
      -' linecolor rgb "red"' to gnuplot-command.
       write gnuplot-command.
       move 'replot "ocgpdata.txt" using 1:4 with lines title "Worth"'
      -    to gnuplot-command.
       write gnuplot-command.
       close scriptfile.

      * Generate a bi-weekly dataset with date, income, expense, worth
       open output moneyfile.
       move spaces to moneyrec.
       move function integer-of-date(20080601) to dates.
       move function random(0) to amount.

       perform varying days from dates by 14
           until days > dates + 365
               move function date-of-integer(days) to timefield
               compute amount = function random() * 2000
               compute worth = worth + amount
               move amount to income
               compute amount  = function random() * 1800
               compute worth = worth - amount 
               move amount to expense
               move worth to networth
               write moneyrec
       end-perform.
       close moneyfile.

      * Invoke gnuplot again.  Will open new window.
       call "SYSTEM" using gplot
                     returning result.
       if result not = 0
           display "Problem: " result
           stop run returning result
       end-if.

       goback.
