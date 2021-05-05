bool CheckFile(TString fn) {

    bool fileok=true;
    TFile fff(fn); 
    if (fff.IsZombie()) fileok=false;

    TTree *t=(TTree*)fff.Get("cbmsim");
    if (t==0x0) fileok=false;

    if (!fileok) std::cout << "Skipping Broken File: '"<< fn << "'" << std::endl;
    return fileok;
}

int prod_ana_multi(Int_t nEvents=10, TString prefix="ll", Bool_t IsSignal=true, int from=1, int to=1, int mode=0) {

 	if (prefix=="") 
	{
		cout << "Example analysis macro \n";
		cout << "USAGE:\n";
		cout << "prod_ana.C( <pref>, <from>, <to>, [nevt] )\n\n";
		cout << "   [nevt]     : number of events; default: 0 = all\n\n";
		cout << "   <pref>     : output file names prefix\n";
		cout << "   <from>     : first run number\n";
		cout << "   <to>       : last run number\n";
		cout << "   [mode]     : arbitrary mode number; default: 0\n";
		return 0;
	}
	
	double   Mom      = 1.642;
	bool     fastsim  = false;
	int      run      = from;	
	
	TString suffix    = fastsim? "fsim": "pid";
	TString outFile   = TString::Format("%s_ana_%d_%d.root", prefix.Data(), from, to);
	TString inParFile = TString::Format("%s_%d_par.root", prefix.Data(), from);
	TString firstFile = TString::Format("%s_%d_%s.root", prefix.Data(), from, suffix.Data());
    
    // *** PID table with selection thresholds; can be modified by the user
	TString pidParFile = TString(gSystem->Getenv("VMCWORKDIR"))+"/macro/params/all.par";	
	
	
	// if prefix is a full file name, we skip the run number in the name
	if (prefix.EndsWith(".root"))
	{
		firstFile = prefix; 
	    outFile   = prefix; outFile.ReplaceAll(".root","_ana.root");
	    inParFile = prefix; inParFile.ReplaceAll("_pid.root","_par.root");
		to = from;
	}
	// if only one file, we name outfile to 'prefix_<run>_ana.root'
	else if (from==to)
	    outFile = TString::Format("%s_%d_ana.root", prefix.Data(), from);



 	// *** initialization
 	FairLogger::GetLogger()->SetLogToFile(kFALSE);
	FairRunAna *fRun = new FairRunAna();
	FairRuntimeDb* rtdb = fRun->GetRuntimeDb();
	FairFileSource *fSrc = new FairFileSource(firstFile);
	
  	// *** add pid files
  	for (int i=from+1; i<=to; ++i) {
  	    
  	    //pidfile: <prefix>_<id>_pid.root
        TString fname = TString::Format("%s_%d_%s.root", prefix.Data(), i, suffix.Data());
        if (CheckFile(fname)) fSrc->AddFile(fname);
  	}
	
	fRun->SetSource(fSrc);
    
	// *** setup parameter database
	FairParRootFileIo* parIO = new FairParRootFileIo();
	parIO->open(inParFile);
	FairParAsciiFileIo* parIOPid = new FairParAsciiFileIo();
	parIOPid->open(pidParFile.Data(),"in");
	
	rtdb->setFirstInput(parIO);
	rtdb->setSecondInput(parIOPid);
	rtdb->setOutput(parIO);
	rtdb->setContainersStatic();
	fRun->SetOutputFile(outFile);
    
    // *** HERE OUR TASK GOES!
	PndLLbarAnaTaskRGIS *anaTask = new PndLLbarAnaTaskRGIS();
    
	// True for Signal (Default), False for Non-resonant Bkg.
	anaTask->SetSignalSample(IsSignal);
	fRun->AddTask(anaTask);
    
	// *** and run analysis
	fRun->Init();
	fRun->Run(0, nEvents);
	return 0;
}
