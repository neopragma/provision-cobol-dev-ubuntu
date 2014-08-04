       >>source format is free
*>*********************************************************************
*> Author:    jrls (John Ellis)
*> Date:      Feb-2009
*> Purpose:   Mysql db schema to open office format spreadsheet(.ods)
*>            
*>*********************************************************************
identification division.
program-id. invoicerep.
*>.
environment division.
*>
input-output section.
*>
file-control.
*>
select dbdata		assign to "dbreportf.data"
                        organization is line sequential.

select repxmlfile	assign to "dbreportx.xml"
                        organization is line sequential.
*>
data division.
*>
file section.
*>
fd dbdata.
*>
01 dbdataRec			pic x(120) value spaces.
*>
fd repxmlfile.
*>
01 repxmlrec			pic x(300) value spaces.
*>
working-storage section.
*>
 01  lastTable			pic x(30) value spaces.
 01  dbSchema.
     05  dbTable		pic x(30) value spaces.
     05  dbFieldName		pic x(30) value spaces.
     05  dbFieldType		pic x(12) value spaces.
     05  dbFieldLength		pic x(10) value spaces.
*>
 01  lowind			index.
 01  highind			index.
 01  reportTable.
     05  rtRows		occurs 200 times
                        indexed by rtrInd.
         10  rtColls	occurs 4 times
                        indexed by rtcInd.
             15  rtrType	pic x value spaces.
             15  rtrTabFldName	pic x(32) value spaces.
             15  rtrFieldType   pic x(12) value spaces.
 01  eof			pic x value spaces.
     88  end-of-file		      value "y".
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*>>>ODS Table statements
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 01  trowstart			pic x(17) value "<table:table-row>".
 01  trowend			pic x(18) value "</table:table-row>".
 01  emptycell			pic x(38) value "<table:table-cell/><table:table-cell/>".
 01  cellStart			pic x(65) value
     '<table:table-cell office:value-type="string" office:string-value='. 
 01  cellStartStyle.
     05  			pic x(18) value " table:style-name=".
     05  cssStyle               pic x(4)  value spaces.
     05                         pic x(2)  value '">'.
 01  textStart			pic x(8)  value "<text:p>".
 01  textEnd                    pic x(9)  value "</text:p>".
 01  cellFinish			pic x(19) value "</table:table-cell>".
 01  headerType			pic x(42) value '<table:table-cell table:style-name="ce2"/>'.
*>
 PROCEDURE DIVISION.
*>
 0000-start.
*>
     open input dbdata
          output repxmlfile.
     
     set lowind			to 1.
     set highind		to 1.
     set rtcInd			to 4.

     perform until end-of-file
         read dbdata
              at end
                 move "y"	to eof
         end-read
         if not end-of-file
            perform 0100-getdata
            perform 0110-loadtable
         else
            set rtrInd		down by 1
            move "F"		to rtrType(rtrInd, rtcInd)
         end-if
     end-perform.

     perform 0130-writereport
             varying rtrInd from 1 by 1
             until rtrInd > 200.

     close dbdata
           repxmlfile.

     goback.
*>
 0100-getdata.
*>
     unstring dbdatarec delimited by "|" 
              into dbTable, dbFieldName, dbFieldType, dbFieldLength
     end-unstring.
*>
 0110-loadtable.
*>
     if dbTable <> lastTable
        if lastTable <> spaces
           set rtrInd		down by 1
           move "F"		to rtrType(rtrInd, rtcInd)
           set rtrInd		up by 1
        end-if
        if rtcInd = 4
           set rtcInd		to 1
           set rtrInd		to highind
           set lowind		to highind
        else 
           set rtrInd		to lowind
           set rtcInd		up by 1
        end-if
        move "h"		to rtrType(rtrInd, rtcInd)
        move dbTable            to rtrTabFldName(rtrInd, rtcInd)
        set rtrInd		up by 1
        move "f"		to rtrType(rtrInd, rtcInd)
        move dbFieldName        to rtrTabFldName(rtrInd, rtcInd)
        move dbFieldType        to rtrFieldType(rtrInd, rtcInd)
     else
        move "f"		to rtrType(rtrInd, rtcInd)
        move dbFieldName        to rtrTabFldName(rtrInd, rtcInd)
        move dbFieldType        to rtrFieldType(rtrInd, rtcInd)
     end-if.

     set rtrInd			up by 1.

     if rtrInd > highind 
        set highind		to rtrInd
     end-if.

     move dbTable		to lastTable.
*>
 0130-writereport.
*>
     write repxmlrec		from trowstart.

     perform varying rtcInd from 1 by 1
                 until rtcInd > 4
          move spaces		to repxmlrec
          if rtrType(rtrInd, rtcInd) = "h"
             move quote & "ce1" to cssStyle
             string cellStart, 
                    quote, function trim(rtrTabFldName(rtrInd, rtcInd)), quote,
                    cellStartStyle 
                  into repxmlrec
             end-string
             write repxmlrec
             move spaces 	to repxmlrec
             string textStart, 
                    rtrTabFldName(rtrInd, rtcInd),
                    textEnd
                  into repxmlrec
             end-string
             write repxmlrec
             write repxmlrec	from cellFinish
             write repxmlrec	from headerType
          else if rtrType(rtrInd, rtcInd) = "f"
             move quote & "ce3" to cssStyle
             string cellStart, 
                    quote, rtrTabFldName(rtrInd, rtcInd), quote,
                    cellStartStyle 
                  into repxmlrec
             end-string
             write repxmlrec
	     move spaces 	to repxmlrec
             string textStart, 
                    rtrTabFldName(rtrInd, rtcInd),
                    textEnd
                  into repxmlrec
             end-string
             write repxmlrec
             write repxmlrec	from cellFinish
             move quote & "ce4" to cssStyle
	     move spaces 	to repxmlrec
             string cellStart, 
                    quote, rtrFieldType(rtrInd, rtcInd), quote,
                    cellStartStyle 
                  into repxmlrec
             end-string
             write repxmlrec
	     move spaces 	to repxmlrec
             string textStart, 
                    rtrTabFldName(rtrInd, rtcInd),
                    textEnd
                  into repxmlrec
             end-string
             write repxmlrec
             write repxmlrec	from cellFinish
          else if rtrType(rtrInd, rtcInd) = "F"
             move quote & "ce5" to cssStyle
             string cellStart, 
                    quote, rtrTabFldName(rtrInd, rtcInd), quote,
                    cellStartStyle 
                  into repxmlrec
             end-string
             write repxmlrec
	     move spaces 	to repxmlrec
             string textStart, 
                    rtrTabFldName(rtrInd, rtcInd),
                    textEnd
                  into repxmlrec
             end-string
             write repxmlrec
             write repxmlrec	from cellFinish
             move quote & "ce6" to cssStyle
	     move spaces 	to repxmlrec
             string cellStart, 
                    quote, rtrFieldType(rtrInd, rtcInd), quote,
                    cellStartStyle 
                  into repxmlrec
             end-string
             write repxmlrec
	     move spaces 	to repxmlrec
             string textStart, 
                    rtrTabFldName(rtrInd, rtcInd),
                    textEnd
                  into repxmlrec
             end-string
             write repxmlrec
             write repxmlrec	from cellFinish
          else
             write repxmlrec    from emptycell
          end-if         
     end-perform. 

     write repxmlrec		from trowend.
