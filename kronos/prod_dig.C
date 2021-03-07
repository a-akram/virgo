void prod_dig(TString prefix="")
{
  //-----User Settings:------------------------------------------------------
  TString  parAsciiFile   = "all.par";
  TString  output         = "digi";
  TString  friend1        = "sim";
  
  // -----   Initial Settings   --------------------------------------------
  PndMasterRunAna *fRun= new PndMasterRunAna();
  fRun->SetInput("dummy");
  fRun->AddFriend(friend1);
  fRun->SetOutput(output);
  fRun->SetParamAsciiFile(parAsciiFile);
  fRun->Setup(prefix);

  // -----   Add tasks   ----------------------------------------------------
  fRun->AddDigiTasks();

  // -----   Intialise and run   --------------------------------------------
  fRun->Init();
  fRun->Run(0);
  fRun->Finish();

}
