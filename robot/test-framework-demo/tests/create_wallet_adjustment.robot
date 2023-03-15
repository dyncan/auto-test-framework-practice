*** Settings ***
Resource          cumulusci/robotframework/Salesforce.robot
Library           cumulusci.robotframework.PageObjects
Library           robot/test-framework-demo/resources/WalletAdjustPageObject.py
Suite Setup       Run keywords
...               Open test browser
...               AND Setup Test Data
Suite Teardown    close browser

*** Variables ***
${L2OWNER}            peter@dong.com
${CURRENTCMP}         c-create-wallet-adjustment-l-w-c
${TXNSUBTYPE}         WorkingCapital_Withdraw
${VALUEDATE}          May 08, 2022
${CREDITWALLET1}      LT-Investment Redeem Transition-BTC
${DEBITWALLET1}       LT-Operation Expense-BTC
${CREDITWALLET2}      LT-Cash -Binance-BTC
${DEBITWALLET2}       LT-Cash -FTX-BTC
${CREATCOUNT}         1

*** Keywords ***
Setup Test Data
    ${Amount__c} =                  Generate Random String  2  [NUMBERS]
    Set suite variable              ${Amount__c}
    ${Counterparty_TXN_Id__c} =     Generate Random String
    Set suite variable              ${Counterparty_TXN_Id__c}
    ${Adjustment_Reason__c} =       Generate Random String
    Set suite variable              ${Adjustment_Reason__c}

API Get Name Based on Object
    [Documentation]         返回特定对象的field_name和field_value 并返回记录的Name。
    [Arguments]             ${obj_name}    ${field_name}     ${field_value}
    @{records} =            Salesforce Query      ${obj_name}
    ...                         select=Name
    ...                         ${field_name}=${field_value}
    ${cnt}=                 Get length    ${records}
    Should Be Equal As Numbers       ${cnt}  1
    ${result} =             Get From List  ${records}  0
    [return]                ${result}[Name]

Created Wallet Adjustment
    [Arguments]             ${creaditWallet}    ${debitWallet}     ${l2Owner}
    go to object list        Wallet_Adjustment__c          All
    Current page should be   Listing            Wallet_Adjustment__c
    Click Element            xpath=//div[@title='New']
    
    Wait Until Loading Is Complete
    
    ${creditWallet}=           API Get Name Based on Object      Wallet__c     Name       ${creaditWallet}
    ${debitWallet}=            API Get Name Based on Object      Wallet__c     Name       ${debitWallet}
    ${user}=                   API Get Name Based on Object      User          Username   ${l2Owner}

    populate wallet lookup     Debit_Wallet__c                                                  ${debitWallet}
    populate wallet lookup     Credit_Wallet__c                                                 ${creditWallet}
    Input Text                 xpath=//${CURRENTCMP}//input[@name='Amount__c']                  ${Amount__c}
    Input Text                 xpath=//${CURRENTCMP}//input[@name='Counterparty_TXN_Id__c']     ${Counterparty_TXN_Id__c}
    Click Button               xpath=//${CURRENTCMP}//button[@name='Transaction_Sub_Type__c']
    Populate The Dropdown      ${TXNSUBTYPE}
    Input Text                 xpath=//${CURRENTCMP}//input[@name='Value_Date__c']              ${VALUEDATE}
    Sleep    1s
    Click Button               xpath=//${CURRENTCMP}//button[@title='Submit for Checker Approval']
    populate wallet lookup     L2_Owner__c                                                      ${user}
    Input Text                 xpath=//${CURRENTCMP}//textarea[@name='Adjustment_Reason__c']    ${Adjustment_Reason__c}
    Click Button               xpath=//${CURRENTCMP}//button[@title='Submit']
    Element Should Not Contain  xpath=//${CURRENTCMP}//input[@name='Currency__c']     ""
    Wait Until Location Contains    list
    Click Button               xpath=(//button[@name='refreshButton'])[1]
    Wait Until Loading Is Complete

*** Test Cases ***
Test the Wallet Adjustment One
    
    FOR  ${Index}  IN RANGE  ${CREATCOUNT}
        # 创建 wallet adjust
        Created Wallet Adjustment   ${CREDITWALLET1}   ${DEBITWALLET1}  ${L2OWNER}    
    END

Test the Wallet Adjustment Two
    
    FOR  ${Index}  IN RANGE  ${CREATCOUNT}
        # 创建 wallet adjust
        Created Wallet Adjustment   ${CREDITWALLET2}   ${DEBITWALLET2}  ${L2OWNER}    
    END
    

