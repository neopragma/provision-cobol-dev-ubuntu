      *>>SOURCE FORMAT IS FIXED
      *> ***************************************************************
      *> Author:    Brian Tiffin 
      *> Date:      27-Oct-2008 
      *> Purpose:   Find and replace unequal length sub strings
      *> Tectonics: cobc -x ocbcta.cob 
      *> ***************************************************************
       identification division.
       program-id. OCBCTA.

       data division.

       working-storage section.
       01 source-string        pic x(256).
       01 dest                 pic x(256).
       01 fore                 usage binary-long.
       01 aft                  usage binary-long.
       01 source-limit         usage binary-long.
       01 elements             constant as 5.
       01 element              usage binary-long.
       01 finder-table.
          03 filler            pic x(16) value "Bob".
          03 filler            pic x(16) value "Carol".
          03 filler            pic x(16) value "Ted".
          03 filler            pic x(16) value "Alice".
          03 filler            pic x(16) value " and ".
       01 filler redefines finder-table.
          03 finder            pic x(16) occurs elements times.
       01 replacement-table.
          03 filler            pic x(32) value "Carol".
          03 filler            pic x(32) value "Bob".
          03 filler            pic x(32) value "Alice".
          03 filler            pic x(32) value "Tony? Who's Tony?".
          03 filler            pic x(32) value " & ".
       01 filler redefines replacement-table.
          03 replacement       pic x(32) occurs elements times.
       01 rlen                 usage binary-long.
       01 flen                 usage binary-long.
       01 substitute-flag      pic x value low-value.
          88 no-substitution   value low-value.
          88 substitution-occured value high-value.

      *> **************************************************************
       procedure division.

      *> **************************************************************
      *> * This is a very particular usage.  The OC developer should
      *> * have access to a more generic *substitute this for that*
      *> * operation.  Whether it be a copybook performable or a 
      *> * separate callable program.
      *> **************************************************************

       move "Bob and Carol and Ted and Alice" to source-string
       move spaces to dest
       display
           "|" function trim(source-string trailing) "|"
       end-display
       perform find-replace-all
       display
           "|" function trim(dest trailing) "|" end-display
       goback.

      *> **************************************************************
       find-replace-all.
       compute aft = 1 end-compute
       compute fore = 1 end-compute
       compute
           source-limit = function
               length(function trim(source-string trailing))
       end-compute
       perform until fore > source-limit
           set no-substitution to true
           move 1 to element
           perform until element > elements
               perform find-replace-current
               if no-substitution
                   add 1 to element end-add
               end-if
           end-perform
           if no-substitution
               move source-string(fore:1) to dest(aft:1)
               add 1 to fore end-add
               add 1 to aft end-add
           end-if
       end-perform
       exit.

      *> **************************************************************
       find-replace-current.
      *> Bugs abound when it comes to trailing spaces and this compute
       compute
           rlen = function
               length(function trim(replacement(element) trailing))
       end-compute
       compute
           flen = function
                length(function trim(finder(element) trailing))
       end-compute
       if source-string(fore:flen) = finder(element)
           move replacement(element) to dest(aft:rlen)
           add rlen to aft end-add
           add flen to fore end-add
           set substitution-occured to true
           add 1 to elements giving element
       end-if
       exit.
                   
       end program OCBCTA.
