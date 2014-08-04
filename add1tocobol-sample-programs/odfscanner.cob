       >>source format is free
*>*********************************************************************
*> Author:    jrls (John Ellis)
*> Date:      Feb-2009
*> Purpose:   This program scans a file that uses Open Document Format
*>            creating the odfscannerb.data file which can be used for 
*>            random access in the later subprograms..  
*>*********************************************************************
identification division.
program-id. odfscanner.
*>.
environment division.
*>
input-output section.
*>
file-control.
*>
select odffile		assign to "$odffile"
                        organization is sequential.

select odffile2		assign to "odfscanned.data"
                        access random
                        organization relative
                        relative key is odfreckey.
*>
data division.
*>
file section.
*>
fd odffile.
*>
01 odfchar			pic x value spaces.
*>
fd odffile2.
*>
01 odfchar2			pic x value spaces.
*>
working-storage section.
*>
 01  eof			pic x value spaces.
     88  end-of-file		      value "y".
 01  odfreckey			unsigned-int value zero.
 01  charcount			unsigned-int value zero.
 01  tbbletag.
     05  tbchar occurs 14 times pic x value spaces.
 01  tbsub			unsigned-int value zero.
 01  sheetname.
     05                         pic x(7)  value "invoice".
     05  sninv                  pic 9(3)  value zero.
 01  fieldtag.
     05  ftchar	occurs 100 times pic x value spaces.
 01  ftsub			unsigned-int value zero.
 01  tagsw 			pic x value spaces.
     88  taginfld		value "f".
     88  intag			value "y".
 01  fnlength			unsigned-int value zero.
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*>external field list table
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 01  fieldlist external.
     05  flCount 		unsigned-int.
     05  flTable      occurs 1 to 200
                      depending on flCount
                      indexed by flInd.
         10  flField  		pic x(20).
         10  flFieldOccur	unsigned-int.
         10  flValue            pic x(100).
         10  flValueSet 	pic x.
         10  flStart		unsigned-int.
         10  flEnd		unsigned-int.
*>
linkage section.
*>
 01  startpage			unsigned-int value zero.
 01  endpage			unsigned-int value zero.
*>
 procedure division		using startpage,
				      endpage.
*>
 0000-start.
*>
     open input odffile
          output odffile2.

     move 0			to flCount.
     set flInd			to 1.

     perform until end-of-file
         read odffile
              at end
                 move "y"	to eof
         end-read
         if not end-of-file
            add 1		to charcount
            move charcount	to odfreckey
            write odfchar2 from odfchar
            perform varying tbsub from 1 by 1
                    until tbsub > 13
                move tbchar(tbsub + 1) to tbchar(tbsub)
            end-perform
            move odfchar	to tbchar(14)
            if tbbletag(1:13) = "<table:table "
               compute startpage = charcount - 13
            end-if
            if tbbletag = "</table:table>"
               move charcount	to endpage
            end-if
            if startpage > 0 and endpage = 0  
               perform 0100-getfields
            end-if
         end-if
     end-perform.

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*>cleanup fieldnames
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     perform varying flInd from 1 by 1
             until flInd > flCount
         compute fnlength = function length(function trim(flField(flInd)))
         subtract 1		from fnlength
         move flField(flInd)(1:fnlength) to fieldtag
         move spaces		to flField(flInd)
         string function trim(fieldtag),
                "]" 
                into flField(flInd)
         end-string
     end-perform.

     close odffile
           odffile2.

     goback.
*>
 0100-getfields.
*>
     if fieldtag = spaces
        if odfchar = "<"
           move "y"		to tagsw
        else if odfchar = ">"
           move spaces		to tagsw
        end-if
     end-if.
     
     if not intag
        if odfchar = "[" 
           move 1 		to ftsub
           move odfchar		to ftchar(ftsub)
           move charcount	to flStart(flInd)
        else if odfchar = "]"
           add 1		to ftsub
           move odfchar		to ftchar(ftsub)
           add 1		to flCount
           move fieldtag	to flField(flInd)
           move charcount	to flEnd(flInd)
           set flInd		up by 1
           move spaces		to fieldtag
        end-if
     end-if.

     if fieldtag <> spaces and odfchar <> "["
        if odfchar = "<"
           move "f"		to tagsw
           subtract 1 		from ftsub
        end-if
        if not taginfld
           add 1		to ftsub
           move odfchar		to ftchar(ftsub)
        end-if
        if odfchar = ">"
           move spaces		to tagsw
        end-if
     end-if.

end program odfscanner.
*>*********************************************************************
*> Author:    jrls (John Ellis)
*> Date:      Feb-2009
*> Purpose:   Subprogram to update fieldvalue in fieldlist table.
*>*********************************************************************
identification division.
program-id. odfsetfield.
*>.
environment division.
*>
input-output section.
*>
file-control.
*>
data division.
*>
file section.
*>
working-storage section.
*>
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*>external field list table
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 01  fieldlist external.
     05  flCount 		unsigned-int.
     05  flTable      occurs 1 to 200
                      depending on flCount
                      indexed by flInd.
         10  flField  		pic x(20).
         10  flFieldOccur	unsigned-int.
         10  flValue            pic x(100).
         10  flValueSet 	pic x.
         10  flStart		unsigned-int.
         10  flEnd		unsigned-int.
*>
 01  searchField		pic x(20) value spaces.
*>
linkage section.
*>
 01  fieldName			pic x(18).
 01  fieldValue			pic x(100).
 01  retCode			unsigned-int.
*>
 procedure division using fieldName,
                          fieldValue
                          retCode.
*>
 0000-start.
*>
     move 10			to retCode.
     initialize	searchfield.
     string "[", function trim(fieldName) , "]" 
            into searchField.
     display function trim(fieldName) "=" function trim(fieldValue).
     perform varying flInd from 1 by 1
             until flInd > flCount or retCode = 0
         if searchField = flField(flInd)
            if flValueSet(flInd) = "y"
               move 12		to retCode
            else
               move fieldValue	to flValue(flInd)
               move "y"		to flValueSet(flInd)
               move zero	to retCode
            end-if
         end-if
     end-perform.
              
end program odfsetfield.
*>*********************************************************************
*> Author:    jrls (John Ellis)
*> Date:      Feb-2009
*> Purpose:   This program starts the open document from odfscannerb.data.
*>*********************************************************************
identification division.
program-id. odfstartform.
*>.
environment division.
*>
input-output section.
*>
file-control.
*>
select odffile		assign to "odfscanned.data"
                        access sequential
                        organization relative
                        relative key is odfreckey.

select odfform		assign to "$odfform"
                        organization sequential.
*>
data division.
*>
file section.
*>
fd odffile.
*>
01 odfchar			pic x value spaces.
*>
fd odfform.
*>
01 odfformchar			pic x value spaces.
*>
working-storage section.
*>
 01  eof			pic x value spaces.
     88  end-of-file		      value "y".
 01  odfreckey			unsigned-int value 1.
*>
linkage section.
*>
 01  startpage			unsigned-int.
*>
 procedure division using startpage.
*>
 0000-start.
*>
     open input   odffile
          output  odfform.
 
     perform until odfreckey = startpage
         read odffile 
              at end
                  move "y"	to eof
         end-read 
         add 1			to odfreckey
         write odfformchar 	from odfchar
     end-perform.

     close odffile
           odfform.

     goback.
         
end program odfstartform.

*>*********************************************************************
*> Author:    jrls (John Ellis)
*> Date:      Feb-2009
*> Purpose:   This program writes 1 page from odfscannerb.data.
*>*********************************************************************
identification division.
program-id. odfwritepage.
*>.
environment division.
*>
input-output section.
*>
file-control.
*>
select odffile		assign to "odfscanned.data"
                        access random
                        organization relative
                        relative key is odfreckey.

select odfform		assign to "$odfform"
                        organization sequential.
*>
data division.
*>
file section.
*>
fd odffile.
*>
01 odfchar			pic x value spaces.
*>
fd odfform.
*>
01 odfformchar			pic x value spaces.
*>
working-storage section.
*>
 01  odfreckey			unsigned-int value zero.
 01  sub1			unsigned-int.
 01  tabletag.
     05  ttag 			occurs 24 times pic x value spaces.
 01  formValue.
     05  formVchar occurs 100 times indexed by formVind
                                pic x.
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*>external field list table
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 01  fieldlist external.
     05  flCount 		unsigned-int.
     05  flTable      occurs 1 to 200
                      depending on flCount
                      indexed by flInd.
         10  flField  		pic x(20).
         10  flFieldOccur	unsigned-int.
         10  flValue		pic x(100).
         10  flValueSet 	pic x.
         10  flStart		unsigned-int.
         10  flEnd		unsigned-int.
*>
linkage section.
*>
 01  startpage			unsigned-int.
 01  endpage			unsigned-int.
 01  sheetname.
    05  snamechar occurs 10 times pic x.
*>
 procedure division using startpage,
                          endpage,
			  sheetname.
*>
 0000-start.
*>
     open input   odffile
          extend  odfform.

     perform varying flInd from 1 by 1
             until flInd > flCount
        if flValueSet(flInd) = spaces
	   move spaces		to flValue(flInd)
	end-if
     end-perform.

     move startpage		to odfreckey.
     set flInd			to 1.

     perform until odfreckey > endpage
         read odffile 
              key odfreckey
                  invalid key display odfreckey " is bad key."
         end-read
         perform varying sub1 from 1 by 1
                 until sub1 > 23
             move ttag(sub1 + 1) to ttag(sub1)
         end-perform
         move odfchar	to ttag(24)
         if odfreckey >= flStart(flInd) and odfreckey <= flEnd(flInd)
            move function trim(flValue(flInd))	to formValue
            if flValueSet(flInd) = "y"
               perform varying formVind from 1 by 1
                       until formVind > function length(function trim(flValue(flInd)))
                  write odfformchar from formVchar(formVind)
               end-perform
            end-if
            compute odfreckey = flEnd(flInd) + 1
            if flInd < flCount
               set flInd	up by 1
            end-if
         else
            add 1		to odfreckey
            write odfformchar 	from odfchar
         end-if

         if tabletag = "<table:table table:name="
            write odfformchar from '"'
            perform varying sub1 from 1 by 1
                    until sub1 > function length (function trim(sheetname))
                 write odfformchar from snamechar(sub1)
            end-perform
            write odfformchar from '"'
            add 8		to odfreckey
         end-if
     end-perform.

     perform varying flInd from 1 by 1
             until flInd > flCount
        move spaces		to flValue(flInd)
	move spaces		to flValueSet(flInd)
     end-perform.

     close odffile
           odfform.

     goback.

end program odfwritepage.
*>*********************************************************************
*> Author:    jrls (John Ellis)
*> Date:      Feb-2009
*> Purpose:   This program writes the end of the form.
*>*********************************************************************
identification division.
program-id. odffinishform.
*>.
environment division.
*>
input-output section.
*>
file-control.
*>
select odffile		assign to "odfscanned.data"
                        access random
                        organization relative
                        status odfstat
                        relative key is odfreckey.

select odfform		assign to "$odfform"
                        organization sequential.
*>
data division.
*>
file section.
*>
fd odffile.
*>
01 odfchar			pic x value spaces.
*>
fd odfform.
*>
01 odfformchar			pic x value spaces.
*>
working-storage section.
*>
 01  odfstat			pic x(2).
     88  odfok			value "00".
 01  eof			pic x value spaces.
     88  end-of-file		      value "y".
 01  odfreckey			unsigned-int value zero.
*>
linkage section.
*>
  01  endpage			unsigned-int.
*>
 procedure division using endpage.
*>
 0000-start.
*>
     open input   odffile
          extend  odfform.

     compute odfreckey = endpage + 1.

     perform until not odfok
         read odffile 
              key odfreckey
                  invalid key display odfreckey " is bad key."
         end-read 
         add 1			to odfreckey
         if odfok
            write odfformchar 	from odfchar
         end-if
     end-perform.

     close odffile
           odfform.

     goback.
         
end program odffinishform.
