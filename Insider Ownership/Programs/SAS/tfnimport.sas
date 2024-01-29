libname tfn 'U:\Research\tfninfo';

/*ONLY BOARD*/

/*Cleansing step for non-intial securities, but for the lowest level as indicated by TR */
data tfn.owni2obitemp;
	set tfn.owni2obi;
	where cleanse ^= 'A' and missing(amend);
run;


proc sort DATA = tfn.owni2obitemp OUT=tfn.owni2obitemp; 
	by cusip6 personid trandate dcn seqnum;
run;


/*Identifies if a person does not disclose their initial holdings*/
data tfn.noinitnames;
	set tfn.owni2obitemp;
	keep personid cusip6 noinit;
	by cusip6 personid trandate dcn seqnum;
	if first.personid and not missing(acqdisp);
	noinit=1;
run;

/*merges the personid's with no initial transactions back into the main dataset with a marker attached*/
data tfn.owni2obitemp;
	merge tfn.owni2obitemp tfn.noinitnames;
	by cusip6 personid;
run;


data tfn.owni2obitemp;
	set tfn.owni2obitemp;

/*Correcting ACQDISP and generating acqdispc*/
/*ACQDISP is a variable which takes on a 'D' if the observation denotes a disposition of shares and takes on an 'A' if the observation denotes an acquisition of shares*/

data tfn.owni2obitemp;
	set tfn.owni2obitemp;
	acqdispc = ".";
	/*acqdispch = Acquisition Disposition Change, this is a flag for whether or not the below if statement picks up an erroneous disposal*/
	acqdispch = 0;
	acqdispch2 = 0;
	by cusip6 personid trandate dcn seqnum;
	if dcn = lag(dcn) and lag(derivative) in ('CVP', 'CVS', 'CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF') and shares_adj = lag(shares_adj) and acqdisp = 'D' and lag(acqdisp) = 'D' then do;
		acqdispc = "A";
		acqdispch = 1;
	end;
	else if dcn = lag(dcn) and dcn = lag2(dcn) and lag(derivative) in ('CVP', 'CVS', 'CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF') and lag(derivative) = lag2(derivative) and shares_adj = lag(shares_adj) + lag2(shares_adj) and shares_adj = lag(shares_adj) and acqdisp = 'D' and lag(acqdisp) = 'D' then do;
		acqdispc = "A";
		acqdispch = 1;
		acqdispch2 = 2;
	end;
	else if acqdispch ^= 1 then do;
			acqdispc = acqdisp;
	end;
run;


* Summing for all transactions for an insider;
data tfn.owni2obitemp;
	set tfn.owni2obitemp;
	derivreportvar = 0;
	shares_adjnew = shares_adj;
	if missing(shares_adjnew) then shares_adjnew = 0;
	if acqdispc = 'D' then shares_adjnew = shares_adjnew*-1;
	by cusip6 personid trandate dcn seqnum;
	if first.personid then sharescount = 0;
	*Identifies actual equity transactions;
	if derivative not in ('CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF') and NOT (derivative = 'UKN' and not missing(tdate) and not missing(xdate)) then do;
		sharescount + shares_adjnew; 
		if noinit = 1 then do;
			if derivative = 'CVP' and acqdispc = 'D' then do;
			shares_adjnew = -1*shares_adjnew;
			sharescount + shares_adjnew;
			end;
		end;
	end;
	else do;
		shares_adjnew = 0;
	end;
	*Corrects if current sharesheld is less than the amount indicated by the derivatives;
	if derivative not in ('CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF') and NOT (derivative = 'UKN' and not missing(tdate) and not missing(xdate)) then do;
		if derivheld_adj > sharescount then do;
			derivreportvar = 1;
			sharescount = derivheld_adj;
		end;
	end;
run;


data tfn.owni2obifinal;
	set tfn.owni2obitemp;
	year = year(trandate);
	by cusip6 personid trandate dcn seqnum;
run;

proc sort data = tfn.owni2obifinal out = tfn.owni2obifinal;
	by cusip6 personid year trandate dcn seqnum;
run;

data tfn.owni2obifinal;
	set tfn.owni2obifinal;
	by cusip6 personid year trandate dcn seqnum;
	if last.year;
run;



/*where derivative not in ('CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF', 'BOND', 'PHNTM', 'EQSWAP', 'NTS', 'EXFND');*/


/*Cleansing step for non-intial securities, but for the lowest level as indicated by TR */
data tfn.owni2uitemp;
	set tfn.owni2ui;
	where cleanse ^= 'A' and missing(amend);
run;


proc sort DATA = tfn.owni2uitemp OUT=tfn.owni2uitemp; 
	by cusip6 personid trandate dcn seqnum;
run;


/*Indentifies if a person does not disclose their initial holdings*/
data tfn.noinitnames;
	set tfn.owni2uitemp;
	keep personid cusip6 noinit;
	by cusip6 personid trandate dcn seqnum;
	if first.personid and not missing(acqdisp);
	noinit=1;
run;

/*merges the personid's with no initial transactions back into the main dataset with a marker attached*/
data tfn.owni2uitemp;
	merge tfn.owni2uitemp tfn.noinitnames;
	by cusip6 personid;
run;


data tfn.owni2uitemp;
	set tfn.owni2uitemp;

/*NOTE: Add firms for which insiders form 3 filings are not constructed by TR*/


/*Correcting ACQDISP and generating acqdispc*/
data tfn.owni2uitemp;
	set tfn.owni2uitemp;
	acqdispc = ".";
	/*acqdispch = Acquisition Disposition Change, this is a flag for whether or not the below if statement picks up an erroneous disposal*/
	acqdispch = 0;
	acqdispch2 = 0;
	by cusip6 personid trandate dcn seqnum;
	if dcn = lag(dcn) and lag(derivative) in ('CVP', 'CVS', 'CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF') and shares_adj = lag(shares_adj) and acqdisp = 'D' and lag(acqdisp) = 'D' then do;
		acqdispc = "A";
		acqdispch = 1;
	end;
	else if dcn = lag(dcn) and dcn = lag2(dcn) and lag(derivative) in ('CVP', 'CVS', 'CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF') and lag(derivative) = lag2(derivative) and shares_adj = lag(shares_adj) + lag2(shares_adj) and shares_adj = lag(shares_adj) and acqdisp = 'D' and lag(acqdisp) = 'D' then do;
		acqdispc = "A";
		acqdispch = 1;
		acqdispch2 = 2;
	end;
	else if acqdispch ^= 1 then do;
			acqdispc = acqdisp;
	end;
run;


* Summing for all transactions for an insider;
data tfn.owni2uitemp;
	set tfn.owni2uitemp;
	derivreportvar = 0;
	shares_adjnew = shares_adj;
	if missing(shares_adjnew) then shares_adjnew = 0;
	if acqdispc = 'D' then shares_adjnew = shares_adjnew*-1;
	by cusip6 personid trandate dcn seqnum;
	if first.personid then sharescount = 0;
	*Identifies actual equity transactions;
	if derivative not in ('CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF') and NOT (derivative = 'UKN' and not missing(tdate) and not missing(xdate)) then do;
		sharescount + shares_adjnew; 
		if noinit = 1 then do;
			if derivative = 'CVP' and acqdispc = 'D' then do;
			shares_adjnew = -1*shares_adjnew;
			sharescount + shares_adjnew;
			end;
		end;
	end;
	else do;
		shares_adjnew = 0;
	end;
	*Corrects if current sharesheld is less than the amount indicated by the derivatives;
	if derivative not in ('CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF') and NOT (derivative = 'UKN' and not missing(tdate) and not missing(xdate)) then do;
		if derivheld_adj > sharescount then do;
			derivreportvar = 1;
			sharescount = derivheld_adj;
		end;
	end;
run;

/*adding a year variable to the unique insiders dataset*/
data tfn.owni2uifinal;
	set tfn.owni2uitemp;
	year = year(trandate);
	by cusip6 personid trandate dcn seqnum;
run;

proc sort data = tfn.owni2uifinal out = tfn.owni2uifinal;
	by cusip6 personid year trandate dcn seqnum;
run;

/*Selecting only the final years of report for each insider such that the insider ownership can be summed by year*/
data tfn.owni2uifinal;
	set tfn.owni2uifinal;
	by cusip6 personid year trandate dcn seqnum;
	if last.year;
run;
