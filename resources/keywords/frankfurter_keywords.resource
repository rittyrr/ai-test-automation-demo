*** Settings ***
Documentation    Business keywords for the Frankfurter API tests.
Resource         api.resource


*** Keywords ***
Open Frankfurter Session
    [Documentation]    Open the unauthenticated API session for Frankfurter.
    Open API Session

Send Api Request
    [Documentation]    GET a path, assert status and JSON content type, return the response.
    [Arguments]    ${path}    ${expected_status}    ${params}=${None}
    ${resp}=    Send Request    GET    ${path}    params=${params}
    Status Should Be    ${resp}    ${expected_status}
    Header Should Contain    ${resp}    Content-Type    application/json
    RETURN    ${resp}

Get Latest Rates
    [Documentation]    GET /latest with optional params and return the response.
    [Arguments]    ${params}=${None}
    ${resp}=    Send Request    GET    /latest    params=${params}
    RETURN    ${resp}

Get Rates For Date
    [Documentation]    GET /{date} and return the response.
    [Arguments]    ${date}
    ${resp}=    Send Request    GET    /${date}
    RETURN    ${resp}

Get Rates For Period
    [Documentation]    GET /{start}..{end} and return the response.
    [Arguments]    ${start}    ${end}
    ${resp}=    Send Request    GET    /${start}..${end}
    RETURN    ${resp}

Get Currencies
    [Documentation]    GET /currencies and return the response.
    ${resp}=    Send Request    GET    /currencies
    RETURN    ${resp}

Post Currencies
    [Documentation]    POST /currencies without a body and return the response.
    ${resp}=    Send Request    POST    /currencies
    RETURN    ${resp}

Response Should Be Json Success
    [Documentation]    Assert status 200 and a JSON content type.
    [Arguments]    ${resp}
    Status Should Be    ${resp}    200
    Header Should Contain    ${resp}    Content-Type    application/json

Body Should Have Keys
    [Documentation]    Assert the JSON body contains every given top-level key.
    [Arguments]    ${resp}    @{keys}
    VAR    ${body}    ${resp.json()}
    FOR    ${key}    IN    @{keys}
        Dictionary Should Contain Key    ${body}    ${key}
    END

Rates Should Be Numbers
    [Documentation]    Assert every value in a code-to-rate mapping is a number.
    [Arguments]    ${rates}
    Should Not Be Empty    ${rates}
    FOR    ${code}    ${rate}    IN    &{rates}
        Should Be True    isinstance($rate, (int, float))    Rate ${code} is not a number: ${rate}
    END

Rates Should Contain Codes
    [Documentation]    Assert the body rates contain every given currency code.
    [Arguments]    ${resp}    @{codes}
    ${rates}=    Get Body Field    ${resp}    rates
    FOR    ${code}    IN    @{codes}
        Dictionary Should Contain Key    ${rates}    ${code}
    END

Period Rates Should Be Numbers
    [Documentation]    Assert period rates map each date to a code-to-number mapping.
    [Arguments]    ${resp}
    ${rates}=    Get Body Field    ${resp}    rates
    Should Not Be Empty    ${rates}
    FOR    ${day}    ${day_rates}    IN    &{rates}
        Should Match Regexp    ${day}    ^\\d{4}-\\d{2}-\\d{2}$
        Rates Should Be Numbers    ${day_rates}
    END

Date Field Should Be Iso
    [Documentation]    Assert the body field at a dotted path is a YYYY-MM-DD string.
    [Arguments]    ${resp}    ${path}
    ${value}=    Get Body Field    ${resp}    ${path}
    Should Match Regexp    ${value}    ^\\d{4}-\\d{2}-\\d{2}$

Date Field Should Be Between
    [Documentation]    Assert the ISO date at a dotted path is within the inclusive range.
    [Arguments]    ${resp}    ${path}    ${start}    ${end}
    Date Field Should Be Iso    ${resp}    ${path}
    ${value}=    Get Body Field    ${resp}    ${path}
    Should Be True    $start <= $value <= $end    ${path} ${value} not in ${start}..${end}

Currencies Should Have Non Empty Names
    [Documentation]    Assert the currencies body maps every code to a non-empty string.
    [Arguments]    ${resp}
    VAR    ${body}    ${resp.json()}
    Should Not Be Empty    ${body}
    FOR    ${code}    ${name}    IN    &{body}
        Should Be True    isinstance($name, str) and $name.strip()    Name for ${code} is empty or not a string
    END

Response Should Not Be Success
    [Documentation]    Assert the status is not 200.
    [Arguments]    ${resp}
    Should Not Be Equal As Integers    ${resp.status_code}    200    Expected non-200, got 200: ${resp.text}

Response Should Not Be Server Error
    [Documentation]    Log the status and assert it is below 500.
    [Arguments]    ${resp}
    Log    Status: ${resp.status_code}
    Should Be True    ${resp.status_code} < 500    Server error ${resp.status_code}: ${resp.text}

Error Message Should Be
    [Documentation]    Assert the error body message equals the expected text.
    [Arguments]    ${resp}    ${expected}
    Body Field Should Be    ${resp}    message    ${expected}

Rates Should Not Contain Code
    [Documentation]    Assert the body has no rate for the code, if it has rates at all.
    [Arguments]    ${resp}    ${code}
    VAR    ${body}    ${resp.json()}
    IF    'rates' in $body
        Dictionary Should Not Contain Key    ${body}[rates]    ${code}
    END

Base Should Not Be
    [Documentation]    Assert the body base, if present, differs from the code.
    [Arguments]    ${resp}    ${code}
    VAR    ${body}    ${resp.json()}
    IF    'base' in $body    Should Not Be Equal    ${body}[base]    ${code}
