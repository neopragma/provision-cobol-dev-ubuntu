       >>SOURCE FORMAT IS FREE
*> *********************************************************************
*> Author:    Brian Tiffin
*> Date:      19-July 2008      
*> Purpose:   Play with SYSTEM CALL
*> Tectonics: cobc -x systemcall.cbl
*>            easily broken, ./systemcall vi   would probably do.
identification division.
program-id. systemcall.
environment division.
input-output section.
file-control.
    select optional pipefile
    assign to tmpfile
    organization is line sequential.
    
    select optional sortfile
    assign to tmpfile
    organization is line sequential.

data division.
file section.
fd pipefile.
   01 pipedata     pic x(80).

sd sortfile.
   01 sort-record  pic x(80).
     
working-storage section.

01 pipestatus      pic 9.
   88 endofpipe        value high-values.
01 stat            pic s9(9).
01 commands        pic x(256).
01 arguments       pic x(241).

01 tmpfile         pic x(1024).

*> redirect a system call to a temp file and display results
procedure division.

accept arguments from command-line end-accept.
if arguments equal spaces
    move "ls" to arguments
end-if.

call "tmpnam" using tmpfile
              returning stat
end-call.

if stat = 0
    display "tmpnam: |" stat "|" end-display
end-if.

string function trim(arguments trailing) delimited by size 
       " > " delimited by size
       tmpfile delimited by space 
       low-value delimited by size
       into commands
end-string.

display "|" function trim(commands trailing) "|" end-display.
call "SYSTEM" using function trim(commands trailing)
    returning stat
end-call.

if stat not = 0
    display "SYSTEM: |" stat "|" end-display
end-if.

*>string
*>    "cat " delimited by size
*>    tmpfile delimited by size
*>    low-value delimited by size
*>    into commands
*>end-string
*>call "SYSTEM" using function trim(commands trailing)
*>    returning stat
*>end-call.

sort sortfile
    on ascending key sort-record
    using pipefile
    giving pipefile.

*>string
*>    "cat " delimited by size
*>    tmpfile delimited by size
*>    low-value delimited by size
*>    into commands
*>end-string
*>call "SYSTEM" using function trim(commands trailing)
*>    returning stat
*>end-call.

open input pipefile.
*>read pipefile
*>   at end move high-values to pipestatus
*>end-read.
*>if pipestatus not equal high-values
*>    display "|"  pipedata "|" end-display
*>end-if.
perform
    until pipestatus = high-values
        read pipefile
            at end move high-values to pipestatus
        end-read
        if pipestatus not = high-values 
            display "|" pipedata "|" end-display
        end-if
end-perform.

close pipefile.

call "remove" using tmpfile returning stat end-call.
if stat not = 0
    display "remove: |" stat "|" end-display
end-if.

goback.

