------------------------------------------------------------
--
-- Lua Unit Testing Framework
--
-- Simply put "require 'unittest'" and "load_modules(<module1>, <module2>, ...)" at the top of the unittest file
-- and define all tests as: tests["<test_name>"] = function (...) ...  -  or use add_test(name{str}, test{func})
-- To run the tests, call run_all_tests()
--
-- Created by Nathan Boehm, 2019


--[[        unit testing functions

    expect_eq(lhs, rhs):                          verifies that 'lhs' is equal to 'rhs', 'lhs' and 'rhs' must be of the same type.
    expect_ne(lhs, rhs):                          verifies that 'lhs' is not equal to 'rhs', succeeds if arguments are of different types.
    expect_lt(lhs, rhs):                          verifies that 'lhs' is less than 'rhs', 'lhs' and 'rhs' must be of the same type. Fails if 'lhs' is equal to 'rhs'.
    expect_lte(lhs, rhs):                         same as expect_lt, except 'lhs' and be equal to 'rhs'.
    expect_gt(lhs, rhs):                          verifies that 'lhs' is greater than 'rhs', 'lhs' and 'rhs' must be of the same type. Fails if 'lhs' is equal to 'rhs'.
    expect_gte(lhs, rhs):                         same as expect_gt, except 'lhs' can be equal to 'rhs'.
    expect_inrange(val, lower, upper):            verifies that 'val' is >= 'lower' and <= 'upper'. Fails is any argument is not a number.
    expect_contains(table, val):                  verifies that 'table' contains at least one instance of 'val', 'val' cannot be nil or a table.
    expect_type(value, type):                     verifies that 'value' is of type 'type', 'type' must ve a string and represent a valid type.
    expect_error(function, ...):                  verifies that 'function' produces an error when run, 'function' must be a funciton. 
                                                    '...' is an optional, variable number of arguments that the function will be called with.
                                                        NOTE: '...' args are not validated and bad arguments can crash the unittesting framework
    expect_noerror(function, ...):                verifies that 'function' produces an error when run, 'function' must be a function.
                                                    '...' is an optional, variable number of arguments that the function will be called with.
                                                        NOTE: '...' args are not validated and bad arguments can crash the unittesting framework
    expect_tableeq(ltable, rtable):               verifies that 'ltable' contains the same key-value pairs as 'rtable'. Will recursively check subtables.
    expect_containstable(table, tval):            verifies that 'table' contains an instance of the table 'tval'. 
    expect(expression):                           verifies that 'expression' evaluates to true, 'expression' must evaluate to a boolean.
    expect_failure(test_func, expected_err, ...): verifies that the given function would fail if run as a test. (Probably not useful unless testing the unittest module itself.)
                                                    Optional string 'expected_err', if set, searches the function failure msg for 'expected_err', fails if it is not found.
                                                    '...' is an optional, variable number of arguments that the function will be called with
                                                        NOTE: '...' args are not validated and bad arguments can crash the unittesting framework
]]


--tests proxy table to relate index->name and index->test, to maintain that tests are run in the order that they are defined
tests = {size = 0}
local _tests_name = {}
local _tests = tests
tests = {}

local tests_mt = {
    __newindex = function (table, name, test)
        _tests.size = _tests.size + 1
        _tests[_tests.size] = test
        _tests_name[_tests.size] = name
    end,

    __len = function () return _tests.size end
}
setmetatable(tests, tests_mt)

local function init_tests()
    _tests = {size = 0}
    _tests_name = {}
end

function load_modules(...)
    init_tests()
    package.loaded['unittest'] = nil
    require('unittest')
    for i=1, select("#", ...) do
        local module = select(i, ...)
        package.loaded[module] = nil
        require(module)
    end
end

test_group = nil

local failure = {
    line_num         = nil,
    additional_msg   = "",
    operation        = nil,
    num_arguments    = nil, --must be set instead of using #arguments, in case of nil args
    arguments        = {},
    expected_types   = {},
    arg_error        = nil,
    unexpected_error = nil,
}
failure.reset = function ()
    failure.line_num         = nil
    failure.additional_msg   = ""
    failure.operation        = nil
    failure.num_arguments    = nil
    failure.arguments        = {}
    failure.expected_types   = {}
    failure.arg_error        = nil
    failure.unexpected_error = nil
end

_failure_conditions = {
    eq            = "arguments not equal",
    ne            = "arguments equal",
    lt            = "argument 1 not less than argument 2",
    lte           = "argument 1 not less than or equal to argument 2",
    gt            = "argument 1 not greater than argument 2",
    gte           = "argument 1 not greater than or equal to argument 2",
    inrange       = "value not in range",
    contains      = "table did not contain value",
    type          = "value was not of expected type",
    error         = "function did not produce error",
    noerror       = "function produced an error",
    tableeq       = "table 1 was not equal to table 2",
    tablene       = "table 1 was equal to table 2",
    containstable = "table did not contain expected table",
    istrue        = "expression was false",
    failure       = "",

    --arg_errors
    badtype   = "argument was of incorrect type -",
    difftypes = "arguments of different types -"
}


local default    = "\027[00;39m"
local black      = "\027[00;30m"
local red        = "\027[00;31m"
local green      = "\027[00;32m"
local yellow     = "\027[00;33m"
local magenta    = "\027[00;35m"
local blue       = "\027[00;34m"
local cyan       = "\027[00;36m"
local light_gray = "\027[00;37m"
local endcolor   = "\027[00m"


local function normalize_failure_args()
    for i=1, failure.num_arguments do
        if (type(failure.arguments[i]) == "boolean") then failure.arguments[i] = (failure.arguments[i] and "(bool)true" or "(bool)false")
        elseif (type(failure.arguments[i]) == "string") then failure.arguments[i] = "\"" .. failure.arguments[i] .. "\""
        elseif (type(failure.arguments[i]) == "nil") then failure.arguments[i] = "nil"
        elseif (type(failure.arguments[i]) == "function") then failure.arguments[i] = "function"
        elseif (type(failure.arguments[i]) == "table") then failure.arguments[i] = "table" end
    end
end

local function get_failure_msg()
    local msg = ""

    if (failure.line_num == nil) then
        msg = "unexpected failure: bad argument passed to expect-function"
        return msg
    end

    if (failure.unexpected_error ~= nil) then
        msg = "unexpected failure on line " .. failure.line_num .. ": " .. failure.unexpected_error
        return msg
    end

    msg = "failure on line " .. failure.line_num .. ": "

    if (failure.arg_error) then
        msg = msg .. failure.arg_error .. " required arguments of type(s): " 
        for i=1, #failure.expected_types do
            msg = msg .. ((i > 1) and ", " or "") .. failure.expected_types[i]
        end
        msg = msg .. " - got: "
        for i=1, failure.num_arguments do
            msg = msg .. ((i > 1) and ", " or "") .. type(failure.arguments[i])
        end
        msg = msg .. ". "
    end

    normalize_failure_args()
    
    if failure.operation == _failure_conditions.eq then
        msg = msg .. _failure_conditions.eq .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " == " .. failure.arguments[2]
    elseif failure.operation == _failure_conditions.ne then
        msg = msg .. _failure_conditions.ne .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " != " .. failure.arguments[2]
    elseif failure.operation == _failure_conditions.lt then
        msg = msg .. _failure_conditions.lt .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " < " .. failure.arguments[2]
    elseif failure.operation == _failure_conditions.lte then
        msg = msg .. _failure_conditions.lte .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " <= " .. failure.arguments[2]
    elseif failure.operation == _failure_conditions.gt then
        msg = msg .. _failure_conditions.gt .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " > " .. failure.arguments[2]
    elseif failure.operation == _failure_conditions.gte then
        msg = msg .. _failure_conditions.gte .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " >= " .. failure.arguments[2]
    elseif failure.operation == _failure_conditions.inrange then
        msg = msg .. _failure_conditions.inrange .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " in range " .. "{" .. failure.arguments[2] .. "," .. failure.arguments[3] .. "}"
    elseif failure.operation == _failure_conditions.contains then
        msg = msg .. _failure_conditions.contains .. failure.additional_msg .. ", expected: table to contain " .. failure.arguments[2]
    elseif failure.operation == _failure_conditions.type then
        msg = msg .. _failure_conditions.type .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " to be if type " .. string.sub(failure.arguments[2], 1, -1)
    elseif failure.operation == _failure_conditions.error then
        msg = msg .. _failure_conditions.error .. failure.additional_msg .. ", expected: function to produce error"
    elseif failure.operation == _failure_conditions.noerror then
        msg = msg .. _failure_conditions.noerror .. failure.additional_msg .. ", expected: function to not produce error"
    elseif failure.operation == _failure_conditions.tableeq then
        msg = msg .. _failure_conditions.tableeq .. failure.additional_msg .. ", expected: table 1 == table 2"
    elseif failure.operation == _failure_conditions.tablene then
        msg = msg .. _failure_conditions.tablene .. failure.additional_msg .. ", expected: table 1 != table 2"
    elseif failure.operation == _failure_conditions.containstable then
        msg = msg .. _failure_conditions.containstable .. failure.additional_msg .. ", expected: table 1 to contain table 2"
    elseif failure.operation == _failure_conditions.istrue then
        msg = msg .. _failure_conditions.istrue .. failure.additional_msg .. ", expected: expression to be true"
    elseif failure.operation == _failure_conditions.failure then
        msg = msg .. _failure_conditions.failure .. failure.additional_msg
    end

    failure.reset()
    return msg
end

local function run_test(test, ...)
    local test_routine = coroutine.create(test)
    local test_passed = false
    while (true) do
        op_status, yield_val = coroutine.resume(test_routine, ...)

        if (op_status == false) then 
            failure.unexpected_error = yield_val
            test_passed = false
            break
        end

        if (yield_val == false) then
            test_passed = false
            break
        end

        if (coroutine.status(test_routine) == "dead") then --exited successfully
            test_passed = true
            break
        end
    end

    return test_passed
end

function run_all_tests()
    io.write(cyan, "\n---BEGIN TESTS---\n\n", endcolor)
    local longest_name = 0
    for i=1, #tests do
        local name = _tests_name[i]
        if (string.len(name) > longest_name) then
            longest_name = string.len(name)
        end
    end
    for i=1, #tests do
        local name = _tests_name[i]
        local test = _tests[i]
        local offset_len = longest_name - string.len(name)
        local offset = " "
        for j=0, offset_len do
            offset = offset .. " "
        end
        if (type(test) == "function") then
            local test_group_name = (type(test_group) == string and "[TEST]" or '[' .. test_file .. "]")
            io.write(test_group_name, "[", name, "]:", offset)
            local test_passed = run_test(test)

            if (test_passed == true) then
                io.write(green, "PASSED\n", endcolor)
            else
                io.write(red, "FAILED\n", endcolor)
                io.write(yellow, get_failure_msg(), endcolor, "\n")
            end
        else
            io.write(yellow, "UNIT TEST ERROR: test \"", name, "\" was not a function!\n", endcolor)
        end
    end
    io.write(cyan, "\n---END TESTS---\n", endcolor)
end

function add_test(name, test)
    if (type(name) ~= "string") then io.write("test name was not a valid string\n") return end
    if (type(test) ~= "function") then io.write("test was not a valid function\n") return end

    tests[name] = test
end

function run()
    run_all_tests()
end

--expect definitions

function expect_eq(lhs, rhs)
    failure.operation = _failure_conditions.eq
    failure.num_arguments = 2
    failure.arguments = {lhs, rhs}
    failure.expected_types = {"any", "any"}
    failure.line_num = debug.getinfo(2).currentline

    if (type(lhs) ~= type(rhs)) then
        failure.arg_error = _failure_conditions.difftypes

        coroutine.yield(false)

    elseif (not (lhs == rhs)) then
        coroutine.yield(false)

    else 
        coroutine.yield(true)
    end
end

function expect_ne(lhs, rhs)
    failure.operation = _failure_conditions.ne
    failure.num_arguments = 2
    failure.arguments = {lhs, rhs}
    failure.expected_types = {"any", "any"}
    failure.line_num = debug.getinfo(2).currentline

    if (type(lhs) ~= type(rhs)) then
        coroutine.yield(true)

    elseif (not (lhs ~= rhs)) then
        coroutine.yield(false)

    else 
        coroutine.yield(true)
    end
end

function expect_lt(lhs, rhs)
    failure.operation = _failure_conditions.lt
    failure.num_arguments = 2
    failure.arguments = {lhs, rhs}
    failure.expected_types = {"number", "number"} 
    failure.line_num = debug.getinfo(2).currentline

    if (type(lhs) ~= "number" or type(rhs) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif (not (lhs < rhs)) then
        failure.message = "operand 1 not less than operand 2"
        coroutine.yield(false)

    else 
        coroutine.yield(true)
    end
end

function expect_lte(lhs, rhs)
    failure.operation = _failure_conditions.lte
    failure.num_arguments = 2
    failure.arguments = {lhs, rhs}
    failure.expected_types = {"number", "number"}
    failure.line_num = debug.getinfo(2).currentline


    if (type(lhs) ~= "number" or type(rhs) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif (not (lhs <= rhs)) then
        coroutine.yield(false)

    else 
        coroutine.yield(true)
    end
end

function expect_gt(lhs, rhs)
    failure.operation = _failure_conditions.gt
    failure.num_arguments = 2
    failure.arguments = {lhs, rhs}
    failure.expected_types = {"number", "number"}
    failure.line_num = debug.getinfo(2).currentline

    if (type(lhs) ~= "number" or type(rhs) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif (not (lhs > rhs)) then
        coroutine.yield(false)

    else 
        coroutine.yield(true)
    end
end

function expect_gte(lhs, rhs)
    failure.operation = _failure_conditions.gte
    failure.num_arguments = 2
    failure.arguments = {lhs, rhs}
    failure.expected_types = {"number", "number"}
    failure.line_num = debug.getinfo(2).currentline

    if (type(lhs) ~= "number" or type(rhs) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif (not (lhs >= rhs)) then
        coroutine.yield(false)

    else 
        coroutine.yield(true)
    end
end

function expect_inrange(val, lower, upper)
    failure.operation = _failure_conditions.inrange
    failure.num_arguments = 3
    failure.arguments = {val, lower, upper}
    failure.expected_types = {"number", "number", "number"}
    failure.line_num = debug.getinfo(2).currentline

    if (type(val) ~= "number" or type(lower) ~= "number" or type(upper) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    else
        if (lower > upper) then
            failure.additional_msg = ". invalid range, lower > upper"
            coroutine.yield(false)

        elseif val >= lower and val <= upper then
            coroutine.yield(true)

        else
            coroutine.yield(false)
        end
    end
end

function expect_contains(table, val)
    failure.operation = _failure_conditions.contains
    failure.num_arguments = 2
    failure.arguments = {table, val}
    failure.expected_types = {"table", "non-nil and non-table"}
    failure.line_num = debug.getinfo(2).currentline

    if type(table) ~= "table" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif type(val) == "nil" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif type(val) == "table" then
        failure.additional_msg = ". contained value cannot be a table, use expect_containstable() instead"
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    else
        found = false
        for _,v in pairs(table) do
            if v == val then found = true end
        end
        if not found then
            coroutine.yield(false)

        else
            coroutine.yield(true)
        end
    end
end

function expect_type(value, type)
    failure.operation = _failure_conditions.type
    failure.num_arguments = 2
    failure.arguments = {lhs, rhs}
    failure.expected_types = {"any", "type-string"}
    failure.line_num = debug.getinfo(2).currentline

    if (type(type) ~= "string") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif (not (lhs >= rhs)) then
        coroutine.yield(false)

    else 
        coroutine.yield(true)
    end
end

function expect_error(func, ...)
    failure.operation = _failure_conditions.error
    failure.num_arguments = 1
    failure.arguments = {func}
    failure.expected_types = {"function"}
    failure.line_num = debug.getinfo(2).currentline

    if (type(func) ~= "function") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)
    end

    success = pcall(func, ...)
    if not success then 
        coroutine.yield(true)

    else
        coroutine.yield(false)
    end
end

function expect_noerror(func, ...)
    failure.operation = _failure_conditions.noerror
    failure.num_arguments = 1
    failure.arguments = {func}
    failure.expected_types = {"function"}
    failure.line_num = debug.getinfo(2).currentline

    if (type(func) ~= "function") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)
    end

    success = pcall(func, ...)
    if success then
        coroutine.yield(true)

    else
        coroutine.yield(false)
    end
end

local function check_tables(ltable, rtable)
    local are_equal = true
    if type(rtable) ~= "table" or type(ltable) ~= "table" then 
        failure.message = "non-table arguments"
        are_equal = false
    elseif (#ltable ~= #rtable) then
        are_equal = false
    else
        for k,v in pairs(ltable) do
            if type(v) == "table" then
                if type(rtable[k]) == "table" then
                    are_equal = check_tables(v, rtable[k])
                else
                    are_equal = false
                end 
            elseif (rtable[k] ~= v) then
                are_equal = false
            end
        end
    end
    return are_equal
end


function expect_tableeq(ltable, rtable)
    failure.operation = _failure_conditions.tableeq
    failure.num_arguments = 2
    failure.arguments = {"left hand table", "right hand table"}
    failure.expected_types = {"table", "table"}
    failure.line_num = debug.getinfo(2).currentline

    if type(ltable) ~= "table" or type(rtable) ~= "table" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    else
        local equal = check_tables(ltable, rtable)
        if equal then
            coroutine.yield(true)

        else
            coroutine.yield(false)
        end
    end
end

function expect_tablene(ltable, rtable)
    failure.operation = _failure_conditions.tablene
    failure.num_arguments = 2
    failure.arguments = {"left hand table", "right hand table"}
    failure.expected_types = {"table", "table"}
    failure.line_num = debug.getinfo(2).currentline

    local equal = check_tables(ltable, rtable)
    if not equal then
        coroutine.yield(true)

    else
        coroutine.yield(false)
    end
end

local function search_table(table, tval)
    local found = false
    for _,v in pairs(table) do
        if type(v) == "table" then
            found = check_tables(v, tval)
            if not found then 
                found = search_table(v, tval)
            else
                return true
            end
        end
    end
    return found
end

function expect_containstable(table, tval)
    failure.operation = _failure_conditions.containstable
    failure.num_arguments = 2
    failure.arguments = {table, tval}
    failure.expected_types = {"table", "table"}
    failure.line_num = debug.getinfo(2).currentline

    if type(table) ~= "table" or type(tval) ~= "table" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)
    
    else
        local found = search_table(table, tval)
        if found then 
            coroutine.yield(true)

        else
            coroutine.yield(false)
        end
    end
end

function expect(expression) 
    failure.operation = _failure_conditions.istrue
    failure.num_arguments = 1
    failure.arguments = {expression}
    failure.expected_types = {"bool"}
    failure.line_num = debug.getinfo(2).currentline

    if (type(expression) ~= "boolean") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif (not expression) then
        coroutine.yield(false)

    else 
        coroutine.yield(true)
    end
end

function expect_failure(test_func, expected_err, ...)
    failure.operation = _failure_conditions.failure
    failure.num_arguments = 2
    failure.arguments = {test_func, expected_err}
    failure.line_num = debug.getinfo(2).currentline
    failure.expected_types = {"function", "string/nil"}

    if (type(test_func) ~= "function") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif (type(expected_err) ~= "string" and type(expected_err) ~= "nil") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    else
        failure.reset()
        local success =  run_test(test_func, ...)
        msg = get_failure_msg()

        failure.operation = _failure_conditions.failure
        failure.num_arguments = 0
        failure.arguments = {}
        failure.line_num = debug.getinfo(2).currentline
        failure.expected_types = {"function", "string"}

        if success then 
            failure.additional_msg = "expected test function to fail" 
            coroutine.yield(false)

        else
            if expected_err ~= nil then
                if string.find(msg, expected_err) then
                    coroutine.yield(true)

                else
                    failure.additional_msg = "test function failure message did not contain the expected message"
                    coroutine.yield(false)
                end

            else
                coroutine.yield(true)
            end
        end
    end
end