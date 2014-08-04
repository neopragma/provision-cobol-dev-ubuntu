       >>SOURCE FORMAT IS FIXED
      *> ***************************************************************
      *> Author:    Brian Tiffin
      *> Date:      01-Jul-2008
      *> Purpose:   Demonstrate the usage of OpenCOBOL call library
      *>            C$JUSTIFY, C$TOUPPER, C$TOLOWER
      *> Tectonics: Using OC1.1 post 02-Jul-2008, cobc -x -Wall
      *> History:   02-Jul-2008, updated to remove warnings
      *> ***************************************************************
       identification division.
       program-id. justify.

       environment division.
       configuration section.
       source-computer. IBMPC.
       object-computer. IBMPC.

       data division.
       WORKING-STORAGE section.
       01 source-str           pic x(80)
           value "    this is a test of the internal voice communication
      - " system".
       01 just-str             pic x(80).
       01 justification        pic x.
       01 result               pic s9(9) comp-5.

       procedure division.
       move source-str to just-str.

      *> Left justification
       move "L" to justification.
       perform demonstrate-justification.

      *> case change to upper, demonstrate LENGTH verb
       call "C$TOUPPER" using just-str
                            by value length just-str
                        returning result
       end-call.

      *> Centre
       move "C" to justification.
       perform demonstrate-justification.

      *> case change to lower
       call "C$TOLOWER" using just-str
                            by value 80
                        returning result
       end-call.

      *> Right, default if no second argument
       call "C$JUSTIFY" using just-str
                        returning result
       end-call.
       move "R" to justification.
       perform show-justification.

       exit program.
       stop run.

      *> ***************************************************************
       demonstrate-justification.
       call "C$JUSTIFY" using just-str
                            justification
                        returning result
       end-call
       if result not equal 0 then
           display "Problem: " result end-display
           stop run
       end-if
       perform show-justification
       .

      *> ***************************************************************
       show-justification.
       evaluate justification
           when "L"   display "Left justify" end-display
           when "C"   display "Centred (in UPPERCASE)" end-display
           when other display "Right justify" end-display
       end-evaluate
       display "|" source-str "|" end-display
       display "|" just-str "|" end-display
       display space end-display
       .
