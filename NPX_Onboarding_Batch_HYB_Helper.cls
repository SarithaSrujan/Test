/**********************************************************************
Name                :NPX_Onboarding_Batch_HYB_Helper
Other class used    : None
Tested in class     : NPX_Onboarding_Batch_HYB_Test
++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Purpose:
   /Helper class for NPX_ONBOARDING_batch_HYB_class
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
History
--------
Version       Author       Date              Details
  1.0        Saritha      25/5/2018        Initial development

*************************************************************************/
//Helper class for NPX_ONBOARDING_batch_HYB_class
public with sharing class NPX_Onboarding_Batch_HYB_Helper{
  public static list<NPX_Survey_Record__c> insertNpxSurveyRecords (List<npx_surveys__c> lsnpxsurvey,Map <string ,string> mapKey_Value,list<contract__c> scope,list<string> listContactFunctions)
  {
    system.debug('@@@@ Scope'+Scope);
    system.debug('@@@@ lsnpxsurvey'+lsnpxsurvey);
    system.debug('@@@@ mapKey_Value'+mapKey_Value);
    system.debug('@@@@ listContactFunctions'+listContactFunctions);
    boolean isHOA = false;
    boolean isBM = false;
    boolean isALL = false;
    string SurveyMethodName = 'OnBoarding_';
    string onBoarding_Batch = mapKey_Value.get('Onboarding_Technical_BatchName');
    //string onBoarding_SurveymethodName = 'OnBoarding_Batch';  
    //string onBoarding_SurveyNumber=mapKey_Value.get('Onboarding_Survey_Number');
    //string onBoarding_SurveyStatus= mapKey_Value.get('Onboarding_survey_Initial_Status');
    string onBoarding_ContactFunction = mapKey_Value.get('Contact_Function');

    if (Onboarding_ContactFunction == null || Onboarding_ContactFunction == '')Onboarding_ContactFunction = 'ALL';

    string onBoarding_ContactActive = mapKey_Value.get('Contact_Active');
    string onBoarding_ContactDonotSurvey= mapKey_Value.get('Contact_Donotsurvey');
    string onBoarding_ContactRole= mapKey_Value.get('Service_Contract_Contact_Role');
    string onboarding_contactOwner_Region= mapKey_Value.get('Contact_Owner_Region');
    string onBoarding_SurveyDefaultMethod =mapKey_Value.get('Survey_Default_Method');
    //Account
    string onBoarding_AccCustGroup= mapKey_Value.get('Account_Customer_Group');
    string onBoarding_AccMarketsegment= mapKey_Value.get('Account_Market_Segment');
    string onBoarding_AccCustsegment= mapKey_Value.get('Account_Customer_Segment');
    string onBoarding_ServiceContractOrderreason= mapKey_Value.get('Service_Contract_OrderReasons');
    //string onBoarding_ServiceOrder= mapKey_Value.get('ServiceOrder_Finish_date');
    
    
    list<Npx_Survey_Record__c> lsnpxsurveyrecords = new list<Npx_Survey_Record__c>();
    list<string> listContact_Function = new list<String>();
    List < String > listAccountCustomerGroup;
    List < String > listAccountCustomerType;
    List < String > listAccountMarketSegment;
    List < String > listAccountCustsegment;
    List < String > listcontactOwner_Region;
    List < String > listContactRoles;
    List < String > listserviceContractorderreason;

    String sWhereClause_ContactFunction = ' ';
    string sWhereClause_AccountCustsegment = ' ';
    Map < String, Equipment_Contract__c> mapContractEquipment = new Map < String, Equipment_Contract__c > ();//map with sap number +00 and contract
   //Map < Id, Service_Order__c > mapEquipmentServiceOrder = new Map < Id, Service_Order__c >> ();
    Npx_Survey_Record__c surveyrecords = new Npx_Survey_Record__c();
    List<NPX_Survey_Record__c> lsnpxRecordssurvey = new List<NPX_Survey_Record__c>();//list to insert npx_survey_records

    if ( Onboarding_ContactFunction <> 'ALL'){
    if (listContactFunctions.size() > 0) 
    {
      sWhereClause_ContactFunction = ' and Contact__r.Function__c in : listContactFunctions';
// CR00038991 : JAN 2019 :START

     // for (String contact_Function: listContactFunctions) {
          //if (contact_Function == 'Building Manager') {
          //    isBM = true;
          //}

          //if (contact_Function == 'Head of Tenants') {
          //    isHOA = true;
          //}
          // NEW 2018 June release

          
          //if (contact_Function != 'Head of Tenants' && contact_Function != 'Building Manager') {
          //    isALL = true;
          //    sWhereClause_ContactFunction = '';
          //    
              //sWhereClause_AccountCustsegment='';
          //}

      //}
      // CR00038991 : JAN 2019 :END
    }
    }
    
    system.debug('@@@@ sWhereClause_ContactFunction'+sWhereClause_ContactFunction);
    //Branch__c populating field
    set<id> setusers = new set<id>();//Branch__c population
    // Get all Original SAP number from custom Object
    //step1: to get equipment and contracts under the scope
    //out put map of equipment id,contract id
    Set < String > setSapContractNumber = new Set < String > ();
    set<id> setequipmentid = new set<id>();
    string sSapOrigNum;
    map<id,id> mapequipment_contract = new map<id,id>();
    for(contract__c contract : scope)
    {
      //setequipmentid.add(contract.Equipments__r);
      setusers.add(contract.ownerid); 
      for(Equipment__c equip:contract.Equipments__r)
        {
          mapequipment_contract.put(equip.id,contract.id);
          setequipmentid.add(equip.id); 

        }
      
    }
    system.debug('@@@@ mapequipment_contract'+mapequipment_contract);
    system.debug('@@@@ setequipmentid'+setequipmentid);
    //step 2: identifying equipment with one service orderby aggragate query
    //step output:set of equipment
    string onboarding_serviceorderFinishdate = mapKey_Value.get('ServiceOrder_Finish date');
    string onboarding_serviceorderSAPstatus = mapKey_Value.get('ServiceOrder_SAP_Status');
    string onboarding_serviceorderKonnect = mapKey_Value.get('ServiceOrder_KONNECT_Status');
    string onboarding_serviceorderActivitycode =mapKey_Value.get('ServiceOrder_ActivityType_Code');
    system.debug('@@@@ onboarding_serviceorderSAPstatus'+onboarding_serviceorderSAPstatus);
    system.debug('@@@@ onboarding_serviceorderKonnect'+onboarding_serviceorderKonnect);
    string onboarding_serviceorderType =mapKey_Value.get('ServiceOrder_Type');
    string Onboarding_AdditionalFilter1 = mapKey_Value.get('Additional_Filter1'); 
    string Onboarding_AdditionalFilter2 = mapKey_Value.get('Additional_Filter2'); 
    
    // service order finish filter
    //changes on SAP and  Konnect filtering on service order 
    //if both sap status and konnect exist it should consider any one value(SAP OR Konnect)
    //if not any one value exist then it should filter on that value
    ////service order on SAP status 
    string sWhereClause_serviceorderSAPStatus;
    if (!String.isEmpty(onboarding_serviceorderSAPstatus))
    {
      list<string> listserviceorderSAPAtatus = onboarding_serviceorderSAPstatus.split('\\|');
         sWhereClause_serviceorderSAPStatus ='   SAP_STATUS__c IN :listserviceorderSAPAtatus ';
    }
    
    ////service order on Konnect status
    string sWhereClause_serviceorderKonnect;
    if (!String.isEmpty(onboarding_serviceorderKonnect))
    {
      list<string> listserviceorderKonnect = onboarding_serviceorderKonnect.split('\\|');
      sWhereClause_serviceorderKonnect = '   KONECT_STATUS__c IN :listserviceorderKonnect ';
             
    }
    system.debug('@@@@ sWhereClause_serviceorderSAPStatus'+sWhereClause_serviceorderSAPStatus);
    system.debug('@@@@ sWhereClause_serviceorderKonnect'+sWhereClause_serviceorderKonnect);
    
    //service order on SAP status  and konnect
    String sWhereClause_ServiceOrderSAP_or_KONNECT = ' ';
    if ((!String.isEmpty(onboarding_serviceorderKonnect)) && (!String.isEmpty(onboarding_serviceorderSAPstatus)))
    {
      sWhereClause_ServiceOrderSAP_or_KONNECT = ' And (' + sWhereClause_serviceorderSAPStatus +'OR' + sWhereClause_serviceorderKonnect + ')' ;
    }
    else
    {
      if (!String.isEmpty(sWhereClause_serviceorderKonnect))
      {
        sWhereClause_ServiceOrderSAP_or_KONNECT = ' and ' + sWhereClause_serviceorderKonnect ;     
      }
      else
      {
        if (!String.isEmpty(sWhereClause_serviceorderSAPStatus))     
        {
          sWhereClause_ServiceOrderSAP_or_KONNECT = ' and ' + sWhereClause_serviceorderSAPStatus ;     
        }
      }
    }
    system.debug('@@@@ sWhereClause_ServiceOrderSAP_or_KONNECT'+sWhereClause_ServiceOrderSAP_or_KONNECT);
    //service order Activity code 
     string sWhereClause_serviceorderActivitycode =' ';
    if (!String.isEmpty(onboarding_serviceorderActivitycode))
    {
      list<string> listserviceorderActivitycode = onboarding_serviceorderActivitycode.split('\\|');
      sWhereClause_serviceorderActivitycode = ' and  ACTIVITY_TYPE_CODE__c IN :listserviceorderActivitycode  ';
    }
    //service_Order_type CR00007770
    string sWhereClause_serviceorder_Type = ' ';
    if (!String.isEmpty(onboarding_serviceorderType))
    {
      list<string> listserviceorderType = onboarding_serviceorderType.split('\\|');
         sWhereClause_serviceorder_Type ='   and TYPE__c IN :listserviceorderType ';
    }
    set<id> setequipFilter = new set<id>();
    string squery;
    squery = 'Select Count(id) totalequips,equipment__c from Service_Order__c';
    squery = squery+' where Equipment__c In: setequipmentid and Survey_Attempt_Onboard_Date__c = Null and ' + onboarding_serviceorderFinishdate;
    //if(onboarding_serviceorderType != null){
    //  squery = squery + ' ' +onboarding_serviceorderType; 
    //}
    squery = squery + ' ' +sWhereClause_ServiceOrderSAP_or_KONNECT;
    squery = squery + ' ' + sWhereClause_serviceorderActivitycode;
    squery = squery + ' ' +sWhereClause_serviceorder_Type; 
    if(Onboarding_AdditionalFilter1 != null){
      squery = squery + ' ' + Onboarding_AdditionalFilter1;
    }
    if(Onboarding_AdditionalFilter2 != null){
      squery = squery + ' ' + Onboarding_AdditionalFilter2;
    }
    squery = squery+' GROUP BY Equipment__c ';
    system.debug('@@@@ query'+squery);
    
    //AggregateResult[] groupResults = [ select  Equipment__c, Count(id) totalequips  from service_order__c  where Equipment__c in: setequipmentid and Finished_date__c = TODAY GROUP BY Equipment__c ];
    AggregateResult[] groupResults = Database.query(squery);
    system.debug('@@@@ groupResults'+groupResults);
    for(AggregateResult agrRes : groupResults)
    {  
      system.debug('totalequips'+(Integer) agrRes.get('totalequips'));   
     if((Integer) agrRes.get('totalequips')==1) 
        setequipFilter.add((Id)agrRes.get('Equipment__c'));
    }
    system.debug('@@@@ setequipFilter'+setequipFilter);
    //step 3: getting contract equipment info
    //step output:map(equipment,contract) 

    list<Equipment_contract__c> lsequipcontract = [select Contract__r.id,Equipment__r.id,Equipment__r.Name,Equipment__r.Address_Street__c,Equipment__r.City__c, Equipment__r.Workcenter__c,
                                                  Equipment__r.Post_Code__c,Equipment__r.Plant_section__c,Equipment__r.Planner_group__c,Equipment__r.Kone_Country__c,Equipment__r.Equipment_location__c,Equipment__r.Equipment_Type__c,
                                                  Equipment__r.Equipment_Type_description__c,Contract__r.OwnerId,contract__r.SAP_ORIGINAL_NUMBER__c,contract__r.Name,Contract__r.Contract_Start_Date__c,Contract__r.Contract_Type__c,Contract__r.Document_Type__c,Contract__r.Market_segment__c,Contract__r.Renewal_date__c,Contract__r.sales_Office__c,Contract__r.Sales_Group__c,Contract__r.Sales_organization__c, Contract__r.Contract_Order_Reason__c  from Equipment_contract__c where Equipment__r.id IN:setequipFilter];
    
    map<id,id> mapEquipcontract = new map<id,id>();
    //map<id,string> mapEquipcontractsapnumber = new map<id,string>();
    map<string,string> mapEquipcontractsapnumber = new map<string,string>();

    for(Equipment_contract__c ec:lsequipcontract){
      mapEquipcontract.put(ec.Equipment__c,ec.contract__c);
      string sapnumber = ec.contract__r.SAP_ORIGINAL_NUMBER__c;
      system.debug('@@@@ sapnumber'+sapnumber);
      if(sapnumber!= Null)
      {
        String s1 = sapnumber.substring(0,1) ;
        if (s1.isalpha() == false ) 
        sSapOrigNum  = '00' + sapnumber;
      //string sapnumber = ec.contract__r.SAP_ORIGINAL_NUMBER__c;
        mapContractEquipment.put(sSapOrigNum,ec);
      }
      //mapEquipcontractsapnumber.put(ec.Equipment__c,ec.contract__r.SAP_ORIGINAL_NUMBER__c);
      mapEquipcontractsapnumber.put(String.valueOf(ec.Equipment__c) + String.valueOf(ec.contract__c),ec.contract__r.SAP_ORIGINAL_NUMBER__c);
    }
    system.debug('@@@@mapEquipcontract'+mapEquipcontract);
    system.debug('@@@@ lsequipcontract'+lsequipcontract);
    system.debug('@@@@ mapContractEquipment'+mapContractEquipment);
    system.debug('@@@@ mapEquipcontractsapnumber'+mapEquipcontractsapnumber);
    string squery1;
    squery1 = 'Select id,equipment__c,Equipment__r.contract__c,Finished_date__c,Name,Fitter_name__c, Fitter_Number__c,Description__c,Job_Description__c from Service_Order__c';
    squery1= squery1+' where Equipment__c In: setequipmentid and Survey_Attempt_Onboard_Date__c = Null and ' + onboarding_serviceorderFinishdate;
    
    squery1 = squery1 + ' ' + sWhereClause_ServiceOrderSAP_or_KONNECT;
    //squery = squery1 + ' ' + sWhereClause_serviceorderKonnect;
    squery1 = squery1 + ' ' + sWhereClause_serviceorderActivitycode;
    system.debug('@@@@ squery1'+squery1);
    list<service_order__c> listServiceOrders = Database.query(squery1);
    system.debug('@@@@ listServiceOrders'+listServiceOrders);
    //step 4: getting service order linked to filtered equipments
    //step output:map(equipment,service order)
    map<string,service_order__c> mapEquipmentServiceOrder = new map<string,service_order__c>();
    //To set the fitter email for the report - Aug 2018 release
    Map<Id, String> mapFitterNumber = new Map<Id, String>();
    Map<String, String> mapFitterEmail = new Map<String, String>();

    for(service_order__c service :listServiceOrders){
      mapEquipmentServiceOrder.put(String.valueOf(service.Equipment__c) + String.valueOf(service.Equipment__r.contract__c),service);
      if(service.Fitter_Number__c != null)
      mapFitterNumber.put(service.Id, service.Fitter_Number__c);
    }
    //CR00037505---populate the fitter email from employee_id__c 2018 dec release
    mapFitterEmail = Npx_CX_Util.getFitterEmail(mapFitterNumber);
    system.debug(mapFitterEmail);
    system.debug('@@@@ mapEquipmentServiceOrder'+mapEquipmentServiceOrder);

      //for(Employee__c employee :[select Email__c , Employee_id__c from Employee__c where Employee_id__c in :mapFitterNumber.values()])
      //{
      //    mapFitterEmail.put(employee.Employee_id__c, employee.Email__c);
      //}

    //step 5:get filtered contract set by 
    //merging map3 and map 4
    //output:set of sap numbers
    //
     set<string> setSapNumberfilter = new set<string>();

    for (string key : mapEquipmentServiceOrder.keySet()) {
      string sapnumber = mapEquipcontractsapnumber.get(key);

      if(sapnumber!= Null)
      {
        sSapOrigNum =  sapnumber;
        String s1 = sapnumber.substring(0,1) ;
        if (s1.isalpha() == false ) 
        sSapOrigNum = '00' + sSapOrigNum;
        setSapNumberfilter.add(sSapOrigNum);
        // verify there are 10 digits - new object has sap number = text(10)
        //mapContractEquipmentContract.put(sSapOrigNum,equipcontract); 
        system.debug('@@@@ '+mapContractEquipment.get(sSapOrigNum ));
        mapContractEquipment.put(sSapOrigNum,mapContractEquipment.get(sSapOrigNum));  
        }
      }
      system.debug('@@@@ setSapNumberfilter'+setSapNumberfilter);
      system.debug('@@@@ mapContractEquipment'+mapContractEquipment);
    ////Branch__c population needs user id 
    Map<Id,String> mapOwnerToRegion = new Map<Id,String>();
    for(User u : [SELECT id,Region__c from User where id In: setusers]){
      if(u.region__c != Null){
        mapOwnerToRegion.put(U.Id,u.region__c);
      }
    }
    system.debug('@@@@ mapOwnerToRegion' +mapOwnerToRegion);
    //to do get the first service order linked with equipment 

    // Contact Active
    string sWhereClause_ContactActive = ' ';
    if (!String.isEmpty(onBoarding_ContactActive))
      sWhereClause_ContactActive = ' and Contact__r.Active__c = ' + onBoarding_ContactActive;

    // Contact Do not Survey
    string sWhereClause_ContactDoNotSurvey = ' ';
    if (!String.isEmpty(onBoarding_ContactDonotSurvey))
      sWhereClause_ContactDoNotSurvey = ' and Contact__r.Do_not_survey__c = ' + onBoarding_ContactDonotSurvey;

    //contact owner region june 2018
    string sWhereClause_ContactOwnerRegion = ' ';
    if (!String.isEmpty(onboarding_contactOwner_Region))
    {
      listcontactOwner_Region = onboarding_contactOwner_Region.split('\\|');
      sWhereClause_ContactOwnerRegion = ' and Contact__r.Owner.Region__c IN : listcontactOwner_Region';
    }
    string sWhereClause_ContactRole = ' ';
    if (!String.isEmpty(onBoarding_ContactRole)) {
      listContactRoles = onBoarding_ContactRole.split('\\|');
      sWhereClause_ContactRole = ' and Role__c in : listContactRoles';
    }
    //should filter on account customer segment,market segment ,contact owner region 


    // Account Customer Group
    string sWhereClause_AccountCustomerGroup = ' ';
    if (!String.isEmpty(onBoarding_AccCustGroup)) {
      listAccountCustomerGroup = onBoarding_AccCustGroup.split('\\|');
      system.debug('@@@@ listAccountCustomerGroup'+listAccountCustomerGroup);
      sWhereClause_AccountCustomerGroup = ' and Contact__r.Account.Customer_Group__c IN : listAccountCustomerGroup '; // 'Core 3' ;
    }
    //Account market segment june 2018
    string sWhereClause_AccountMarketSegment = ' ';
    if (!String.isEmpty(onBoarding_AccMarketsegment)) {
      listAccountMarketSegment = onBoarding_AccMarketsegment.split('\\|');
      system.debug('@@@@ listAccountMarketSegment'+listAccountMarketSegment);
      sWhereClause_AccountMarketSegment = ' and Contact__r.Account.Industry_Segment__c IN : listAccountMarketSegment '; // 'Core 3' ;
    }
    //Account customer segment june 2018
    
    if (!String.isEmpty(onBoarding_AccCustsegment)) {
      listAccountCustsegment = onBoarding_AccCustsegment.split('\\|');
      system.debug('@@@@ listAccountCustsegment'+listAccountCustsegment);
      sWhereClause_AccountCustsegment = ' and Contact__r.Account.Customer_Type__c IN : listAccountCustsegment '; // 'Core 3' ;
    }
    //should filter on service contract order reason
    string sWhereClause_ServiceContractOrderreason = ' ';
    if (!String.isEmpty(onBoarding_ServiceContractOrderreason)) {
      listserviceContractorderreason = onBoarding_ServiceContractOrderreason.split('\\|');
      system.debug('@@@@ listserviceContractorderreason'+listserviceContractorderreason);
      sWhereClause_ServiceContractOrderreason = ' and Service_Contract__r.Order_Reason__c IN : listserviceContractorderreason '; // 'Core 3' ;
    }
    

    string sWhereCause_SapOrigNum = ' and Service_Contract__r.Contract_SAP_Number__c  in : setSapNumberfilter ';
    // Get All contacts from custom object ContactServiceContractJunction__c
    // This custom object is child of standard object ServiceContract
    // Contact Role   
    
    //system.debug('@@@@ listAccountCustomerType' +listAccountCustomerType);
    system.debug('@@@@ listAccountCustomerGroup' +listAccountCustomerGroup);
    system.debug('@@@@@ listContactRoles'+listContactRoles);
    //setSapContractNumber
    String sContactnAccountquery;
    sContactnAccountquery = 'select id,name,Role__c, Contact__r.name ,Contact__r.FirstName, Contact__r.LastName,';
    sContactnAccountquery = sContactnAccountquery + ' Contact__r.Function__c, Contact__r.Preferred_Language__c,';
    sContactnAccountquery = sContactnAccountquery + ' Contact__r.Email,Contact__r.Phone, Contact__r.MobilePhone,';
    sContactnAccountquery = sContactnAccountquery + ' Contact__r.Do_not_survey__c,  Contact__r.Active__c,Contact__r.Owner.Region__c,';
    sContactnAccountquery = sContactnAccountquery + ' Contact__r.OwnerId, Contact__r.Owner.Email,  Contact__r.Salutation,';
    sContactnAccountquery = sContactnAccountquery + ' Contact__r.Account.id,Contact__r.Account.name, Contact__r.Account.accountnumber, Contact__r.Account.Customer_Group__c, ';
    sContactnAccountquery = sContactnAccountquery + ' Contact__r.Account.account__c, Contact__r.Account.Industry_Segment__c, Contact__r.Account.Customer_Type__c,Contact__r.Account.Main_Business_Type__c,';
    sContactnAccountquery = sContactnAccountquery + ' Service_Contract__c,Service_Contract__r.Contract_SAP_Number__c from ContactServiceContractJunction__c  ';
    sContactnAccountquery = sContactnAccountquery + ' where  id<> null';
    // make all where clause as optional --to do
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereClause_ContactActive;
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereClause_ContactDoNotSurvey;
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereClause_ContactRole;
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereClause_ContactFunction;
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereClause_ContactOwnerRegion;
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereClause_AccountCustomerGroup;
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereClause_AccountMarketSegment;
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereClause_AccountCustsegment;    
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereCause_SapOrigNum;
    sContactnAccountquery = sContactnAccountquery + ' ' + sWhereClause_ServiceContractOrderreason;

    //// todo from here 
    SYSTEM.DEBUG(' @@@@  sContactnAccountquery ' + sContactnAccountquery);
    // Get Contact and Account details
    ContactServiceContractJunction__c[] listContactnAccounts = new List < ContactServiceContractJunction__c > ();
    listContactnAccounts = Database.query(sContactnAccountquery);

    SYSTEM.DEBUG('@@@@ - ContactServiceContractJunction__c size = ' + listContactnAccounts.size());
    SYSTEM.DEBUG('@@@@ - ContactServiceContractJunction__c  = ' + listContactnAccounts);
    // loop through listContactnAccounts to fill in survey
    // contact and account from ContactServiceContractJunction__c
    // 3 maps needed
    // map 1   contract from ServiceContract , equipment contract object
    // map 2   equiment , service order object
    if(listContactnAccounts.size() > 0){
      for (ContactServiceContractJunction__c objServiceContract_Contact: listContactnAccounts) {
        system.debug('@@@@ contact junction object ids' +objServiceContract_Contact.id);
        system.debug('@@@@ objServiceContract_Contact.Service_Contract__r.Contract_SAP_Number__c = ' +objServiceContract_Contact.Service_Contract__r.Contract_SAP_Number__c );
        system.debug('@@@@ objServiceContract_Contact.Service_Contract__r.Contract_SAP_Number__c'+mapContractEquipment.get(objServiceContract_Contact.Service_Contract__r.Contract_SAP_Number__c));
        
        if (mapContractEquipment.get(objServiceContract_Contact.Service_Contract__r.Contract_SAP_Number__c)!= NULL){
          system.debug('@@@@@');
          Equipment_Contract__c objEquipContract4Contact = mapContractEquipment.get(objServiceContract_Contact.Service_Contract__r.Contract_SAP_Number__c);
          system.debug('@@@@ objEquipContract4Contact'+objEquipContract4Contact);
          //retriving salesorg of contract to get the survey method
          string sContractSalesOrg;
          sContractSalesOrg = objEquipContract4Contact.Contract__r.Sales_Organization__c;   
          //calling npx_cx_util class for survey method
          string sSurveyMethod4Contact = NPX_CX_Util.getNpxGenSurveyMethod(SurveyMethodName, sContractSalesOrg);
          if ((String.isEmpty(sSurveyMethod4Contact)) &&
              (!String.isEmpty(onBoarding_SurveyDefaultMethod))) sSurveyMethod4Contact = onBoarding_SurveyDefaultMethod;
          if (sSurveyMethod4Contact == 'Email') 
          {
              // if no email id exists then try SMS
              if (objServiceContract_Contact.Contact__r.Email == null) 
              {
                  sSurveyMethod4Contact = '';
                  if (objServiceContract_Contact.Contact__r.Mobilephone != null) 
                  sSurveyMethod4Contact = 'SMS';
              }
          }
          if (sSurveyMethod4Contact == 'SMS') 
          {
              if (objServiceContract_Contact.Contact__r.Mobilephone == null) 
              {
                  sSurveyMethod4Contact = '';
                  if (objServiceContract_Contact.Contact__r.Email != null) 
                  sSurveyMethod4Contact = 'Email';
              }
          }
          if (sSurveyMethod4Contact == 'Phone') {
              //phone is mandatory on contact nothing to check
          }
          
          surveyrecords = SurveyRecordsinserted(lsnpxsurvey,mapKey_Value,mapOwnerToRegion,objServiceContract_Contact,sSurveyMethod4Contact,objEquipContract4Contact, mapEquipmentServiceOrder, mapFitterEmail);
          lsnpxRecordssurvey.add(surveyrecords);
          system.debug('@@@@ lsnpxRecordssurvey'+lsnpxRecordssurvey.size());
        }//end of if map 

      }//end of for con junction object

    }//end if listcontact
    return lsnpxRecordssurvey;
  }//end of insert method
  public static Npx_Survey_Record__c SurveyRecordsinserted(List<npx_surveys__c> lsnpxsurvey,Map <string ,string> mapKey_Value,Map<Id,String> mapOwnerToRegion,ContactServiceContractJunction__c objServiceContract_Contact,string sSurveyMethod4Contact,Equipment_Contract__c objEquipmentContract4Survey,map<string,service_order__c> mapEquipmentServiceOrder, Map<String, String> mapFitterEmail)
  {
      //list<Npx_Survey_Record__c> lsnpxsurveyrecords = new list<Npx_Survey_Record__c>();
        //system.debug('@@@@ listContactAccounts'+listContactAccounts);
        system.debug('@@@@enter');
        string OnboardingBatch = mapKey_Value.get('Technical_BatchName');
        string OnboardingSurveymethodName = 'Onboarding_Batch'; 
        string OnboardingSurveyNumber=mapKey_Value.get('Survey_Number');
        string OnboardingSurveyStatus= mapKey_Value.get('Survey_Initial_Status');
        string OnboardingContactFunction = mapKey_Value.get('Service_Contract_Contact_Function');
        string OnboardingSurveyDefaultMethod =mapKey_Value.get('Survey_Default_Method');
        String sSalesOrg = objEquipmentContract4Survey.Contract__r.Sales_Organization__c;
        String sSalesOffice= objEquipmentContract4Survey.Contract__r.Sales_Office__c;
        //map for unique 
        Map<string,Contact > mapContactAccount = new Map<string,Contact >();
        //Map <string,string> mapEscalationEmail = new map<string,string>();
        //mapEscalationEmail = NPX_CX_Util.getNpxCEscalationMatrix();//Esclation matrix changes forseen
        Map <string,NPX_Action_Owner__c> mapEscalationOwnerDetails = new map<string,NPX_Action_Owner__c>();
        mapEscalationOwnerDetails = NPX_CX_Util.getNpxEscalationOwnerMap(); 
        system.debug('@@@@ saritha esc'+mapEscalationOwnerDetails);// 2018 March Release:Som
        List<NPX_Survey_Record__c> surveyList = new List<NPX_Survey_Record__c>(); 
        Map<string,NPX_Action_Owner__c > mapFollowUpOwner = new Map<string,NPX_Action_Owner__c >();
        NPX_Survey_Record__c surveyData = new NPX_Survey_Record__c();
        surveyData.Survey_Method__c = sSurveyMethod4Contact;
        surveyData.Extract_date__c = System.today();
        surveyData.Batch_Name__c = OnboardingBatch;
        system.debug('');
        surveyData.SurveyID__c = lsnpxsurvey[0].id;

        system.debug('@@@@  OnboardingSurveyNumber'+ OnboardingSurveyNumber); //Feb 2018
        surveyData.Survey_ID__c = OnboardingSurveyNumber; //Feb 2018
        surveyData.DataCollectionId__c = OnboardingSurveyNumber;
        String SurveyName = '';
        if (surveyData.Survey_ID__c != '')
            //SurveyName= mapSurveyIdToSurveyName.get(surveyData.Survey_ID__c); 
            surveyData.DataCollectionName__c = lsnpxsurvey[0].NPX_Survey_Name__c;
            surveyData.Status__c = OnboardingSurveyStatus;
            //-------------------------
        //GUI - Account & ContactInfo
        //-------------------------

        //***************//
        //Account data   //
        //***************//
        surveyData.Account__c = objServiceContract_Contact.Contact__r.Account.Id;
        surveyData.Account_Number__c = objServiceContract_Contact.Contact__r.Account.AccountNumber;
        surveyData.Account_Name__c = objServiceContract_Contact.Contact__r.Account.Name;
        surveyData.Customer_Group__c = objServiceContract_Contact.Contact__r.Account.Customer_Group__c;
           surveyData.Account_customer_segment__c = objServiceContract_Contact.Contact__r.Account.Customer_Type__c;//july release CR00005436
        Surveydata.Main_Business_Type__c = objServiceContract_Contact.Contact__r.Account.Main_Business_Type__c;
        if (objServiceContract_Contact.Contact__r.Account.Industry_Segment__c != Null) surveyData.Market_Segment__c = objServiceContract_Contact.Contact__r.Account.Industry_Segment__c;
        //Contact data
        surveyData.Contact_Function__c = objServiceContract_Contact.Contact__r.Function__c;
        surveyData.Contact__c = objServiceContract_Contact.Contact__r.Id;
        surveyData.NPX_Contact_Record_ID__c = objServiceContract_Contact.Contact__r.Id;
        surveyData.Contact_Owner_Region__c = objServiceContract_Contact.Contact__r.Owner.Region__c;
        if (objServiceContract_Contact.Contact__r.OwnerId != Null) surveyData.ContactOwner__c = objServiceContract_Contact.Contact__r.OwnerId;
        if (objServiceContract_Contact.Contact__r.Salutation != Null) surveyData.Salutation__c = objServiceContract_Contact.Contact__r.Salutation;
        if (objServiceContract_Contact.Contact__r.FirstName != Null) surveyData.First_name__c = objServiceContract_Contact.Contact__r.FirstName;
        if (objServiceContract_Contact.Contact__r.FirstName == Null) surveyData.First_name__c = '.';
        surveyData.Branch__c = mapOwnerToRegion.get(objEquipmentContract4Survey.Contract__r.OwnerId);
        surveyData.Last_name__c = objServiceContract_Contact.Contact__r.LastName;
        surveyData.Contact_Name__c = objServiceContract_Contact.Contact__r.Name;//july release CR0006086
        surveyData.Service_Contract_Contact_Role__c = objServiceContract_Contact.Role__c;//july release CR0006086
        surveyData.Service_Contract__c = objServiceContract_Contact.Service_Contract__r.id;//Aug 2018 CR00006819
        if (objServiceContract_Contact.Contact__r.Email != Null) surveyData.Email__c = objServiceContract_Contact.Contact__r.Email;
        if (objServiceContract_Contact.Contact__r.Phone != Null) surveyData.Phone__c = objServiceContract_Contact.Contact__r.Phone;
        if (objServiceContract_Contact.Contact__r.Mobilephone != Null) surveyData.Mobile_Phone__c = objServiceContract_Contact.Contact__r.Mobilephone;
        if (objServiceContract_Contact.Contact__r.Preferred_Language__c != Null)
        surveyData.Preferred_Language__c = objServiceContract_Contact.Contact__r.Preferred_Language__c;
        //-------------------------
        //GUI Contract & Equipment
        //-----------------------
        // Contract data
        surveyData.Contract__c = objEquipmentContract4Survey.Contract__r.id;
        surveyData.Contract_Name__c = objEquipmentContract4Survey.Contract__r.Name;
        surveyData.Sales_Organization__c = sSalesOrg;
        surveyData.Contract_Start_Date__c = objEquipmentContract4Survey.Contract__r.Contract_Start_Date__c;
        surveyData.Contract_Type__c = objEquipmentContract4Survey.Contract__r.Contract_Type__c;
        surveyData.Contract_doc_type__c = objEquipmentContract4Survey.Contract__r.Document_Type__c;//july release CR00005436
        surveyData.Contract_Market_Segment__c = objEquipmentContract4Survey.Contract__r.Market_segment__c;
        if (objEquipmentContract4Survey.Contract__r.Renewal_date__c != Null) surveyData.Renewal_Date__c = objEquipmentContract4Survey.Contract__r.Renewal_date__c;
        if (objEquipmentContract4Survey.Contract__r.Sales_Office__c != Null) surveyData.Sales_Office__c = objEquipmentContract4Survey.Contract__r.sales_Office__c;
        if (objEquipmentContract4Survey.Contract__r.Sales_Group__c != Null) surveyData.Sales_Group__c = objEquipmentContract4Survey.Contract__r.Sales_Group__c;
        // Equipment data
        String SupervisorKey;
        //String SupervisorKey;
        //Boolean EquipAllow = false;
        //if (objEquipmentContract4Survey.Equipment__c.size()> 0) EquipAllow = true;
        system.debug('@@@@ objEquipmentContract4Survey.Equipment__c'+objEquipmentContract4Survey.Equipment__c);
        //if ( (objEquipmentContract4Survey.Equipment_contracts__r.size()> 0 ) && (Test.isRunningTest()) ) 
        //EquipAllow = false;
          //Equipment__c equip = objEquipmentContract4Survey.Equipment__c;
          // Only one equipment from the list needed per contract
          //SYSTEM.DEBUG ( ' EQUIPMENT = '+equip);          
            surveyData.EquipmentNumber__c=objEquipmentContract4Survey.Equipment__r.Id;
            surveyData.Equipment_Name__c = objEquipmentContract4Survey.Equipment__r.Name;
            if(objEquipmentContract4Survey.Equipment__r.Address_Street__c !=Null)surveyData.Address_Street__c=objEquipmentContract4Survey.Equipment__r.Address_Street__c;
            if(objEquipmentContract4Survey.Equipment__r.City__c !=Null)surveyData.City__c=objEquipmentContract4Survey.Equipment__r.City__c;
            if(objEquipmentContract4Survey.Equipment__r.Post_Code__c !=Null)surveyData.Post_Code__c=objEquipmentContract4Survey.Equipment__r.Post_Code__c;
            if(objEquipmentContract4Survey.Equipment__r.Plant_section__c !=Null)surveyData.Plant_section__c=objEquipmentContract4Survey.Equipment__r.Plant_section__c;
            if(objEquipmentContract4Survey.Equipment__r.Planner_group__c !=Null)surveyData.Planner_group__c=objEquipmentContract4Survey.Equipment__r.Planner_group__c;
            if(objEquipmentContract4Survey.Equipment__r.Kone_Country__c !=Null)surveyData.Kone_Country__c=objEquipmentContract4Survey.Equipment__r.Kone_Country__c;
            SupervisorKey = objEquipmentContract4Survey.Equipment__r.Plant_section__c + objEquipmentContract4Survey.Equipment__r.Planner_group__c;
            if(objEquipmentContract4Survey.Equipment__r.Equipment_location__c !=Null)
            { 
              surveyData.Region__c=objEquipmentContract4Survey.Equipment__r.Equipment_location__c;
              surveyData.Equipment_location__c=objEquipmentContract4Survey.Equipment__r.Equipment_location__c;
            }  
              // Get equipment type data - 2017 October release
              if(objEquipmentContract4Survey.Equipment__r.Equipment_Type__c !=Null) surveyData.Equipment_Type__c = objEquipmentContract4Survey.Equipment__r.Equipment_Type__c ;
              if(objEquipmentContract4Survey.Equipment__r.Equipment_Type_description__c !=Null) 
                surveyData.Equipment_Type_description__c = objEquipmentContract4Survey.Equipment__r.Equipment_Type_description__c ;

              //Added on 28/06/2018 - Nermala - 2018 July Release
              if (objEquipmentContract4Survey.Equipment__r.Workcenter__c != Null){
                  surveyData.Workcenter__c = objEquipmentContract4Survey.Equipment__r.Workcenter__c;
              }
              if (objEquipmentContract4Survey.Equipment__r.Kone_Country__c   != Null){
                  surveyData.Equipment_Country__c = objEquipmentContract4Survey.Equipment__r.Kone_Country__c;
              }
        //Escalation Owner details - 
        // From new Object Action Followup Matrix
        //----------------------------------------------------
        NPX_Action_Owner__c EscalationOwnerDetail = new NPX_Action_Owner__c ();

        //sSalesOrg = 'BEL';//for test
        EscalationOwnerDetail = NPX_CX_Util.getNpxEscalationOwnerDetails (mapEscalationOwnerDetails,objEquipmentContract4Survey.Equipment__r.Kone_Country__c,sSalesOrg,objEquipmentContract4Survey.Equipment__r.Equipment_location__c,sSalesOffice, objEquipmentContract4Survey.Equipment__r.Plant_section__c  ); 
        system.debug('@@@@ saritha'+EscalationOwnerDetail);
        if ( EscalationOwnerDetail !=Null)
        {
          String EscSurveyId = EscalationOwnerDetail.SurveyID__c;//April release 2018 checking for SurveyId of NPX_Action_Owner__c
          if((!string.isblank(EscSurveyId ) &&  ( EscSurveyId.contains(onBoardingSurveyNumber) ||  EscSurveyId.contains('Default')))) {
            if ( EscalationOwnerDetail.Escalation_Owner_Email__c !=Null)
            surveyData.Fu_escalation1__c = EscalationOwnerDetail.Escalation_Owner_Email__c;
          }
        }
      
      ////-------------------------------------
      ////Work Order - Not for Welcome Survey
      ////-------------------------------------
      String str = String.valueOf(objEquipmentContract4Survey.Equipment__c) + String.valueOf(objEquipmentContract4Survey.contract__r.id);
      system.debug('@@@@ Saritha'+str);
      
        if (mapEquipmentServiceOrder.keyset().contains(str))
        {
           service_order__c so = mapEquipmentServiceOrder.get(str);
        surveyData.Service_Order__c = so.Id;
        surveyData.Finished_date__c = so.Finished_date__c;
        surveyData.Service_Order_Name__c = so.Name;
        if (so.Fitter_name__c != Null) surveyData.Fitter_name__c = so.Fitter_name__c;

        if(so.Fitter_Number__c != Null){
            surveyData.Fitter_email__c = mapFitterEmail.get(so.Fitter_Number__c);
            surveyData.Fitter_Number__c = so.Fitter_Number__c;
        }

        if (so.Description__c != Null) {
            surveyData.Job_Description__c = so.Description__c;
        }
        else {
          if (so.Job_Description__c != Null)
              surveyData.Job_Description__c = so.Job_Description__c;
        }

            //Added on 28/06/2018 - Nermala - 2018 July Release
            surveyData.Contract_order_reason_description__c = objEquipmentContract4Survey.contract__r.Contract_Order_Reason__c;
        //system.debug(serviceorder);
      
      list<service_order__c> listServiceOrderstoUpdate = new list<service_order__c>();
      //for (Service_Order__c serviceorder : so )
      //  {
          Service_Order__c serviceordertrimed = new Service_Order__c();
          serviceordertrimed.id = so.id;
          serviceordertrimed.Survey_Attempt_Onboard_Date__c = system.now();
          listServiceOrderstoUpdate.add(serviceordertrimed);
          //Database.SaveResult[] src=sObjectsDMLService.updateSObjects( Service_Order__c.sObjectType,listServiceOrderstoUpdate);
        //}
        system.debug('@@@@ listServiceOrderstoUpdate'+listServiceOrderstoUpdate);
      
        
          try{
           if (listServiceOrderstoUpdate.size()> 0 )
           {
              //Update listServiceOrders;
              Database.SaveResult[] src=sObjectsDMLService.updateSObjects( Service_Order__c.sObjectType,listServiceOrderstoUpdate);
              SYSTEM.DEBUG ( ' #### NPX  -- SURVEY RECORDS UPDATED  Total records = '+listServiceOrderstoUpdate.size());
              //ser += listServiceOrderstoUpdate.size();
           }  

          }
      catch (Exception e)
          {                         
          SYSTEM.DEBUG(LoggingLevel.ERROR,'ABSILOG *** Exception - Message : ' + e.getMessage() + 'Line no : ' + e.getLineNumber() + ' getStackTraceString ' + e.getStackTraceString() + '' + e.getCause());
          //errorLog.Log(Onboarding_Batch, 'execute', 'Error for iBM_Man_BatchNum: ' + Onboarding _BatchNum, e);            
          }

        }
          
      //  //survey details
        mapFollowUpOwner = NPX_CX_Util.getNpxFollowUpOwnerMap();
        NPX_Action_Owner__c objectFollowUpOwnerDetail = new NPX_Action_Owner__c();
        if (SupervisorKey != Null) objectFollowUpOwnerDetail = mapFollowUpOwner.get(SupervisorKey);
        if (objectFollowUpOwnerDetail != null && objectFollowUpOwnerDetail.FollowUp_Owner_Email__c != Null) 

        {
          string SurveyId = objectFollowUpOwnerDetail.SurveyID__c;//April release 2018 checking for SurveyId of NPX_Action_Owner__c 
            if(!string.isblank(SurveyId) && SurveyId.contains(OnboardingSurveyNumber))
            {
            surveyData.Supervisor_Email__c = objectFollowUpOwnerDetail.FollowUp_Owner_Email__c;
            if (objectFollowUpOwnerDetail.FollowUp_Owner_FirstName__c != Null || objectFollowUpOwnerDetail.FollowUp_Owner_LastName__c != Null)
                surveyData.Supervisor_Name__c = objectFollowUpOwnerDetail.FollowUp_Owner_Firstname__c + ' ' + objectFollowUpOwnerDetail.FollowUp_Owner_Lastname__c;
          }
        }

        surveyData.Lookup_History__c = Npx_CX_Util.FillLookupHistory(surveyData);
        system.debug('@@@@@ survey data'+surveydata);
       
        system.debug('@@@@ END');
        return surveydata;
  }
}