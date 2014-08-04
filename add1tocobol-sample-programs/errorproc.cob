       >>SOURCE FORMAT IS FIXED
      *****************************************************************
      * OpenCOBOL demonstration
      * Author:  Brian Tiffin
      * Date:    26-Jun-2008
      * History:
      *     03-Jul-2008
      *     Updated to compile warning free according to standards
      * Purpose:
      *     CBL_ERROR_PROC and CBL_EXIT_PROC call example
      *     CBL_ERROR_PROC installs or removes run-time error procedures
      *     CBL_EXIT_PROC installs or removes exit handlers
      *     Also demonstrates the difference between Run time errors
      *     and raised exceptions.  Divide by zero is raises an
      *     exception, it does not cause a run time error.
      * NB:
      *     Please be advised that this example uses the functional but
      *     now obsolete ENTRY verb.  Compiling with -Wall will display
      *     a warning.  No warning will occur using -std=MF
      * Tectonics: cobc -x errorproc.cob
       identification division.
       program-id. error_exit_proc.

       data division.
       working-storage section.
      * entry point handlers are procedure addresses 
       01  install-address   usage is procedure-pointer.
       01  install-flag      pic 9 comp-x value 0.
       01  status-code       pic s9(9) comp-5.

      * exit handler address and priority (prio is IGNORED with OC1.1)
       01  install-params.
           02 exit-addr      usage is procedure-pointer.
           02 handler-prio   pic 999 comp-x.

      * indexing variable for back scannning error message strings
       01  ind               pic s9(9) comp-5.

      * work variable to demonstrate raising exception, not RTE
       01  val               pic 9.

      * mocked up error procedure reentrancy control, global level
       01  once              pic 9 value 0.
           88 been-here            value 1.

      * mocked up non-reentrant value
       01  global-value      pic 99 value 99.

      * LOCAL-STORAGE SECTION comes into play for ERROR_PROCs that
      *   may themselves cause run-time errors, handling reentry. 
       local-storage section.
       01  reenter-value     pic 99 value 11.

      * Linkage section for the error message argument passed to proc
      * By definition, error messages are 325 alphanumeric
       linkage section.
       01  err-msg           pic x(325).

      * example of OpenCOBOL error and exit procedures
       procedure division.

      * Demonstrate problem installing procedure
      * get address of WRONG handler.  NOTE: Invalid address
       set exit-addr to entry "nogo-proc".

      * flag: 0 to install, 1 to remove
       call "CBL_EXIT_PROC" using install-flag
                                  install-params
                            returning status-code
       end-call.
      * status-code 0 on success, in this case expect error.
       if status-code not = 0
           display
               "Intentional problem installing EXIT PROC"
               ", Status: " status-code
           end-display
       end-if.

      * Demonstrate install of an exit handler
      * get address of exit handler
       set exit-addr to entry "exit-proc".

      * flag: 0 to install, 1 to remove
       call "CBL_EXIT_PROC" using install-flag
                                  install-params
                            returning status-code
       end-call.
      * status-code 0 on success.
       if status-code not = 0
           display
               "Problem installing EXIT PROC"
               ", Status: " status-code
           end-display
           stop run
       end-if.

      * Demonstrate installation of an error procedure
      * get the procedure entry address
       set install-address to entry "err-proc".

      * install error procedure. install-flag 0 installs, 1 removes
       call "CBL_ERROR_PROC" using install-flag
                                   install-address
                             returning status-code
       end-call.
      * status-code is 0 on success.
       if status-code not = 0
           display "Error installing ERROR PROC" end-display
           stop run
       end-if.

      * example of error that raises exception, not a run-time error
       divide 10 by 0 giving val end-divide.
      * val will be a junk value, use at own risk

       divide 10 by 0 giving val
           on size error display "DIVIDE BY ZERO Exception" end-display
       end-divide.

      * intentional run-time error
       call "erroneous" end-call.           *> ** Intentional error **

      * won't get here.  RTS error handler will stop run
       display
           "procedure division, following run-time error"
       end-display.
       display 
           "global-value: " global-value
           ", reenter-value: " reenter-value
       end-display.

       exit program.
      *****************************************************************

      *****************************************************************
      * Programmer controlled Exit Procedure:
       entry "exit-proc".

       display
           "**Custom EXIT HANDLER (will pause 3 and 0.5 seconds)**"
       end-display.

      * sleep for 3 seconds
       call "C$SLEEP" using "3" end-call.
      * demonstrate nanosleep; argument in billionth's of seconds
      *   Note: also demonstrates OpenCOBOL's compile time
      *         string catenation using ampersand;
      *         500 million being one half second
       call "CBL_OC_NANOSLEEP" using "500" & "000000" end-call.

       exit program.

      *****************************************************************
      * Programmer controlled Error Procedure:
       entry "err-proc" using err-msg.

       display "**ENTER error procedure**" end-display.

      * These lines are to demonstrate local and working storage
       display 
           "global-value: " global-value
           ", reenter-value: " reenter-value
       end-display.
      * As reenter-value is local-storage
      *  the 77 will NOT display on rentry, while the global 66 will
       move 66 to global-value.
       move 77 to reenter-value.

      * Process err-msg.
      * Determine Length of error message, looking for null terminator
       perform varying ind from 1 by 1
           until (err-msg(ind:1) = x"00") or (ind = length of err-msg)
               continue
       end-perform.
       display err-msg(1:ind) end-display.

      * demonstrate trapping an error caused in error-proc
       if not been-here then
           set been-here to true 
           display "Cause error while inside error-proc" end-display
           call "very-erroneous" end-call        *> Intentional error
       end-if.

      * In OpenCOBOL 1.1, the return-code is local and does
      *   not influence further error handlers
      *move 1 to return-code.
       move 0 to return-code.

       display "**error procedure EXIT**" end-display.

       exit program.
