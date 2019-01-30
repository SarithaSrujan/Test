
/**********************************************************************
Name                :NPX_Onboarding_Batch_HYB_Test
Other class used    : None
Test class for    : NPX_Onboarding_Batch_HYB_BP
++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Purpose:
    Test class for 
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
History
--------
Version       Author       Date              Details
  1.0        Saritha      28/5/2018        Initial development

*************************************************************************/
@isTest
public with sharing class NPX_Onboarding_Batch_HYB_Test {
  final static String  EQUIPMENT_TYPE_BM = '004';
  static string sBatch =  'NPX_GLOBAL_MAINTAINCED_BM';
  static map < string,string > mapNpxConfigMap = new map < string,string >();
  static List<NPX_Config__c> listNPXConfig = new List<NPX_Config__c>();
  
  //@testSetup
    Public static void createTestData() 
    {

        NPX_Cx_TestUtil.insertCountryLists();
        NPX_Cx_TestUtil.createTestAccount('Building Manager');
        NPX_Cx_TestUtil.createTestContact('Building Manager',true,'12345','test@example.com',false);
        NPX_Cx_TestUtil.createTestBuilding();
        NPX_Cx_TestUtil.createTestContract('231','BRU');
        NPX_Cx_TestUtil.createTestEquipment('123','W10');
        NPX_Cx_TestUtil.createTestEquipmentcontract();
        NPX_Cx_TestUtil.createServiceOrder('Z03','01');
        //NPX_Cx_TestUtil.getServiceOrder('Y01','01');
        NPX_Cx_TestUtil.createNPXSalesOrgConfig('Phone','231','BRU');
        NPX_Cx_TestUtil.createTestSurveys('KONE_111467');
        NPX_Cx_TestUtil.createTestServiceContract();
        NPX_Cx_TestUtil.createNPXEsclationActionOwnerConfig('BEL','BEN','KONE_111467');
        NPX_Cx_TestUtil.createContactServiceContractJunction();
        mapNpxConfigMap=NPX_Cx_TestUtil.createNpxConfigMap(sBatch);
    }

    public static  void  getNPXConfig( string s1, string s2)
    {        
        NPX_Config__c testConfig= new NPX_Config__c();
        testConfig.Key__c = s1;  
        testConfig.Value__c = s2;
        testConfig.Batch__c = sBatch;
        
        listNPXConfig.add(testConfig) ;                
        //return testConfig;
    }
    //+++++++++++++++++++++++++++++++++++++++++++++++++++  
    // 2. Add NPX_Configuration__c
    //+++++++++++++++++++++++++++++++++++++++++++++++++++
    public static void createConfigdata( string custseg ,string sBatch_BM,string salesorg , string salesoffice , string saleorg4surveymethod ,string sale2org4surveymethod ,string sBatch_BMMethod, string startdays ,string enddays,string contfunction) 
    {
        createTestData();
        //getNPXConfig (configname+'Filter','TODAY');
        getNPXConfig ('Contract_Doc_Type','YWV');
        getNPXConfig ('Survey_Number','KONE_111467');
        getNPXConfig ('Technical_Test','No');
        getNPXConfig ('Technical_Summary_Emails','som@x.xb');
        getNPXConfig ('Technical_Error_Emails','som@x.xb');
        getNPXConfig ('Contract_SalesOrg',salesorg);
        getNPXConfig ('Contract_SalesOffice',salesoffice);
        getNPXConfig ('Contract_OrderReasons','210|220|230|240|250|260|280|290');
        getNPXConfig ('Contract_Equipment_type','004');
        //getNPXConfig ('Contract_StartDate_BeginDaysAgo','< N_DAYS_AGO:60');
        getNPXConfig ('Survey_Default_Method',sBatch_BMMethod);
        getNPXConfig ('Survey_Initial_Status','Nominated');
        getNPXConfig ('Contract_Market_Segment','Residential');
        getNPXConfig ('Service_Contract_Contact_Role','influencer');
        getNPXConfig ('Account_CustomerGroup','Strategic');
        getNPXConfig ('BatchSize','1000');   
        getNPXConfig ('Contract_StartDate_BeginDaysAgo' ,startdays); 
        getNPXConfig ('Contract_StartDate_EndDaysAgo',enddays);
        getNPXConfig ('Contract_koneCountry','France');
        getNPXConfig ('Contract_Contract_Type','03|04');
        getNPXConfig ('Technical_BatchName','ONBOARDING_HYBRID');
        getNPXConfig ('Contact_Active','True');
        getNPXConfig ('Contact_Donotsurvey','False');
        getNPXConfig ('Contact_Owner_Region','Center|South');
        getNPXConfig ('Account_Market_segment','Residential|Office');
        getNPXConfig ('Account_Customer_segment',custseg);
        getNPXConfig ('Service_Contract_OrderReasons','210|220|230|240|250|260|280|290');
        getNPXConfig ('Contact_Function',contfunction);
        getNPXConfig ('ServiceOrder_Finish date','( finished_date__c = null or finished_date__c > n_days_ago:14)');
        getNPXConfig ('ServiceOrder_KONNECT_Status','13');
        getNPXConfig ('ServiceOrder_SAP_Status','TECO|CLSD');
        getNPXConfig ('ServiceOrder_ActivityType_Code','Z03|Y03|Z16');

        getNPXConfig ('Service_Contract_contract_End_date','Contract_end_date__c = Null or Contract_end_date__C > TODAY');
        INSERT listNPXConfig;
        SYSTEM.DEBUG ( ' #### . NPX Config Inserted = '+listNPXConfig.size());
        system.debug(listNPXConfig);
  
    }

    //Npx record creation
    static testmethod void npxCreationTest_BM()
    {
        System.runAs(NPX_Cx_TestUtil.createNPXAdminUser())
        {
            
            test.startTest();
            SYSTEM.DEBUG (' ==========================================');
            //SYSTEM.DEBUG ( ' STARTING BATCH TEST  BM Survey 4');
            SYSTEM.DEBUG (' STARTING - GENERIC BATCH TEST BM Survey 1');
            createConfigdata('Building Manager', sBatch, '231', 'BRU', '', '', 'Phone', '>N_DAYS_AGO:301', '<N_DAYS_AGO:0','Building Manager');
            integer y5 = database.countQuery ('SELECT count() FROM Service_Order__c ');
            system.assertEquals(6,y5);
            NPX_Onboarding_Batch_HYB_BP batch = new NPX_Onboarding_Batch_HYB_BP(sBatch, mapNpxConfigMap);
            Database.executeBatch(batch);
            //system.debug(mapKey_Value)
            SYSTEM.DEBUG (' END BATCH TEST ');
            SYSTEM.DEBUG (' ==========================================');
            test.stopTest();
            integer y1 = database.countQuery ( 'SELECT count() FROM account ');
            SYSTEM.DEBUG ( 'Total Account records to be available = '+y1);
            integer y2 = database.countQuery ( 'SELECT count() FROM NPX_Config__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available = '+y2);
            integer y3 = database.countQuery ( 'SELECT count() FROM NPX_Survey_Record__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available  days (100 - 0) = '+y3);
            SYSTEM.DEBUG ( ' FINISH -  BATCH TEST BM Survey 1');
            system.assertEquals(1, y3);
            
        }
    }
    //Npx record creation
    static testmethod void npxCreationTest_HOA()
    {
        System.runAs(NPX_Cx_TestUtil.createNPXAdminUser())
        {
            
            test.startTest();
            SYSTEM.DEBUG (' ==========================================');
            //SYSTEM.DEBUG ( ' STARTING BATCH TEST  BM Survey 4');
            SYSTEM.DEBUG (' STARTING - GENERIC BATCH TEST BM Survey 1');
            createConfigdata('Housing / owners cooperation', sBatch, '231', 'BRU', '', '', 'Phone', '>N_DAYS_AGO:301', '<N_DAYS_AGO:0','Head of tenants');
            list<account> lsAccount = [select id,Customer_Type__c,Name,Has_KONE_Care_Online_Users__c,KONE_City__c,Kone_Country__c,Street_1__c,KONE_Zip_Postal_Code__c,Customer_of_Equipments__c,Industry_Segment__c from account];
            for(Account acc:lsAccount){
                acc.Customer_Type__c = 'Housing / owners cooperation';
            
            }
            update lsAccount;
            system.debug(lsAccount);

            list<Contact> lscontact = [Select id ,Function__c,AccountId,Active__c,Mobilephone,Do_not_survey__c from Contact];
            system.debug(lscontact);
            for(Contact contact:lscontact){
                contact.Function__c  = 'Head of Tenants';
            }
            update lscontact;
            system.debug(lscontact);
            integer y5 = database.countQuery ('SELECT count() FROM Service_Order__c ');
            system.assertEquals(6,y5);
            NPX_Onboarding_Batch_HYB_BP batch = new NPX_Onboarding_Batch_HYB_BP(sBatch, mapNpxConfigMap);
            Database.executeBatch(batch);
            //system.debug(mapKey_Value)
            SYSTEM.DEBUG (' END BATCH TEST ');
            SYSTEM.DEBUG (' ==========================================');
            test.stopTest();
            integer y1 = database.countQuery ( 'SELECT count() FROM account ');
            SYSTEM.DEBUG ( 'Total Account records to be available = '+y1);
            integer y2 = database.countQuery ( 'SELECT count() FROM NPX_Config__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available = '+y2);
            integer y3 = database.countQuery ( 'SELECT count() FROM NPX_Survey_Record__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available  days (100 - 0) = '+y3);
            SYSTEM.DEBUG ( ' FINISH -  BATCH TEST BM Survey 1');
            system.assertEquals(1, y3);
        }
    }
    ////Npx record creation
    static testmethod void npxCreationTest_ALL()
    {
        System.runAs(NPX_Cx_TestUtil.createNPXAdminUser())
        {
            
            test.startTest();
            SYSTEM.DEBUG (' ==========================================');
            //SYSTEM.DEBUG ( ' STARTING BATCH TEST  BM Survey 4');
            SYSTEM.DEBUG (' STARTING - GENERIC BATCH TEST BM Survey 1');
            createConfigdata(' ', sBatch, '231', 'BRU', '', '', 'Phone', '>N_DAYS_AGO:301', '<N_DAYS_AGO:0','ALL');
            list<Contact> lscontact = [Select id ,Function__c,AccountId,Active__c,Mobilephone,Do_not_survey__c from Contact];
            system.debug(lscontact);
            for(Contact contact:lscontact){
                contact.Function__c  = 'NOT ASSIGNED';
            }
            update lscontact;
            system.debug(lscontact);
            integer y5 = database.countQuery ('SELECT count() FROM Service_Order__c ');
            system.assertEquals(6,y5);
            NPX_Onboarding_Batch_HYB_BP batch = new NPX_Onboarding_Batch_HYB_BP(sBatch, mapNpxConfigMap);
            Database.executeBatch(batch);
            //system.debug(mapKey_Value)
            SYSTEM.DEBUG (' END BATCH TEST ');
            SYSTEM.DEBUG (' ==========================================');
            test.stopTest();
            integer y1 = database.countQuery ( 'SELECT count() FROM account ');
            SYSTEM.DEBUG ( 'Total Account records to be available = '+y1);
            integer y2 = database.countQuery ( 'SELECT count() FROM NPX_Config__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available = '+y2);
            integer y3 = database.countQuery ( 'SELECT count() FROM NPX_Survey_Record__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available  days (100 - 0) = '+y3);
            SYSTEM.DEBUG ( ' FINISH -  BATCH TEST BM Survey 1');
            system.assertEquals(1, y3);
        }
    }
    static testmethod void npxCreationNoSalesorg()
    {
        System.runAs(NPX_Cx_TestUtil.createNPXAdminUser())
        {
            
            test.startTest();
            SYSTEM.DEBUG (' ==========================================');
            //SYSTEM.DEBUG ( ' STARTING BATCH TEST  BM Survey 4');
            SYSTEM.DEBUG (' STARTING - GENERIC BATCH TEST BM Survey 1');
            createConfigdata('Building Manager', sBatch, '', 'BRU', '', '', 'Phone', '>N_DAYS_AGO:301', '<N_DAYS_AGO:0','Building Manager');
            //createConfigdata('Housing / owners cooperation', 'Onboarding_', sBatch, '231', 'BRU', '', '', 'Phone', 'N_DAYS_AGO:301', 'N_DAYS_AGO:0','Head of tenants');
            integer y5 = database.countQuery ('SELECT count() FROM Service_Order__c ');
            system.assertEquals(6,y5);
            NPX_Onboarding_Batch_HYB_BP batch = new NPX_Onboarding_Batch_HYB_BP(sBatch, mapNpxConfigMap);
            Database.executeBatch(batch);
            //system.debug(mapKey_Value)
            SYSTEM.DEBUG (' END BATCH TEST ');
            SYSTEM.DEBUG (' ==========================================');
            test.stopTest();
            integer y1 = database.countQuery ( 'SELECT count() FROM account ');
            SYSTEM.DEBUG ( 'Total Account records to be available = '+y1);
            integer y2 = database.countQuery ( 'SELECT count() FROM NPX_Config__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available = '+y2);
            integer y3 = database.countQuery ( 'SELECT count() FROM NPX_Survey_Record__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available  days (100 - 0) = '+y3);
            SYSTEM.DEBUG ( ' FINISH -  BATCH TEST BM Survey 1');
            system.assertEquals(1, y3);
            
        }
    }
     static testmethod void surveyMethodDefaultTest()
    {
       System.runAs(NPX_Cx_TestUtil.createNPXAdminUser())
        {
            test.startTest();
            SYSTEM.DEBUG (' ==========================================');
            //SYSTEM.DEBUG ( ' STARTING BATCH TEST  BM Survey 4');
            SYSTEM.DEBUG (' STARTING - GENERIC BATCH TEST BM Survey 1');
            createConfigdata('Building Manager', sBatch, '231', 'BRU', '', '', 'SMS', '>N_DAYS_AGO:301', '<N_DAYS_AGO:0','Building Manager');
            //createConfigdata('Housing / owners cooperation', 'Onboarding_', sBatch, '231', 'BRU', '', '', 'Phone', 'N_DAYS_AGO:301', 'N_DAYS_AGO:0','Head of tenants');
            NPX_Onboarding_Batch_HYB_BP batch = new NPX_Onboarding_Batch_HYB_BP(sBatch, mapNpxConfigMap);
            Database.executeBatch(batch);
            //system.debug(mapKey_Value)
            SYSTEM.DEBUG (' END BATCH TEST ');
            SYSTEM.DEBUG (' ==========================================');
            test.stopTest();

            integer y1 = database.countQuery ( 'SELECT count() FROM account ');
            SYSTEM.DEBUG ( 'Total Account records to be available = '+y1);
            integer y2 = database.countQuery ( 'SELECT count() FROM NPX_Config__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available = '+y2);
            integer y3 = database.countQuery ( 'SELECT count() FROM NPX_Survey_Record__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available  days (100 - 0) = '+y3);
            SYSTEM.DEBUG ( ' FINISH -  BATCH TEST BM Survey 1');
            system.assertEquals(1, y3);
            list<NPX_Survey_Record__c> npxRec1= [SELECT Id,Survey_Method__c FROM NPX_Survey_Record__c];
            system.debug(npxRec1);
            for(NPX_Survey_Record__c npx:npxRec1)
            {
                System.debug(npx.Survey_Method__c);
                system.assertEquals('SMS',npx.Survey_Method__c);
            }
        }
    }
    //Escalation Matrix Test
    static testmethod void EscalationTest()
    {
        System.runAs(NPX_Cx_TestUtil.createNPXAdminUser())
        {
            test.startTest();
            SYSTEM.DEBUG (' ==========================================');
            //SYSTEM.DEBUG ( ' STARTING BATCH TEST  BM Survey 4');
            SYSTEM.DEBUG (' STARTING - GENERIC BATCH TEST BM Survey 1');
            NPX_Cx_TestUtil.createNPXEsclationConfig('231', 'BRU');
            createConfigdata('Building Manager', sBatch, '231', 'BRU', '', '', 'SMS', '>N_DAYS_AGO:301', '<N_DAYS_AGO:0','Building Manager');
            //createConfigdata('Housing / owners cooperation', 'Onboarding_', sBatch, '231', 'BRU', '', '', 'Phone', 'N_DAYS_AGO:301', 'N_DAYS_AGO:0','Head of tenants');
            NPX_Onboarding_Batch_HYB_BP batch = new NPX_Onboarding_Batch_HYB_BP(sBatch, mapNpxConfigMap);
            Database.executeBatch(batch);
            //system.debug(mapKey_Value)
            SYSTEM.DEBUG (' END BATCH TEST ');
            SYSTEM.DEBUG (' ==========================================');
            test.stopTest();

            integer y1 = database.countQuery ( 'SELECT count() FROM account ');
            SYSTEM.DEBUG ( 'Total Account records to be available = '+y1);
            integer y2 = database.countQuery ( 'SELECT count() FROM NPX_Config__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available = '+y2);
            integer y3 = database.countQuery ( 'SELECT count() FROM NPX_Survey_Record__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available  days (100 - 0) = '+y3);
            SYSTEM.DEBUG ( ' FINISH -  BATCH TEST BM Survey 1');
            system.assertEquals(1, y3);
            list<NPX_Survey_Record__c> npxRec1= [SELECT Id,Survey_Method__c,FU_escalation1__c FROM NPX_Survey_Record__c where Survey_Method__c = 'Phone'];
            system.debug(npxRec1);
            for(NPX_Survey_Record__c npx:npxRec1)
            {
                system.assertEquals('test@example.com',npx.FU_escalation1__c);
            }
        }
    }
     //No records created(Negative test)
    static testmethod void noNpxCreationTest()
    {
        System.runAs(NPX_Cx_TestUtil.createNPXAdminUser())
       {
            test.startTest();
            SYSTEM.DEBUG (' ==========================================');
            //SYSTEM.DEBUG ( ' STARTING BATCH TEST  BM Survey 4');
            SYSTEM.DEBUG (' STARTING - GENERIC BATCH TEST BM Survey 1');
            createConfigdata('', sBatch, '', 'BRU', '', '', '', '>N_DAYS_AGO:3', '<N_DAYS_AGO:0','Building Manager');
            NPX_Onboarding_Batch_HYB_BP batch = new NPX_Onboarding_Batch_HYB_BP(sBatch, mapNpxConfigMap);
            Database.executeBatch(batch);
            //system.debug(mapKey_Value)
            SYSTEM.DEBUG (' END BATCH TEST ');
            SYSTEM.DEBUG (' ==========================================');
            test.stopTest();

            integer y1 = database.countQuery ( 'SELECT count() FROM account ');
            SYSTEM.DEBUG ( 'Total Account records to be available = '+y1);
            integer y2 = database.countQuery ( 'SELECT count() FROM NPX_Config__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available = '+y2);
            integer y3 = database.countQuery ( 'SELECT count() FROM NPX_Survey_Record__c ');
            SYSTEM.DEBUG ( 'Total NPX records to be available  days (100 - 0) = '+y3);
            SYSTEM.DEBUG ( ' FINISH -  BATCH TEST BM Survey 1');
            system.assertEquals(0, y3);
        }
    }
    //scheduler test
    static testmethod void schedulerTest()
    {
        String jobId;
        Integer year = Date.today().year() + 1;

        System.runAs(NPX_Cx_TestUtil.createNPXAdminUser())
        {
            Test.startTest();
            // This test runs a scheduled job at midnight Sept. 3rd. next year
            String CRON_EXP = '0 0 0 3 9 ? ' + year;
            // Schedule the test job
            NPX_Onboarding_Batch_HYB_Sched scheduler = new NPX_Onboarding_Batch_HYB_Sched('');
            jobId = System.schedule('scheduleTest', CRON_EXP, scheduler);
            scheduler.execute(null);
            Test.stopTest();
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            // Verify the next time the job will run
            System.assertEquals(year + '-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        }
     }

}