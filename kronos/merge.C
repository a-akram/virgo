void merge(TString ntp="", TString fout="", TString f1="", TString f2="", TString f3="", TString f4="", TString f5="")
{
	if (ntp=="" || fout=="" || f1=="")
	{
		cout <<"\nmerge : merges a TTree with certain name from different files to one.\n\n"; 
		cout <<"USAGE: merge(TString ntp, TString outfile, TString filepattern 1, ... TString filepattern 5)\n\n";
		cout <<"   ntp           : name of the TTree.\n";
		cout <<"   outfile       : output file name.\n";
		cout <<"   filepattern 1 : 1st file pattern.\n";
		cout <<"   filepattern 2 : 2nd file pattern (optional).\n";
		cout <<"   ...\n";
		cout <<"   filepattern 2 : 5th file pattern (optional).\n\n";
		
		return;
	}
	
	TChain n(ntp);

	n.Add(f1+"/"+ntp);
	if (f2!="") n.Add(f2);
	if (f3!="") n.Add(f3);
	if (f4!="") n.Add(f4);
	if (f5!="") n.Add(f5);
	
	n.Merge(fout);
}
