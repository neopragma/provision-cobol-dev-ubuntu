      *>>SOURCE FORMAT IS FIXED
      *> ***************************************************************
      *> Author:    Brian Tiffin 
      *> Date:      22-Oct-2008 
      *> Purpose:   Test the OCDUMP routine 
      *> Tectonics: cobc -x ocdump.cob
      *> ***************************************************************
       identification division.
       program-id. testdump.

       data division.
       local-storage section.
       01 buffer               pic x(64).
       01 int                  usage binary-long value 123.
       01 addr                 usage pointer.

       01 len                  usage binary-long.

      *> **************************************************************
       procedure division.
       move "abcdefghijklmnopqrstuvwxyz0123456789" to buffer
       move function length(buffer) to len

       display "Buffer Dump: " buffer(1:len) end-display
       call "OCDUMP" using buffer len end-call

       display "Alpha literal Dump" end-display
       move 17 to len
       call "OCDUMP" using "abcdefghijklmopqr" len end-call

       display "Integer Dump: " int end-display
       move function byte-length(int) to len
       call "OCDUMP" using int len end-call

       display "Numeric Literal Dump: " 0 end-display
       move function byte-length(0) to len
       call "OCDUMP" using 0 len end-call

       display "Hex Literal Dump" end-display
       call "OCDUMP" using x"f5f5f5f5" 4 end-call

       set addr to address of buffer
       display "Pointer Dump: " addr end-display
       call "OCDUMP" using addr function byte-length(addr) end-call 

       goback.
       end program testdump.
      *> **************************************************************
       
      *>>SOURCE FORMAT IS FIXED
      *> ***************************************************************
      *> Author:    Brian Tiffin     
      *> Date:      20-Oct-2008 
      *> Purpose:   Hex Dump display 
      *> Tectonics: cobc -c ocdump.cob
      *> ***************************************************************
       identification division.
       program-id. OCDUMP.

       data division.
       local-storage section.
       01 counter                         usage binary-long.
       01 byline                          usage binary-long.
       01 current                         usage binary-long.
       01 offset               pic 9999   usage computational-5.
       01 byte                 pic x      based.
       01 datum                pic 999    usage computational-5.
       01 high                 pic 99     usage computational-5.
       01 low                  pic 99     usage computational-5.
       01 lins                 pic 9999   usage computational-5.
       01 colu                 pic 99     usage computational-5.

       01 char-table           pic x(256) value
           '................................' &
          x'202122232425262728292a2b2c2d2e2f' &
          x'303132333435363738393a3b3c3d3e3f' &
          x'404142434445464748494a4b4c4d4e4f' &
          x'505152535455565758595a5b5c5d5e5f' &
          x'606162636465666768696a6b6c6d6e6f' &
          x'707172737475767778797a7b7c7d7e7f' &
           '................................' &
           '................................' &
           '................................' &
           '................................'. 
       01 dots                 pic x(16)  value '................'.
       01 show                 pic x(16).

       01 hex.
          02 high-hex          pic x.
          02 low-hex           pic x.
       01 hex-digit            pic x(16)  value '0123456789abcdef'.

       linkage section.
       01 buffer               pic x      any length.
       01 len                             usage binary-long.
      *> **************************************************************
       
       procedure division using buffer len.

       perform varying counter from 1 by 16
           until counter > len
               move counter to offset
               display
                   offset space space with no advancing
               end-display
               move dots to show
               perform varying byline from 0 by 1
                   until byline > 15
                       add counter to byline giving current end-add
                       if current > len
                           display
                               space space space with no advancing
                           end-display
                       else
                           set address of byte to
                               address of buffer(current:1)
                           compute
                               datum = function ord(byte) - 1
                           end-compute
                           divide
                               datum by 16 giving high remainder low
                           end-divide
                           move hex-digit(high + 1:1) to high-hex
                           move hex-digit(low + 1:1) to low-hex
                           move char-table(datum + 1:1)
                               to show(byline + 1:1)
                           display
                               hex space with no advancing
                           end-display
                       end-if
               end-perform
               display space space show end-display
       end-perform
       display "" end-display

       goback.
       end program OCDUMP.
