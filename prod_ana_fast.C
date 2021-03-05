bool checkfile(TString fn)
{
	bool fileok=true;
	TFile fff(fn); 
	if (fff.IsZombie()) fileok=false;
	TTree *t=(TTree*)fff.Get("cbmsim");
	if (t==0x0) fileok=false;
	
	if (!fileok) cout <<"Skipping broken file '"<<fn<<"'"<<endl;
	return fileok;
}

void prod_ana_fast(TString prefix="", int from=1, int to=1, int mode=0, int nevts=0)
{
 	if (prefix=="") 
	{
		cout << "Example analysis macro \n";
		cout << "USAGE:\n";
		cout << "prod_ana.C( <pref>, <from>, <to>, [nevt] )\n\n";
		cout << "   <pref>     : output file names prefix\n";
		cout << "   <from>     : first run number\n";
		cout << "   <to>       : last run number\n";
		cout << "   [mode]     : arbitrary mode number; default: 0\n";
		cout << "   [nevt]     : number of events; default: 0 = all\n\n";
		return;
	}
	
	double   Mom      = 1.642;
	bool     fastsim  = false;
	int      run      = from;	
	
	TString suffix = fastsim ? "fsim" : "pid";

	TString outFile    = TString::Format("%s_ana_%d_%d.root",prefix.Data(), from, to);
	TString inParFile  = TString::Format("%s_%d_par.root",prefix.Data(),from);
	TString firstFile  = TString::Format("%s_%d_%s.root",prefix.Data(),from,suffix.Data());

	// if prefix is a full file name, we skip the run number in the name
	if (prefix.EndsWith(".root"))
	{
		firstFile = prefix; 
	    outFile   = prefix; outFile.ReplaceAll(".root","_ana.root");
	    inParFile = prefix; inParFile.ReplaceAll("_pid.root","_par.root");
		to = from;
	}
	// if only one file, we name outfile to 'prefix_<run>_ana.root'
	else if (from==to)  outFile = TString::Format("%s_%d_ana.root", prefix.Data(), from);

	
	// Start a stop watch
	TStopwatch fTimer;
	fTimer.Start();

 	// --------------------------------
	// Create the Analysis run manager
	// --------------------------------
	FairRunAna     *fRun = new FairRunAna();
	FairFileSource *fSrc = new FairFileSource(firstFile);
		
  	// *** Add pid files
  	for (int i=from+1;i<=to;++i)
  	{
	  TString fname = TString::Format("%s_%d_%s.root",prefix.Data(),i,suffix.Data());
		if ( checkfile(fname) ) fSrc->AddFile(fname);
  	}
	
	fRun->SetSource(fSrc);
  	
	// *** PID table with selection thresholds; can be modified by the user
	TString pidParFile = TString(gSystem->Getenv("VMCWORKDIR"))+"/macro/params/all.par";	
	
	// *** initialization
	FairLogger::GetLogger()->SetLogToFile(kFALSE);


	FairRuntimeDb* rtdb = fRun->GetRuntimeDb();
	
	// *** setup parameter database 	
	FairParRootFileIo* parIO = new FairParRootFileIo();
	parIO->open(inParFile);
	//FairParRootFileIo* parIOdummy = new FairParRootFileIo();
	//parIO->open("dummypar.root");
	FairParAsciiFileIo* parIOPid = new FairParAsciiFileIo();
	parIOPid->open(pidParFile.Data(),"in");
	rtdb->setFirstInput(parIO);
	
	rtdb->setFirstInput(parIO);
	rtdb->setSecondInput(parIOPid);
	rtdb->setOutput(parIO);
	rtdb->setContainersStatic();
	

	fRun->SetOutputFile(outFile);
	
	//---------------------Create and Set the Field(s)---------- 
  	//PndMultiField *fField= new PndMultiField("AUTO");
  	//fRun->SetField(fField);
	
	//RhoCalculationTools::ForceConstantBz(10.0);

	// ***
	// *** HERE YOUR ANALYSIS CODE GOES!
	// ***
	
	PndLLbarAnaTaskRGIS *anaTask = new PndLLbarAnaTaskRGIS();
	anaTask->SetBeamMom(Mom);
	fRun->AddTask(anaTask);

	// *** and run analysis
	fRun->Init(); 
	fRun->Run(0,nevts);	
	
	//------------------------Print some info and exit----------------
	fTimer.Stop();
	FairSystemInfo sysInfo;
	Float_t maxMemory=sysInfo.GetMaxMemory();
	Double_t rtime = fTimer.RealTime();
	Double_t ctime = fTimer.CpuTime();
	
	Float_t cpuUsage=ctime/rtime;
	
	cout << endl;
	cout << "[INFO   ] Macro call       : prod_fsim.C(\""<<prefix<<"\", "<<from<<", "<<to<<", "<<mode<<", "<<nevts<<")" <<endl;
	cout << "[INFO   ] Output file      : " << outFile << endl;
	cout << "[INFO   ] Real time        : " << rtime << " s, CPU time " << ctime << "s" << endl;
	cout << "[INFO   ] CPU usage        : " << cpuUsage*100. << "%" << endl;
	cout << "[INFO   ] Max Memory       : " << maxMemory << " MB" << endl;
	cout << "[INFO   ] Macro finished successfully." << endl<<endl;
}
