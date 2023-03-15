*** Settings ***
Resource          cumulusci/robotframework/Salesforce.robot
Library           cumulusci.robotframework.PageObjects
Suite Setup       Run keywords
...               Login To Salesforce
...               AND Setup Test Data
Suite Teardown    close browser


*** Variables ***
# 基于CreatedDate (条件为大于并且小于等于CreatedDate)
${STARTDATE}          2022-05-05T00:00:00Z
${ENDDATE}            2022-05-06T00:00:00Z
${APPROVALCOUNT}      1


*** Keywords ***
Setup Test Data
    ${approval_comment} =     Generate Random String
    Set suite variable        ${approval_comment}

Login To Salesforce
    Open Test Browser Chrome    https://test.salesforce.com
    Input Text                id=username    xxx
    Input Password            xpath=//input[@name='pw']    xxx
    Click Button              xpath=//*[@id='Login']

Salesforce Query Where Limit Wallet Adjustment
    [Arguments]             ${startDate}        ${endDate}      ${limitNum}
    @{records} =    Salesforce Query  Wallet_Adjustment__c
    ...              select=Id
    ...              where= Status__c='Checker' AND CreatedDate>${startDate} AND CreatedDate <=${endDate}
    ...              order_by=CreatedDate desc
    ...              limit=${limitNum}
    ${cnt}=    Get length    ${records}
    Should Not Be Equal As Numbers   ${cnt}  0
    [return]                ${records}

Salesforce Approval Wallet Adjustment
    [Arguments]      ${wallet_adjust}  
    Go To Page    Detail    Wallet_Adjustment__c   ${wallet_adjust}[Id]
    Current page should be     Detail    Wallet_Adjustment__c
    Wait Until Loading Is Complete
    Sleep    3s
    Execute Javascript        window.scrollTo({top: 1000, behavior: "smooth"})
    Sleep    1s
    Click Element     xpath=//div[@title='Approve']
    Input Text        xpath=//div[@class='commentContainer']//textarea    ${approval_comment}
    Click Element     xpath=//div[@class='modal-footer slds-modal__footer']//span[contains(text(),'Approve')]
    Reload Page
    Element Should Contain    xpath=//c-modify-wallet-adjustment//span[@class="slds-text-heading_small slds-truncate"]    Complete
    Sleep    3s

*** Test Cases ***
Test Approval Process
    # 对特定时间范围内的wallet adjust 记录进行审批, 可以指定记录创建的时间, 需要审批的记录的数量
    @{wallet_adjusts}=     Salesforce Query Where Limit Wallet Adjustment        ${STARTDATE}    ${ENDDATE}    ${APPROVALCOUNT}

    FOR    ${wallet_adjust}    IN    @{wallet_adjusts}
        Salesforce Approval Wallet Adjustment      ${wallet_adjust}
    END

    
