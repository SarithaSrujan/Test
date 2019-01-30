/**********************************************************************
Name                :NPX_Onboarding_Batch_HYB_BP
Other class used    : None
Tested in class     : NPX_Onboarding_Batch_HYB_Test
++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Purpose:
    Batch job to create entries in Npx Survey Record Object which include
    the following records.
    
    1. whose Contact is Head of Tenants/Building Manager  OR ALL and has a phone number/EMAIL/Mobilenumber
        
    4. Use NPX_Config__c to set up configuration parameter.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
History
--------
Version       Author       Date              Details
  1.0        Saritha      24/5/2018        Initial development

*************************************************************************/
public with sharing class NPX_Onboarding_Batch_HYB_BP implements Database.Batchable<sObject> , Database.Stateful{
  public final String query;
  public Integer Onboarding_BatchNum = 0;
  public Integer Onboarding_Scopesize = 0;
  public Integer Onboarding_UniqueBMCount = 0;
  public Integer Onboarding_SurveyAttempt = 0;
  //public string Onboarding_SurveyID;
  public string Onboarding_Batch = String.valueof(NPX_Onboarding_Batch_HYB_BP.class);
  public string Onboarding_SurveyMethodName = 'Onboarding_BM';
  public String Onboarding_Query;
  public boolean Onboarding_AbortBatch = false;
  public String Onboarding_Batch_Config;
  public Datetime dtbatchStart = System.Now();
  public Map < String, String > mapKey_Value = new Map < String, String > ();
  public map < string, string > mapEscalationEmail = new map < string, string > ();
  Map < string, NPX_Action_Owner__c > mapEscalationOwnerDetails = new map < string, NPX_Action_Owner__c > ();
  public Integer iSurveySummaryNum = 0;
  public Integer Onboarding_UniqueHOACount = 0;
  public String Onboarding_FinishDate;
  public string Onboarding_ContractMarketSegment;
  public string Onboarding_Status;
  public string Onboarding_FinishFilter;
  public string Onboarding_OrderReasons;
  public String Onboarding_FinishedDate;
  public string Onboarding_ConditionOnLeaving;
  public string Onboarding_ActivityTypeCode;
  public string Onboarding_DateFilter1;
  public string Onboarding_DateFilter2;
  public string Onboarding_SAPstatus;
  public string Onboarding_KONECtstatus;
  public string Onboarding_ContactFunction;
  public string Onboarding_DocType;
  public string Onboarding_Equipment;
  public string Onboarding_emailsError;
  public String Onboarding_SurveyDefaultMethod;
  public string Onboarding_SalesOrgs;
  public string Onboarding_SalesOffices;
  public string Onboarding_emails;
  public string Onboarding_SurveyID;
  public string Onboarding_DebugTest;
  public string Onboarding_CustSegment;
  public string Onboarding_ConStartDate_AGO;
  public string Onboarding_IndustrySegment;
  public string Onboarding_BatchName;
  public string Onboarding_Countries;
  public string Onboarding_CustomerGroup;
  public string Onboarding_ContactRole;
  public string Onboarding_ContractStartBeginDate;
  public string Onboarding_ContractStartEndDate;
  public string Onboarding_ContractKonecountry;
  public string Onboarding_Accountcustomersegment;
  public string Onboarding_Accountmarketsegment;
  public string Onboarding_Contracttype;
  public string onBoarding_ContactActive;
  public string onBoarding_ContactDonotSurvey;
  public string onboarding_contactOwner_Region;
  public String  sQuery;
  public string strParam;
  public list<NPX_Surveys__c> lsnpxsurvey = new list<NPX_Surveys__c>();

  public NPX_Onboarding_Batch_HYB_BP(String strParam, Map < string, string > mapConfigs) 
  {
    Onboarding_Batch_Config = strParam;
    mapKey_Value = mapConfigs;
    SYSTEM.DEBUG('==========Input string from scheduler=====' + Onboarding_Batch_Config);
    SYSTEM.DEBUG('==========Input string from scheduler=====' + mapKey_Value);

    //if (mapConfigs == null || mapConfigs.size () == 0 ) 
    mapKey_Value = NPX_CX_Util.getNpxConfigMap(strParam);

    if (mapKey_Value == null || mapKey_Value.size() == 0) {
        Onboarding_AbortBatch = True;
    } 
    else 
    {

      // Onboarding_FinishFilter = mapKey_Value.get('Onboarding_contract_FinishDate');
      /** Equipments **/
      Onboarding_Equipment = mapKey_Value.get('Contract_Equipment_Type');
      /** Service Contract **/
      Onboarding_DocType = mapKey_Value.get('Contract_Doc_Type');
      Onboarding_SalesOrgs = mapKey_Value.get('Contract_SalesOrg');
      Onboarding_SalesOffices = mapKey_Value.get('Contract_SalesOffice');
      Onboarding_FinishedDate = mapKey_Value.get('ServiceOrder_Finish_date');
      Onboarding_ContractStartBeginDate = mapKey_Value.get('Contract_StartDate_BeginDaysAgo');
      Onboarding_ContractStartEndDate = mapKey_Value.get('Contract_StartDate_EndDaysAgo');
      Onboarding_Countries = mapKey_Value.get('ServiceOrder_Kone_Country'); //new
      Onboarding_ContractMarketSegment = mapKey_value.get('Contract_Market_segment');
      Onboarding_ContractKonecountry = mapKey_value.get('Contract_koneCountry');
      Onboarding_Contracttype = mapKey_value.get('Contract_Contract_Type'); 
      Onboarding_OrderReasons = mapKey_Value.get('Contract_OrderReasons');
      /*** Contacts **/
      Onboarding_ContactFunction = mapKey_value.get('Contact_Function');
      if (Onboarding_ContactFunction == null || Onboarding_ContactFunction == '')Onboarding_ContactFunction = 'ALL';

      Onboarding_ContactRole =  mapKey_Value.get('Service_Contract_Contact_Role'); 
      
       onBoarding_ContactActive = mapKey_Value.get('Contact_Active');
       onBoarding_ContactDonotSurvey= mapKey_Value.get('Contact_Donotsurvey');
       onboarding_contactOwner_Region= mapKey_Value.get('Contact_Owner_Region');
       onBoarding_SurveyDefaultMethod =mapKey_Value.get('Survey_Default_Method'); 
      /** Technical **/
      Onboarding_Status = mapKey_Value.get('Survey_Initial_Status');
      Onboarding_SurveyID = mapKey_Value.get('Survey_Number');
      Onboarding_DebugTest = mapKey_Value.get('Technical_Test');
      Onboarding_SurveyDefaultMethod = mapKey_Value.get('Survey_Default_Method');
      Onboarding_emailsError = mapKey_Value.get('Technical_Error_Emails');
      Onboarding_BatchName = mapKey_Value.get('Technical_BatchName');
      Onboarding_emails = mapKey_Value.get('Technical_Summary_Emails');
      
      /* Account  **/
      Onboarding_Accountcustomersegment = mapKey_Value.get('Account_Customer_Segment');
      Onboarding_Accountmarketsegment = mapKey_Value.get('Account_Market_Segment');
      Onboarding_CustomerGroup = mapKey_Value.get('Account_Customer_Group');
      
     
      
      Onboarding_Batch = Onboarding_BatchName;
    }
    //Abort batch if the sHOASurveyID is empty values to be included 
      lsnpxsurvey = [select NPX_Survey_ID__c, NPX_Survey_Name__c from NPX_Surveys__c where NPX_Survey_ID__c =: Onboarding_SurveyID ];
      system.debug('@@@@ lsnpxsurvey '+lsnpxsurvey);
      if(Onboarding_AbortBatch = false){
        if(lsnpxsurvey[0].NPX_Survey_ID__c != Onboarding_SurveyID){
          Onboarding_AbortBatch = TRUE;
        }
      }
      else
       Onboarding_AbortBatch = False;
  }//end of constructor
  public Database.QueryLocator start(Database.BatchableContext BC) 
  {

    string sWhere_ContractSalesoffice = ' ';
    string sWhere_ContractSalesOrg = ' ';
    string swhere_Contractdoctype = ' ';
    
    SYSTEM.DEBUG ( '1x1 METHOD EXECUTE - START Survey 1  = ' + Onboarding_Batch + ' with abort = '+Onboarding_AbortBatch + ' || mapKey_Value.size () = ' +mapKey_Value.size () );
    if (mapKey_Value.size () ==0 || Onboarding_AbortBatch ) 
    {
      SYSTEM.DEBUG ( ' METHOD EXECUTE - ABORTED - NO CONFIG MAP AVAILABLE  -- OR --- REQUIRED DATA NOT AVAILABLE ');
      return Database.getQueryLocator([select Id from Contract__c Where Name = 'DOESNOT - EXIST - RETURN - DUMMY' LIMIT 1]);  
    }
    List<String> listOnboarding_OrderReasons = new List<String> ();
    String sQuery0,sQuery1,sQuery2,sQuery3,sQuery4 ='' ;
    //if  (!Onboarding_AbortBatch ) {
    //  listOnboarding_OrderReasons = Onboarding_OrderReasons.split('\\|') ;
    //}

    if  (!Onboarding_AbortBatch ) 
    {  
      if (( String.isEmpty( Onboarding_salesOffices )) &&  (String.isEmpty( Onboarding_SalesOrgs) ) )
      {
        // sQuery ='' ;
        Onboarding_AbortBatch = true;
        SYSTEM.DEBUG ('*****Onboarding_AbortBatch TRUE = '+ Onboarding_AbortBatch );      
      }
       //if either of  salesoffice or salesorg present scope should be defined.
      //else 
      //{
        //string sWhere_ContractSalesoffice = ' ';
        if ( !String.isEmpty( Onboarding_salesOffices) )
        {
          List<String> listOnboarding_SalesOffice = Onboarding_salesOffices.split('\\|') ;
          sWhere_ContractSalesoffice=  '  Sales_Office__c in : listOnboarding_SalesOffice ';
          SYSTEM.DEBUG ('@@@@listOnboarding_SalesOffice = '+ listOnboarding_SalesOffice );                               
        }
        //string sWhere_ContractSalesOrg = ' ';
        if (!String.isEmpty( Onboarding_SalesOrgs) )
        {
          List<String> listOnboarding_SalesOrg = Onboarding_SalesOrgs.split('\\|') ;
          sWhere_ContractSalesOrg =  ' and   Sales_Organization__c in : listOnboarding_SalesOrg ';
          SYSTEM.DEBUG ('@@@@listOnboarding_SalesOrg = '+ listOnboarding_SalesOrg );                
        }
        string swhere_contractsalesoffice_org = ' ';
        if ( !String.isEmpty( Onboarding_salesOffices)  &&   !String.isEmpty( Onboarding_SalesOrgs) )
        {
          swhere_contractsalesoffice_org = ' and (' + sWhere_ContractSalesoffice + ' OR ' + sWhere_ContractSalesOrg + ')'   ; 
        }
        else
        {
          if ( !String.isEmpty( sWhere_ContractSalesoffice) )
          {
            swhere_contractsalesoffice_org = ' and ' + sWhere_ContractSalesoffice  ; 
          }
          else {
          if (  !String.isEmpty( sWhere_ContractSalesOrg ) )
          {
            swhere_contractsalesoffice_org = ' and ' + sWhere_ContractSalesOrg     ; 
          }
        }
      }
    }
        //SYSTEM.DEBUG ('***** sQuery1  Sales office = '+ sQuery1 );     
       // SYSTEM.DEBUG ('***** sQuery2  Sales Organization = '+ sQuery2 );    
        //SYSTEM.DEBUG ('***** sQuery3  And/OR = '+ sQuery3 );                        
    //}     
    if ( Onboarding_AbortBatch )
    {
        sQuery =''; 
    }
    else
    {

      // Step : Create Map for FollowUp Owner Emails

       //mapEscalationEmail = cxNpxUtil.getNpxCEscalationMatrix();//Esclation matrix changes forseen
      //mapEscalationEmail = cxNpxUtil.getNpxFollowUpOwnerEscalationEmails(); // 2018 March Release:Som
        sQuery4 = ' ';
        if(!string.isempty(Onboarding_Equipment)){
      List<String> listOnboarding_Equipments = Onboarding_Equipment.split('\\|') ;
      system.debug('@@@@ listOnboarding_Equipments'+listOnboarding_Equipments);
      sQuery4 = ' where Equipment_Type__c IN : listOnboarding_Equipments ';
        }
        
      SYSTEM.DEBUG ('***** sQuery4  where clause for inner query = '+ sQuery4 ); 
      SYSTEM.DEBUG ('***** Onboarding_DocType = '+ Onboarding_DocType ); 
      sQuery = 'SELECT   Contract_type__c,Sales_Organization__c,SAP_ORIGINAL_NUMBER__c,Market_Segment__c, Sales_Office__c,Sales_Group__c,id, Contract_Start_Date__c,Renewal_date__c, Account__c,sold_to_account__r.Customer_Group__c,sold_to_account__r.Main_Business_Type__c,Contract_creation_date__c,';
      sQuery = sQuery + ' Contract_End_Date__c,Name, Contract_Order_Reason__c, CreatedDate,Customer__c, Kone_Country__c, OwnerId ,Building_Manager_contact__c, Bill_To__c,decided_by_account__r.Main_Business_Type__c,Decided_by_account__r.Customer_Group__c,';
      sQuery = sQuery + ' Purchase_Order_Num__c, Regional_Customer__c, Sold_to_account__c , Decided_by_account__c,';
      sQuery = sQuery + ' ( select  Id, Name,Equipment_type__c,Equipment_Type_description__c,Address_Street__c,City__c, Post_Code__c, Kone_Country__c,  Plant_Section__c, ';
      sQuery = sQuery + ' Planner_Group__c,Equipment_location__c from equipments__r  ';
      //need to check
      sQuery = sQuery +   sQuery4 ;
      sQuery = sQuery + ' order by createddate    limit 1 ), (SELECT  id,Equipment__r.Id, Equipment__r.Name,';
      sQuery = sQuery + ' Equipment__r.Address_Street__c, Equipment__r.City__c, Equipment__r.Contract__r.Sales_Organization__c,Equipment__r.Post_Code__c, Equipment__r.Kone_Country__c, ';
      sQuery = sQuery + ' Equipment__r.Plant_Section__c, Equipment__r.Planner_Group__c, Equipment__r.Equipment_location__c , ';
      sQuery = sQuery + ' Equipment__r.Equipment_type__c,Equipment__r.contract__r.OwnerId,Equipment__r.Equipment_Type_description__c, Equipment__r.Inventory_Num__c ';
      sQuery = sQuery + ' FROM Equipment_contracts__r '+ sQuery4 ;
      sQuery = sQuery + ' order by createddate Limit 1) FROM Contract__c ';
      sQuery = sQuery + ' where  Contract_Start_Date__c  ' + Onboarding_ContractStartBeginDate ; 
      sQuery = sQuery + ' and  Contract_Start_Date__c  ' + Onboarding_ContractStartEndDate ;
      //}
      //checking condition on whether End Date config value has a value.
      list<String> lstContractEndDate = Onboarding_ContractStartEndDate.split('\\|');
      if(lstContractEndDate.size() !=0){
      sQuery = sQuery + ' and  ( Contract_end_date__C = Null or Contract_end_date__C > TODAY )';//make a part of config(contract end parameter)condition should only be valid on contract_end date
    }
    //string swhere_Contractdoctype = ' ';
      If (!String.isEmpty(Onboarding_DocType)) 
      {
        SYSTEM.DEBUG ('XXX - sHoaDocType ==  ' + Onboarding_DocType);
        List<String> listOnboarding_DocType =  Onboarding_DocType.split('\\|');
        system.debug('@@@@ listOnboarding_DocType'+listOnboarding_DocType);
        swhere_Contractdoctype = ' and Document_Type__c  in : listOnboarding_DocType ' ;
        //sQuery = sQuery + ' and Document_Type__c  in : listOnboarding_DocType ' ; 
      }
      string swhere_Contractorderreason = ' ';
      If (!String.isEmpty(Onboarding_OrderReasons)) 
      {
        SYSTEM.DEBUG ('XXX - sHoaDocType ==  ' + Onboarding_OrderReasons);
        listOnboarding_OrderReasons =  Onboarding_OrderReasons.split('\\|');
        system.debug('@@@@ listOnboarding_OrderReasons'+listOnboarding_OrderReasons);
        swhere_Contractorderreason = ' and Contract_Order_Reason__c  in : listOnboarding_OrderReasons ' ;
        //sQuery = sQuery + ' and Document_Type__c  in : listOnboarding_DocType ' ; 
      }
      sQuery = sQuery + swhere_Contractdoctype;
      //sQuery = sQuery + ' and Contract_Order_Reason__c  in : listOnboarding_OrderReasons and  (Sold_to_account__c <> null or Decided_by_Account__C <> Null)' ;//need to check 
      sQuery = sQuery + swhere_Contractorderreason;
      //SYSTEM.DEBUG ('XXX -  HOA Query1 ==  ' + squery);
      if  (sWhere_ContractSalesOrg <> Null )
      sQuery =   sQuery +  sWhere_ContractSalesOrg;     
    }
    //filter on kone country and market segment
    string swhere_ContractKonecountry = ' ';
    if(!String.isEmpty(Onboarding_ContractKonecountry))
    {
      list<String> listContractKoneCountry = Onboarding_ContractKonecountry.split('\\|');
      swhere_ContractKonecountry =  'and  Kone_Country__c in : listContractKoneCountry';
      //sQuery = sQuery + 'and  Kone_Country__c in : listContractKoneCountry';
    }
     sQuery = sQuery + swhere_ContractKonecountry ;
    //may 2018 release filter on contract market segment
    string sWhere_ContractMarketsegment = ' ';
    if(!String.isEmpty(Onboarding_ContractMarketSegment))
    {
       list<String> listContractMarketsegment = Onboarding_ContractMarketSegment.split('\\|');
       system.debug('@@@@ listContractMarketsegment '+listContractMarketsegment);
       sWhere_ContractMarketsegment = '  and  Market_Segment__c in :listContractMarketsegment';
      //sQuery = sQuery + '  and  Market_Segment__c in :listContractMarketsegment';
    }
    sQuery = sQuery + sWhere_ContractMarketsegment;
    //may 2018 release filter on contract type
    string sWhere_ContractType = ' ';
    if(!String.isEmpty(Onboarding_ContractType))
    {
       list<String> listContractType= Onboarding_ContractType.split('\\|');
       system.debug('@@@@ listContractType'+listContractType );
        sWhere_ContractType = '  and  Contract_type__c in :listContractType';
      //sQuery = sQuery + '  and  Contract_type__c in :listContractType';
    }
    sQuery = sQuery + sWhere_ContractType;
 
    SYSTEM.DEBUG ('XXX - FINAL Query ==  ' + squery);
    try
    {
      if (!Test.isRunningTest())
      {    
        return Database.getQueryLocator( sQuery);
      }
      else 
      {
        return Database.getQueryLocator(   sQuery  + ' LIMIT 50'); 
      }
    }
      catch (Exception e){
      SYSTEM.DEBUG(LoggingLevel.ERROR,'ABSILOG *** Exception - Message : ' + e.getMessage() + 'Line no : ' + e.getLineNumber() + ' getStackTraceString ' + e.getStackTraceString() + '' + e.getCause());
      errorLog.Log(Onboarding_Batch, 'start', 'Error for batchNum: ' + Onboarding_BatchNum, e);   
      return Database.getQueryLocator([select Id from Contract__c Where Name = 'DOESNOT EXIST']);              
    }               
  }//end of start method
  public void execute(Database.BatchableContext BC, List<Contract__c> scope) 
  {
    SYSTEM.DEBUG(' #### METHOD EXECUTE - Scope.size()  = '+ Scope.size() + '|| mapKey_Value.size () = '+mapKey_Value.size ());
    Onboarding_BatchNum = Onboarding_BatchNum+1;  
    Onboarding_Scopesize +=  scope.size();
    list<string> listOnboarding_ContactFunction = Onboarding_ContactFunction.split('\\|');


    //calling a new class to insert npx survey records //condition on contact Function
    list<Npx_Survey_Record__c> npxSurveyRecords = NPX_Onboarding_Batch_HYB_Helper.insertNpxSurveyRecords(lsnpxsurvey,mapKey_Value,scope,listOnboarding_ContactFunction);
    System.debug('@@@@ npxSurveyRecords'+npxSurveyRecords);
    //surveyList.add(npxSurveyRecords);
    //list to merge both HOA and BM records
    
    list<Npx_Survey_Record__c> ListnpxSurveyRecords = new list<Npx_Survey_Record__c>();
    if(npxSurveyRecords != NULL)
    ListnpxSurveyRecords.addALL(npxSurveyRecords);
    system.debug('@@@@ ListnpxSurveyRecords'+ListnpxSurveyRecords.size());
    Onboarding_SurveyAttempt +=  npxSurveyRecords.size();
    Onboarding_UniqueBMCount +=  npxSurveyRecords.size();
      SYSTEM.DEBUG (' #### XXX - SurveyList size = '+ ListnpxSurveyRecords.size() +  ' ||  DEBUG Test = '+ Onboarding_DebugTest + ' || Attempt count ' + Onboarding_SurveyAttempt);
      if  ( Onboarding_DebugTest <> 'Yes' ) // for prod test purpose only - make config value = Yes - avoid insert and get logs 
      {                    
        try
        {
          if (ListnpxSurveyRecords.size()> 0 )
            {
              //Integer intSurveysbefore = [SELECT count() FROM NPX_Survey__c ];
                //Insert ListnpxSurveyRecords ; // u could use dml methods with  allornone optioninstead check with business.
                Database.SaveResult[] src=sObjectsDMLService.insertSObjects( Npx_Survey_Record__c.sObjectType,ListnpxSurveyRecords);
                SYSTEM.DEBUG ( ' Onboarding_ INSERTED RECORD ID = '+ListnpxSurveyRecords[0].ID + ' -- created date = '+ +ListnpxSurveyRecords[0].CreatedDate);
                iSurveySummaryNum += ListnpxSurveyRecords.size();
                SYSTEM.DEBUG ( ' **********  ####?  Total NPX records to be inserted for Onboarding_ = '+ListnpxSurveyRecords.size() +' - iSurveySummaryNum  = '+iSurveySummaryNum);                          }
            }
        catch (Exception e)
        {
          SYSTEM.DEBUG(LoggingLevel.ERROR,'ABSILOG *** Exception - Message : ' + e.getMessage() + 'Line no : ' + e.getLineNumber() + ' getStackTraceString ' + e.getStackTraceString() + '' + e.getCause());
          errorLog.Log(Onboarding_Batch, 'execute', 'Error for batchNum: ' + Onboarding_BatchNum, e);            
        }
     }  
    
  }//end of excute method

  public void finish(Database.BatchableContext BC) 
  {
    SYSTEM.DEBUG(' #### METHOD FINISH  mapKey_Value.size () = '+mapKey_Value.size ());
    // Query the AsyncApexJob object to retrieve the current job's information.
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
    //List<Error_Log__c> lsErrorLogs = [SELECT Error__c FROM Error_Log__c WHERE CreatedDate  =: dtBatchStart  and Component__c =: Onboarding_Batch];
    List<Error_Log__c> lsErrorLogs = [SELECT Error__c FROM Error_Log__c WHERE CreatedDate  >=: dtBatchStart and  component__c =:Onboarding_Batch];
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    if((!String.isBlank(Onboarding_Emails)) || (!String.isBlank(Onboarding_EmailsError)))
    {
      String[] toAddresses;
      if(!String.isBlank(Onboarding_Emails))
      {
        toAddresses = Onboarding_Emails.split(';');
        mail.setToAddresses(toAddresses);
        mail.setSubject(Onboarding_Batch + ' -  Survey Batch ' + a.Status);
      }
        SYSTEM.DEBUG('BM survey FINISH ===='+Onboarding_Emails);  
        String body = 'The batch job processed ' + a.TotalJobItems + ' batches and [ ';
        body += iSurveySummaryNum+ ' ]   records have been created. \n\n';
            body += 'Errors: ' + lsErrorLogs.size() + '\n';
            body += '\n\n';
            body += ' +++++++++++ CONFIG  VALUES ++++++++++++++++++\n\n';

            body += '+++++++++++ TECHNICAL PARAMETERS  +++++++++++++++\n';
            body += 'Batch Config........................: ' + Onboarding_Batch_Config + '\n';
            body += 'Batch Name..........................: ' +Onboarding_BatchName + '\n';
            body += 'Survey Number.......................: ' + Onboarding_SurveyID + '\n';           
            body += 'AbortBatch..........................: ' + Onboarding_AbortBatch + '\n';
            body += 'TEST2 DEBUG.........................: ' + Onboarding_DebugTest  + '\n';
            body += 'Emails4Summary......................: ' + Onboarding_emails + '\n';
            body += 'Emails4Error........................: ' + Onboarding_emailsError + '\n\n';
            body += '++++++++++ CONTRACT PARAMETERS  +++++++++++++++++++\n';
            body += 'Sales Org...........................: ' + Onboarding_SalesOrgs + '\n';
            body += 'Sales Office........................: ' + Onboarding_SalesOffices + '\n';
            body += 'Contract Start Days ago.............: ' + Onboarding_ContractStartBeginDate  + '\n';
            body += 'Equipment...........................: ' + Onboarding_Equipment+ '\n';
            body += 'Market Segment...........................: ' + Onboarding_ContractMarketSegment + '\n';
            body += 'Kone Country...........................: ' +Onboarding_ContractKonecountry + '\n';
            body += 'Document Type.......................: ' + Onboarding_DocType + '\n\n';
            
            body +='++++++++++++++++ ACCOUNT AND CONTACT PARAMETERS  ++++++++++++++++++\n';            
            body += 'Customer Group...........................: ' +  Onboarding_CustomerGroup + '\n';
            body += 'Account Market Segment ...........................: ' + Onboarding_Accountmarketsegment+ '\n';
            body += 'Account Customer segment...........................: ' +Onboarding_Accountcustomersegment + '\n';
            body += 'Contact Function...........................: ' + Onboarding_ContactFunction + '\n';
            body += 'Contact Active...........................: ' + onBoarding_ContactActive + '\n';
            //body += 'Contact Active...........................: ' + OnBoarding_ContactActive + '\n;
            body += 'Contact Do Not Survey...........................: ' + onBoarding_ContactDonotSurvey + '\n';
            body += 'Contact Owner Region...........................: ' + onboarding_contactOwner_Region + '\n';

            body += 'Contact Role...........................: ' + Onboarding_ContactRole + '\n\n';
            
            body += ' +++++++++++ SUMMARY  VALUES ++++++++++++++++++++++++++++\n';
            body += 'Batch Size..........................: ' + Onboarding_BatchNum + '\n';
            body += 'Scope size..........................: ' + Onboarding_Scopesize + '\n';
            body += 'Total insert Attempt................: ' + Onboarding_SurveyAttempt + '\n';
            body += 'Total Survey inserts................: ' + iSurveySummaryNum + '\n\n';
            body += ' +++++++++++         ERRORS            ++++++++++++++++++\n';
            body += 'Errors..............................: ' + lsErrorLogs.size() + '\n\n';
            body += ' +++++++++++ QUERY  ++++++++++++++++++\n' +sQuery;

        SYSTEM.DEBUG('Body ===='+body); 
        //mail.setPlainTextBody(body); 
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
    for(Error_Log__c errorLog : lsErrorLogs)
    {
       body += '- ' + errorLog.Error__c + '\n';
    }
    if(lsErrorLogs.size() > 0) 
    {
      if(!String.isBlank(Onboarding_EmailsError))
      {   
        if(!String.isBlank(Onboarding_Emails))
        {
          Onboarding_EmailsError = Onboarding_Emails+';' + Onboarding_EmailsError;
        }
        toAddresses =   Onboarding_EmailsError.split(';');
        mail.setToAddresses(toAddresses);
      }
      mail.setSubject(' -  ERRORS - '+ Onboarding_Batch +  ' - Survey  Batch ' + a.Status);
      SYSTEM.DEBUG('Onboarding_come BM survey FINISH ==== ERRORS');
    }
    if(lsErrorLogs.size() > 3)
    {
      body += 'Please refer to full overview of the errors . ';// + cpPortalUtil.getPortalConfigItem('OutboundSummaryListView');   
    }
    //SYSTEM.DEBUG('Onboarding_come BM survey FINISH ===='+ toAddresses);
    mail.setPlainTextBody(body);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 
  }
  
}