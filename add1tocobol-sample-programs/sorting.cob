      *>>SOURCE FORMAT IS FIXED
      ******************************************************************
      * Author:    Brian Tiffin
      * Date:      02-Sep-2008
      * Rights:    Copyright (c) 2008, Brian Tiffin.  Licensed LGPL.
      * Purpose:   An OpenCOBOL SORT verb example
      * Tectonics: cobc -x sorting.cob
      *     ./sorting <input >output
      *   or simply 
      *     ./sorting
      *   for keyboard and screen demos 
      ******************************************************************
       identification division.
       program-id. sorting.

       environment division.
       configuration section.
       special-names.
           alphabet mixed is " AabBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTu
      -"UvVwWxXyYzZ0123456789".

       input-output section.
       file-control.
           select sort-in
               assign keyboard
               organization line sequential.
           select sort-out
               assign display
               organization line sequential.
           select sort-work
               assign "sortwork".

       data division.
       file section.
       fd sort-in.
          01 in-rec        pic x(255).
       fd sort-out.
          01 out-rec       pic x(255).
       sd sort-work.
          01 work-rec      pic x(255).

       working-storage section.
       01 loop-flag        pic 9 value low-value.

       procedure division.
       sort sort-work
           on descending key work-rec
           collating sequence is mixed
           using  sort-in
      *    input procedure is sort-transform
           giving sort-out.
      *    output procedure is output-uppercase.

       display sort-return end-display.
       goback.

      ******************************************************************
       sort-transform.
       move low-value to loop-flag
       open input sort-in
       read sort-in
           at end move high-value to loop-flag
       end-read
       perform
           until loop-flag = high-value
               move FUNCTION LOWER-CASE(in-rec) to work-rec
               release work-rec
               read sort-in
                   at end move high-value to loop-flag
               end-read
       end-perform
       close sort-in
       .

      ******************************************************************
       output-uppercase.
       move low-value to loop-flag
       open output sort-out
       return sort-work
           at end move high-value to loop-flag
       end-return
       perform
           until loop-flag = high-value
               move FUNCTION UPPER-CASE(work-rec) to out-rec
               write out-rec end-write
               return sort-work
                   at end move high-value to loop-flag
               end-return
       end-perform
       close sort-out
       .

       exit program.
       end program sorting.

