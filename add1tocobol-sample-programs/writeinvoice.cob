       >>source format is free
*>*********************************************************************
*> Author:    jrls (John Ellis)
*> Date:      Feb-2009
*> Purpose:   Reads invoicedata from invrunf and uses the odfscanner
*>            sub routines to write the invoices to a open document 
*>	      spreadheet.
*>*********************************************************************
identification division.
program-id. writeinvoice.
environment division.
*>
input-output section.
*>
file-control.
*>
select invoicefile	assign to "database/invoice1.csv"
                        organization is line sequential.
*>
data division.
*>
file section.
*>
fd invoicefile.
*>
01 invoicerec		pic x(200).
*>
working-storage section.
*>
 01  eof			pic x value spaces.
     88  end-of-file		      value "y".
 01  untstate			pic x(4) value spaces.
*>
 01 invoicedata		.
*>
    05  inv-invoiceno		pic 9(6) value zero.
    05  inv-invdate.
        10  invd-year		pic x(4) value spaces.
        10                      pic x value spaces.
        10  invd-month		pic xx value spaces.
        10 			pic x value spaces.
        10  invd-day		pic xx value spaces.
    05  inv-sonumber		pic 9(6).
    05  inv-custpo               pic x(8).
    05  inv-terms		pic x(8).
    05  inv-salesrep		pic x(8).
    05  inv-shipmethod		pic x(8).
    05  inv-address occurs 2 times.
        10  inv-name  		pic x(28).
        10  inv-addr1		pic x(28).
        10  inv-addr2		pic x(28).
        10  inv-city		pic x(16).
        10  inv-state		pic xx.
        10  inv-zip		pic 9(10).
    05  inv-quantity		pic 9(10).
    05  inv-description		pic x(70).
    05  inv-unitprice		pic 9(6)v99.
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*>>>parms for calling odf subroutines
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 01  lastinvoice		pic 9(6) value zero.
 01  startpage			unsigned-int value zero.
 01  endpage			unsigned-int value zero.
 01  fieldname			pic x(18) value spaces.
 01  fieldvalue			pic x(100) value spaces.
 01  retcode			unsigned-int value zero.	
 01  sheetname			pic x(10) value spaces.
 01  showuprice			pic zzz,zz9.99 value zero.
 01  showamt			pic zzz,zz9.99 value zero.
 01  showtamt			pic zzz,zz9.99 value zero.
 01  totamt			pic 9(6)v99 value zero.
*>
 procedure division.
*>
 0000-start.
*>
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*>odfscanner preps the template file 
*>that was set to the system varible $odffile.
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     call "odfscanner"		using startpage,
				      endpage.
 
     open input invoicefile.

     perform until end-of-file
         read invoicefile
              at end
                 move "y" 	to eof
                 perform 0200-putsheetname
           	 move "totalamt" to fieldName
           	 move totamt	to showtamt
           	 move showtamt	to fieldValue
                 perform 0800-odfsetvalue
	         call "odfwritepage"	using startpage,
                                              endpage,
                                              sheetname
                 end-call
                 call "odffinishform"   using endpage
                 end-call
              not at end
                 inspect invoicerec replacing all '"' by " "
                 unstring invoicerec delimited by ","
                          into inv-invoiceno,
                               inv-invdate,
                               inv-sonumber,
                               inv-custpo,
                               inv-salesrep,
                               inv-shipmethod,
                               inv-terms,
                               inv-name(1),
                               inv-addr1(1),
                               untstate,
                               inv-zip(1),
                               inv-quantity,
                               inv-unitprice,
                               inv-description
                 end-unstring
                 move function trim(untstate) to inv-state(1)
                 perform 0100-process-invoices
         end-read
     end-perform.
 
     close invoicefile.

     goback.
*>
 0100-process-invoices.
*>
      if inv-invoiceno <> lastinvoice
        if lastinvoice <> 0
           perform 0200-putsheetname
           move "totalamt"	to fieldName
           move totamt		to showtamt
           move showtamt	to fieldValue
           perform 0800-odfsetvalue
	   call "odfwritepage"	using startpage,
                                      endpage,
                                      sheetname
           end-call
           move zero		to totamt
        else
            call "odfstartform"	using startpage
        end-if
        move "soldto"		to fieldName
        move inv-name(1) 	to fieldValue
        perform 0800-odfsetvalue
        move "soldtoaddr1" 	to fieldName
        move inv-addr1(1) 	to fieldValue
        perform 0800-odfsetvalue
        move "invnbr" 		to fieldName
        move inv-invoiceno 	to fieldValue
        perform 0800-odfsetvalue
        move "invdate" 		to fieldName
        move inv-invdate 	to fieldValue
        perform 0800-odfsetvalue
        move "soldtocitystatezip" to fieldName
        display "state=" inv-state(1)
        string inv-city(1), ", " inv-state(1), " ", inv-zip(1)
               into fieldValue
        end-string
        perform 0800-odfsetvalue
        move "sonbr" 		to fieldName
        move inv-sonumber 	to fieldValue
        perform 0800-odfsetvalue
        move "custpo" 		to fieldName
        move inv-custpo 	to fieldValue
        perform 0800-odfsetvalue
        move "shipto" to fieldName
        move inv-name(1) 	to fieldValue
        perform 0800-odfsetvalue
        move "terms" 		to fieldName
        move inv-terms 		to fieldValue
        perform 0800-odfsetvalue
        move "shiptoaddr1" 	to fieldName
        move inv-addr1(1)	to fieldValue
        perform 0800-odfsetvalue
        move "srep" 		to fieldName
        move inv-salesrep 	to fieldValue
        perform 0800-odfsetvalue
        move "shvia" 		to fieldName
        move inv-shipmethod	to fieldValue
        perform 0800-odfsetvalue
        move "shiptocitystatezip" to fieldName
        string inv-city(1), ", " inv-state(1), " ", inv-zip(1)
               into fieldValue
        end-string
        perform 0800-odfsetvalue
     end-if.
     move "qty" 		to fieldName.
     move inv-quantity 		to fieldValue.
     perform 0800-odfsetvalue.
     
     move "description" 	to fieldName.
     move inv-description 	to fieldValue.
     perform 0800-odfsetvalue.
  
     move "unitprice" 		to fieldName.
     move inv-unitprice 	to showuprice.
     move showuprice		to fieldValue.
     perform 0800-odfsetvalue.

     compute showamt = inv-quantity * inv-unitprice.
     compute totamt = totamt + (inv-quantity * inv-unitprice).
     move "amount" 		to fieldName.
     move showamt 		to fieldValue.
     perform 0800-odfsetvalue.
     move inv-invoiceno		to lastinvoice.
*>
 0200-putsheetname.
*>
     string "inv", 
            lastinvoice 
       into sheetname
     end-string.
*>
 0800-odfsetvalue.
*>
     call "odfsetfield" using fieldName,
			      fieldValue,
			      retcode
     end-call.
     if retcode <> 0
        display "0800-odfsetvalue problem with retcode=" retcode
     end-if.
