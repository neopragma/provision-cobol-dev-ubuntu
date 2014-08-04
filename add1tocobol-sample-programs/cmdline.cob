       >>source format is free
*>*********************************************************************
*> Author:    jrls (John Ellis)
*> Date:      Nov-2008
*> Purpose:   command line processing
*>*********************************************************************
identification division.
program-id. cmdline.
data division.
*>
working-storage section.
*>******************************************
01 argv			pic x(100) value spaces.
   88 recv		           value "-r", "--recv".
   88 email			   value "-e", "--email".
   88 delivered			   value "-d", "--delivered".
01 cmdstatus		pic x    value spaces.
   88 lastcmd		         value "l".
01 reptinfo.
   05 rept-recv		pic x(30) value spaces.
   05 rept-howsent	pic x(10) value spaces.
*>
procedure division.
 0000-start.
*>
    perform until lastcmd
         move low-values	to argv
         accept argv		from argument-value		
         if argv > low-values
            perform 0100-process-arguments
         else
            move "l"		to cmdstatus
         end-if
    end-perform
    display reptinfo.
    stop run.
*>
 0100-process-arguments.
*>
     evaluate true
         when recv
            if rept-recv = spaces
               accept rept-recv	from argument-value
            else
               display "duplicate " argv
            end-if
         when email
            move "email"	to rept-howsent
         when delivered
            move "delivered"	to rept-howsent
         when other display "invalid switch: " argv
     end-evaluate.
