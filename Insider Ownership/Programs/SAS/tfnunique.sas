libname tfn 'U:\Research\tfninfo';
/*Comments in this file refer to the line below, and not above*/

proc sort DATA = tfn.owni2 OUT= tfn.owni2;
	by cusip6 personid trandate dcn seqnum;
run;

/*identifies the number of transactions taken by personid in order to select highest count if initial counts are equal*/
data tfn.transcount;
	set tfn.owni2 (keep= cusip6 personid);
	by cusip6 personid;
	if first.personid then count = 0;
	count + 1;
	/*sets all values of max to missing besides the last transaction for a personid, used in next data statement*/
	if last.personid then max = count;
run;


/*drops all but the final observation for each personid*/
data tfn.transcount;
	set tfn.transcount;
	drop count;
	where not missing(max);
run;

/*Isolates non-option statements of ownership and stores them in alli2dup which standards for All Firms, Table 2 Indirect Transactions, Duplicates*/;
data tfn.alli2nodup;
	set tfn.owni2;
	where derivative not in ('CALL', 'CLLR', 'OPTIO', 'OPTNS', 'PUT', 'RGHTS', 'WARRA', 'WT', 'WT TO', 'WTS', 'FWD', 'DIRO', 'DIREO', 'ISO', 'NONQ', 'PERF', 'BOND', 'PHNTM', 'EQSWAP', 'NTS', 'EXFND');
	shares2=0;
	cvpcount = 0;
	keepvar = 0;
	dropindicator = 0;
run;

proc sort data = tfn.alli2nodup out = tfn.alli2nodup;
	by cusip6 personid trandate dcn seqnum;
run;

/*selects the first transaction from the first dcn for each insider within alli2dup*/
data tfn.alli2nodup;
	set tfn.alli2nodup;
	keep cusip6 personid trandate owner dcn;
	by cusip6 personid trandate dcn;
	if first.personid and first.dcn;
run;


/*prepares alli2dup for merging*/
proc sort DATA = tfn.alli2nodup OUT = tfn.alli2nodup;
	by cusip6 personid trandate dcn;
run;


data tfn.firsttrans;
	merge tfn.alli2nodup(in=i) tfn.owni2(in=j);
	by cusip6 personid trandate dcn;
	if i=j;
run;

/*Sums the initial share counts for each insider*/
data tfn.firsttranssum;
	set tfn.firsttrans;
	by cusip6 personid;
	if first.personid then sharescount = 0;
	sharescount + shares_adj;
run;

data tfn.uniqueowners;
	set tfn.firsttranssum;
	by cusip6 personid trandate;
	if last.trandate;
run;

data tfn.uniqueownerswcount;
	merge tfn.transcount(in=i) tfn.uniqueowners(in=j);
	by cusip6 personid;
	if i=j;
run;

proc sort data = tfn.uniqueownerswcount out= tfn.uniqueownerswcount;
	by cusip6 sharescount max personid;
run;

/*Selects highest shares in order to check against the initial share count list to identify the "primary" exector of holding company shares*/
data tfn.uniqueownerswcount;
	set tfn.uniqueownerswcount;
	by cusip6 sharescount max personid;
	if last.sharescount;
run;

data tfn.uniqueownernames;
	set tfn.uniqueownerswcount;
	keep cusip6 personid owner;
run;

proc sort DATA = tfn.uniqueownernames OUT = tfn.uniqueownernames NODUPKEY;
	by cusip6 personid;
run;

/*Selects shareholders with board designations*/
data tfn.onlyboardinit;
	set tfn.firsttranssum;
	keep cusip6 personid;
	where rolecode1 in ("CB","D","DO","H","OD"," VC","AC"," CC","EC","FC","MC","SC","AV","CEO","CFO","CI","CO","CT","EVP","O","OB","OP","OS","OT","OX","P","S","SVP","VP");
run;

proc sort DATA = tfn.onlyboardinit OUT = tfn.onlyboardinit NODUPKEY;
	by cusip6 personid;
run;

/*owni2ui = "Indirect Table 2 Ownership Selected for Unique Owners" using the method above */

data tfn.owni2ui;
	merge tfn.uniqueownernames(in=i) tfn.owni2(in=j);
	by cusip6 personid;
	if i = j;
run;
/*owni2ui = "Indirect Table 2 Ownership Selected for Unique Owners from RoleCodes" using the method above */

data tfn.owni2obi;
	merge tfn.onlyboardinit(in=i) tfn.owni2(in=j);
	by cusip6 personid;
	if i = j;
run;
