*** Settings ***
Documentation    API layer driver: the only file that imports RequestsLibrary.
Resource         ../../variables/prod.resource
Library          Collections
Library          RequestsLibrary


*** Keywords ***
Open API Session
    [Documentation]    Create session `api` for ${BASE_URL}.
    Create Session    api    ${BASE_URL}    timeout=${TIMEOUT}

Send Request    # robocop: off=LEN07
    [Documentation]    Send a request on session `api` with expected_status=any and return the response.
    [Arguments]    ${method}    ${path}    ${params}=${None}    ${json}=${None}    ${headers}=${None}    ${data}=${None}
    ${resp}=    On Session    ${method}    api    ${path}    params=${params}    json=${json}
    ...    headers=${headers}    data=${data}    expected_status=any
    RETURN    ${resp}

Status Should Be
    [Documentation]    Assert the response status code equals the expected code.
    [Arguments]    ${resp}    ${expected}
    Should Be Equal As Integers    ${resp.status_code}    ${expected}    Status ${resp.status_code}: ${resp.text}

Get Body Field
    [Documentation]    Return the JSON body value at a dotted path, failing if a key is missing.
    [Arguments]    ${resp}    ${path}
    VAR    ${value}    ${resp.json()}
    ${keys}=    Evaluate    $path.split('.')
    FOR    ${key}    IN    @{keys}
        Dictionary Should Contain Key    ${value}    ${key}
        ${value}=    Get From Dictionary    ${value}    ${key}
    END
    RETURN    ${value}

Body Field Should Be
    [Documentation]    Assert the JSON body value at a dotted path equals the expected value.
    [Arguments]    ${resp}    ${path}    ${expected}
    ${value}=    Get Body Field    ${resp}    ${path}
    Should Be Equal As Strings    ${value}    ${expected}

Header Should Contain
    [Documentation]    Assert a response header contains the expected substring.
    [Arguments]    ${resp}    ${name}    ${expected}
    Dictionary Should Contain Key    ${resp.headers}    ${name}
    Should Contain    ${resp.headers}[${name}]    ${expected}

Body Field Should Be Of Type
    [Documentation]    Assert the JSON value at a dotted path has the type name (str, dict, list, number, bool).
    [Arguments]    ${resp}    ${path}    ${type}
    ${value}=    Get Body Field    ${resp}    ${path}
    ${actual}=    Evaluate    'number' if type($value) in (int, float) else type($value).__name__
    Should Be Equal    ${actual}    ${type}    Field ${path} is ${actual}, not ${type}
