 libname tfn 'U:\Research\tfninfo';


/*Ininiates connect to WRDS and downloads Thomson-Reuters*/

%let wrds=wrds.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=_prompt_;

rsubmit;

libname tfnrem '/wrds/tfn/sasdata/insiders/';

/*Downloads Table 1 and Table 2 from Thomson-Reuters*/
proc download data=tfnrem.table1 out=tfn.tfn1; run;
proc download data=tfnrem.table2 out=tfn.tfn2; run;

endrsubmit;

data tfn.owni2;
	set tfn.tfn2;
	where ownership='I';
run;

proc sort data = tfn.owni2 out = tfn.owni2;
	by cusip6 personid trandate dcn seqnum;
run;
