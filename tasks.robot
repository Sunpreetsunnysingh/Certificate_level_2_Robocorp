*** Settings ***
Documentation   Template robot main suite.
Library         RPA.Browser
Library         RPA.HTTP
Library         RPA.PDF
Library         RPA.Tables
Library         OperatingSystem
Library         RPA.Archive
Library         RPA.FileSystem
Library         RPA.Robocloud.Secrets
Library         Dialogs
Library         RPA.core.notebook



*** Keywords ***
open order website
    ${url}=    Get Secret    websitedata
    Open Available Browser  ${url}[url]
    Maximize Browser Window


*** Keywords ***
click ok
    Click Button    //button[@class='btn btn-dark'] 

**Keywords***
ADD directory
    [Arguments]  ${folder}
    Remove Directory  ${folder}  True
    Create Directory  ${folder}

***Keywords***
Intializing Directory Steps   
    Remove File  ${CURDIR}${/}orders.csv
    ${reciept_folder}=  Does Directory Exist  ${CURDIR}${/}reciepts
    ${robots_folder}=  Does Directory Exist  ${CURDIR}${/}robots
    Run Keyword If  '${reciept_folder}'=='True'  ADD directory  ${CURDIR}${/}reciepts  ELSE  Create Directory  ${CURDIR}${/}reciepts
    Run Keyword If  '${robots_folder}'=='True'  ADD directory  ${CURDIR}${/}robots  ELSE  Create Directory  ${CURDIR}${/}robots

# +
*** Keywords ***
Fill and submit order form
    [Arguments]       ${order}
    Select From List By Value    id:head    ${order}[Head]
    Select Radio Button    body     ${order}[Body]
    Input Text    //*[@type="number"]     ${order}[Legs]
    Input Text    id:address     ${order}[Address]
    Click Button   id:preview  
    Sleep  2 seconds
    Click Button   id:order
  
    
    
    
# -


*** Keywords ***
Get order Reciept as pdf
    [Arguments]         ${order}
    Wait Until Page Contains Element    id:receipt    timeout=50
    Sleep  5 seconds
    ${order_Reciept_html}=   Get Element Attribute   id:receipt    outerHTML
    Html To Pdf    ${order_Reciept_html}    ${CURDIR}${/}reciepts${/}${order}[Order number].pdf
    Screenshot    id:robot-preview-image    ${CURDIR}${/}robots${/}${order}[Order number].png 
    Add Watermark Image To Pdf  ${CURDIR}${/}robots${/}${order}[Order number].png  ${CURDIR}${/}reciepts${/}${order}[Order number].pdf  ${CURDIR}${/}reciepts${/}${order}[Order number].pdf 


*** Keywords ***
Download csv
    Download    https://robotsparebinindustries.com/orders.csv      overwrite=True

*** Keywords ***
READING CSV FILE
    ${ordersFile}=  Read table from CSV     orders.csv
    
    FOR   ${order}  IN  @{ordersFile}
    Fill and submit order form    ${order}
    Checking Receipt data processed or not
    Get order Reciept as pdf       ${order}
  
    Sleep  3 seconds
    Click Button   id:order-another
  
    Sleep   2 seconds
    Wait Until Page Contains Element    //button[@class='btn btn-dark']
    Click Button    //button[@class='btn btn-dark'] 
    Sleep  2 seconds
    END

***Keywords***
Close and start Browser to tr
    Close Browser
    open order website
    Continue For Loop

*** Keywords ***
Checking Receipt data processed or not 
    FOR  ${i}  IN RANGE  ${100}
        ${alert}=  Is Element Visible  //div[@class="alert alert-danger"]  
        Run Keyword If  '${alert}'=='True'  Click Button  //button[@id="order"] 
        Exit For Loop If  '${alert}'=='False'       
    END
    
    Run Keyword If  '${alert}'=='True'  Close and start Browser to tr

***Keywords***
Zip the reciepts PDFS
    Archive Folder With Zip  ${CURDIR}${/}reciepts  ${OUTPUT_DIR}${/}reciepts.zip

*** Tasks ***
working on order robot level 2 certificate
    open order website
    click ok
    READING CSV FILE
    Zip the reciepts PDFS
    [Teardown]  Close Browser



