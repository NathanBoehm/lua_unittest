------------------------------------------------------------
--
-- Lua Unit Testing Framework
--
-- Simply put "require 'unittest'" and "load_modules(<module1>, <module2>, ...)" at the top of the unittest file
-- and define all tests as: tests["<test_name>"] = function (...) ...  -  or use add_test(name{str}, test{func})
-- To run the tests, call run_all_tests() or start()
--
-- Created by Nathan Boehm, 2019


--[[        unit testing functions

    expect_eq(lhs, rhs):                          verifies that 'lhs' is equal to 'rhs', 'lhs' and 'rhs' must be of the same type.
    expect_ne(lhs, rhs):                          verifies that 'lhs' is not equal to 'rhs', succeeds if arguments are of different types.
    expect_lt(lhs, rhs):                          verifies that 'lhs' is less than 'rhs', 'lhs' and 'rhs' must be of the same type. Fails if 'lhs' is equal to 'rhs'.
    expect_lte(lhs, rhs):                         same as expect_lt, except 'lhs' and be equal to 'rhs'.
    expect_gt(lhs, rhs):                          verifies that 'lhs' is greater than 'rhs', 'lhs' and 'rhs' must be of the same type. Fails if 'lhs' is equal to 'rhs'.
    expect_gte(lhs, rhs):                         same as expect_gt, except 'lhs' can be equal to 'rhs'.
    expect_inrange(val, lower, upper):            verifies that 'val' is >= 'lower' and <= 'upper'. Fails if any argument is not a number.
    expect_not_inrange(val, lower, upper):        verifies that 'val' is > 'upper' or < 'lower'. Fails if anhy argument is not a number.
    expect_contains(table, val):                  verifies that 'table' contains at least one instance of 'val', 'val' cannot be nil.
    expect_doesnt_contain(table, val):            verifies that 'table' does not contain any instance of 'val', 'val' cannot be nil.
    expect_type(value, type):                     verifies that 'value' is of type 'type', 'type' must be a string and represent a valid type.
    expect_not_type(value, type):                 verifies that 'value' is not of type 'type', 'type' must be a stirng and represent a valid type.
    expect_error(function, ...):                  verifies that 'function' produces an error when run, 'function' must be a funciton. 
                                                    '...' is an optional, variable number of arguments that the function will be called with.
                                                        NOTE: '...' args are not validated and bad arguments can crash the unittesting framework
    expect_noerror(function, ...):                verifies that 'function' produces an error when run, 'function' must be a function.
                                                    '...' is an optional, variable number of arguments that the function will be called with.
                                                        NOTE: '...' args are not validated and bad arguments can crash the unittesting framework
    expect_close(value, target, magnitudeDif):    verifies that the difference between 'target' and 'value' is less than or equal to abs('magnitudeDif' * 'target'). Fails 
                                                        any argument is not a number. A negative magnitude is treated as a positive.
    expect_true(expression):                      verifies that 'expression' evaluates to true, 'expression' must evaluate to a boolean.
    expect_false(expression):                     verifies that 'expression' evaluates to false, 'expression' must evaluate to a boolean.
    expect_failure(test_func, expected_err, ...): verifies that the given function would fail if run as a test. (Probably not useful unless testing the unittest module itself - will be removed form 'release' version)
                                                    Optional string 'expected_err', if set, searches the function failure msg for 'expected_err', fails if it is not found. 
                                                        If there are multiple failure messages within an expect_failure call, then each failure message will be check for 'expect_err'
                                                    '...' is an optional, variable number of arguments that the function will be called with
                                                        NOTE: '...' args are not validated and bad arguments can crash the unittesting framework
]]


--tests proxy table to relate index->name and index->test, to maintain that tests are run in the order that they are defined
tests = {size = 0}
local _tests_name = {}
local _tests = tests
tests = {}

local assert = true
local expect = false

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
    eq             = "arguments were not equal",
    ne             = "arguments were equal",
    lt             = "argument 1 was not less than argument 2",
    lte            = "argument 1 was not less than or equal to argument 2",
    gt             = "argument 1 was not greater than argument 2",
    gte            = "argument 1 was not greater than or equal to argument 2",
    inrange        = "value was not in range",
    not_inrange    = "value was in range",
    contains       = "table did not contain value",
    doesnt_contain = "table contained value",
    type           = "value was not of expected type",
    not_type       = "value was of the incorrect type",
    error          = "function did not produce error",
    noerror        = "function produced an error",
    close          = "value was not close enough to target value",
    not_close      = "value was too close to the target value",
    istrue         = "expression was false",
    isfalse        = "expression was true",
    failure        = "",

    --arg_errors
    badtype   = "argument was of incorrect type -",
    difftypes = "arguments of different types -",
    badrange  = "invalid range, lower > upper"
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

local function get_failure_msg(prefix)
    local msg = ""

    if (failure.line_num == nil) then
        msg = "unexpected failure: bad argument passed to expect-function"
        return msg
    end

    if (failure.unexpected_error ~= nil) then
        msg = "unexpected failure on line " .. failure.line_num .. ": " .. failure.unexpected_error
        return msg
    end

    msg = prefix .. "failure on line " .. failure.line_num .. ": "

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
    
    else

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
            if (failure.additional_msg ~= "") then
                msg = msg .. failure.additional_msg .. " - {" .. failure.arguments[2] .. "," .. failure.arguments[3] .. "}"
            else
                msg = msg .. _failure_conditions.inrange .. ", expected: " .. failure.arguments[1] .. " in range " .. "{" .. failure.arguments[2] .. "," .. failure.arguments[3] .. "}"
            end
        elseif failure.operation == _failure_conditions.not_inrange then
            if (failure.additional_msg ~= "") then
                msg = msg .. failure.additional_msg .. " - {" .. failure.arguments[2] .. "," .. failure.arguments[3] .. "}"
            else
                msg = msg .. _failure_conditions.not_inrange .. ", expected: " .. failure.arguments[1] .. " in range " .. "{" .. failure.arguments[2] .. "," .. failure.arguments[3] .. "}"
            end
        elseif failure.operation == _failure_conditions.contains then
            msg = msg .. _failure_conditions.contains .. failure.additional_msg .. ", expected: table to contain " .. failure.arguments[2]
        elseif failure.operation == _failure_conditions.doesnt_contain then
            msg = msg .. _failure_conditions.doesnt_contain .. failure.additional_msg .. ", expected: table to not contain " .. failure.arguments[2]
        elseif failure.operation == _failure_conditions.type then
            msg = msg .. _failure_conditions.type .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " to be of type " .. string.sub(failure.arguments[2], 1, -1)
        elseif failure.operation == _failure_conditions.not_type then
            msg = msg .. _failure_conditions.not_type .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " to not be of type " .. string.sub(failure.arguments[2], 1, -1)
        elseif failure.operation == _failure_conditions.error then
            msg = msg .. _failure_conditions.error .. failure.additional_msg .. ", expected: function to produce error"
        elseif failure.operation == _failure_conditions.noerror then
            msg = msg .. _failure_conditions.noerror .. failure.additional_msg .. ", expected: function to not produce error"
        elseif failure.operation == _failure_conditions.close then
            msg = msg .. _failure_conditions.close .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " to be within ±" .. failure.arguments[3] .. " of " .. failure.arguments[2]
        elseif failure.operation == _failure_conditions.not_close then
            msg = msg .. _failure_conditions.not_close .. failure.additional_msg .. ", expected: " .. failure.arguments[1] .. " to be at least ±" .. failure.arguments[3] .. " away from " .. failure.arguments[2]
        elseif failure.operation == _failure_conditions.istrue then
            msg = msg .. _failure_conditions.istrue .. failure.additional_msg .. ", expected: expression to be true"
        elseif failure.operation == _failure_conditions.isfalse then
            msg = msg .. _failure_conditions.isfalse .. failure.additional_msg .. ", expected: expression to be false"
        elseif failure.operation == _failure_conditions.failure then
            msg = msg .. _failure_conditions.failure .. failure.additional_msg
        end
    end

    failure.reset()
    return msg
end

local function run_test(test, ...)
    local test_routine = coroutine.create(test)
    local test_passed = true
    local failure_log = {}
    local failure_count = 0
    while (true) do --continue running regardless of expect_<>() results until the end of the function is reached or an unexpected error occurs
        op_status, yield_val, is_assert = coroutine.resume(test_routine, ...) --FLAG: consider an assert return that immeadiately ends the operation, for assert functions

        if (op_status == false) then 
            failure.unexpected_error = yield_val
            test_passed = false
            failure_count = failure_count + 1
            failure_log[failure_count] = get_failure_msg()
            break --no reason to continue in this case
        end

        if (yield_val == false) then
            test_passed = false
            failure_count = failure_count + 1
            if (is_assert) then
                failure_log[failure_count] = get_failure_msg("assert ")
                break
            else
                failure_log[failure_count] = get_failure_msg("expect ")
            end
        end

        if (coroutine.status(test_routine) == "dead") then --end of function reached
            break
        end
    end

    return test_passed, failure_log
end

function run_all_tests()
    io.write("\n", cyan, "---BEGIN TESTS---", endcolor, "\n\n")
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
            local test_group_name = (type(test_group) == "string" and "[" .. test_group .. "]" or "[TEST]")
            io.write(test_group_name, "[", name, "]:", offset)
            local test_passed, failure_log = run_test(test)

            if (test_passed == true) then
                io.write(green, "PASSED", endcolor, "\n")
            else
                io.write(red, "FAILED", endcolor, "\n")
                for _,err_msg in ipairs(failure_log) do
                    io.write(yellow, err_msg, endcolor, "\n\n")
                end
            end
        else
            io.write(yellow, "UNIT TEST ERROR: test \"", name, "\" was not a function!\n", endcolor)
        end
    end
    io.write("\n", cyan, "---END TESTS---", endcolor, "\n\n")
end

function add_test(name, test)
    if (type(name) ~= "string") then io.write("test name was not a valid string\n") return end --FLAG: why is there a return here?
    if (type(test) ~= "function") then io.write("test was not a valid function\n") return end

    tests[name] = test
end

function start()
    run_all_tests()
end

--helpers

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
                    if not are_equal then return are_equal end --must return false here or a subsequent pair of subtables that are the same will overwrite this.
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

local function search_table(table, val)
    local found = false
    for _,v in pairs(table) do
        if (type(v) == "table") then
            found = search_table(v, val)
        else
            if (v == val) then
                return true
            end
        end
    end
    return found
end

local function search_tablet(table, tval)
    local found = false
    for _,v in pairs(table) do
        if (type(v) == "table") then
            found = check_tables(v, tval)
            if (not found) then 
                found = search_tablet(v, tval)
            else
                return true
            end
        end
    end
    return found
end

--expect/assert definitions

--equal/not-equal

local function _eq(lhs, rhs) --not set_eq_failure() needed because there is no yeild prior to the calls to _eq
    failure.num_arguments = 2
    failure.arguments = {lhs, rhs}
    failure.expected_types = {"any", "any"}
    failure.line_num = debug.getinfo(4).currentline

    if (type(lhs) ~= type(rhs)) then
        failure.arg_error = _failure_conditions.difftypes
        return false

    elseif (type(lhs) == "table") then
        local tables_eq = check_tables(lhs, rhs)
        return tables_eq

    else
        return (lhs == rhs)
    end
end

local function test_eq(is_assert, lhs, rhs)
    failure.operation = _failure_conditions.eq
    coroutine.yield( _eq(lhs, rhs), is_assert )
end

function assert_eq(lhs, rhs)
    test_eq(assert, lhs, rhs)
end
function expect_eq(lhs, rhs)
    test_eq(expect, lhs, rhs)
end


local function test_ne(is_assert, lhs, rhs)
    failure.operation = _failure_conditions.ne
    coroutine.yield( not _eq(lhs, rhs), is_assert )
end

function assert_ne(lhs, rhs)
    test_ne(assert, lhs, rhs)
end
function expect_ne(lhs, rhs)
    test_ne(expect, lhs, rhs)
end


--less-than/greater-than


local function set_ltgt_failure(lhs, rhs)
    failure.num_arguments = 2
    failure.arguments = {lhs, rhs}
    failure.expected_types = {"number", "number"} 
    failure.line_num = debug.getinfo(4).currentline
end

local function test_lt(is_assert, lhs, rhs)
    set_ltgt_failure(lhs, rhs)
    failure.operation = _failure_conditions.lt

    if (type(lhs) ~= "number" or type(rhs) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    else
        coroutine.yield( (lhs < rhs), is_assert )
    end
end

function assert_lt(lhs, rhs)
    test_lt(assert, lhs, rhs)
end
function expect_lt(lhs, rhs)
    test_lt(expect, lhs, rhs)
end


local function test_gt(is_assert, lhs, rhs)
    set_ltgt_failure(lhs, rhs)
    failure.operation = _failure_conditions.gt

    if (type(lhs) ~= "number" or type(rhs) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    else
        coroutine.yield( (lhs > rhs), is_assert )
    end
end

function assert_gt(lhs, rhs)
    test_gt(assert, lhs, rhs)
end
function expect_gt(lhs, rhs)
    test_gt(expect, lhs, rhs)
end


local function test_lte(is_assert, lhs, rhs)
    set_ltgt_failure(lhs, rhs)
    failure.operation = _failure_conditions.lte
    
    if (type(lhs) ~= "number" or type(rhs) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    else
        coroutine.yield( (lhs <= rhs), is_assert )
    end
end

function assert_lte(lhs, rhs)
    test_lte(assert, lhs, rhs)
end
function expect_lte(lhs, rhs)
    test_lte(expect, lhs, rhs)
end


local function test_gte(is_assert, lhs, rhs)
    set_ltgt_failure(lhs, rhs)
    failure.operation = _failure_conditions.gte
    failure.line_num = debug.getinfo(3).currentline

    if (type(lhs) ~= "number" or type(rhs) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    else
        coroutine.yield( (lhs >= rhs), is_assert )
    end
end

function assert_gte(lhs, rhs)
    test_gte(assert, lhs, rhs)
end
function expect_gte(lhs, rhs)
    test_gte(expect, lhs, rhs)
end


--inrange


local function set_inrange_failure(val, lower, upper)
    failure.num_arguments = 3
    failure.arguments = {val, lower, upper}
    failure.expected_types = {"number", "number", "number"}
    failure.line_num = debug.getinfo(4).currentline
end

local function _inrange(val, lower, upper)
    return (val >= lower and val <= upper)
end

local function _inrange_strict(val, lower, upper)
    return (val > lower and val < upper)
end

local function test_inrange(is_assert, val, lower, upper, strict)
    set_inrange_failure(val, lower, upper)
    failure.operation = _failure_conditions.inrange

    if (type(val) ~= "number" or type(lower) ~= "number" or type(upper) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    else
        if (lower > upper) then
            failure.additional_msg = _failure_conditions.badrange
            coroutine.yield(false, is_assert)

        elseif (strict == true) then
            coroutine.yield( _inrange_strict(val, lower, upper), is_assert )

        else --anything other than true (and crucially nil) is considered to be not strict
            coroutine.yield( _inrange(val, lower, upper), is_assert )
        end
    end
end

function assert_inrange(val, lower, upper, strict)
    test_inrange(assert, val, lower, upper, strict)
end
function expect_inrange(val, lower, upper,  strict)
    test_inrange(expect, val, lower, upper, strict)
end


local function test_not_inrange(is_assert, val, lower, upper, strict) --ADD TESTS
    set_inrange_failure(val, lower, upper)
    failure.operation = _failure_conditions.not_inrange

    if (type(val) ~= "number" or type(lower) ~= "number" or type(upper) ~= "number") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    else
        if (lower > upper) then
            failure.additional_msg = _failure_conditions.badrange
            coroutine.yield(false, is_assert)

        elseif (strict == true) then
            coroutine.yield( not _inrange_strict(val, lower, upper), is_assert )

        else --anything other than true (and crucially nil) is considered to be not strict
            coroutine.yield( not _inrange(val, lower, upper), is_assert )
        end
    end
end

function assert_not_inrange(val, lower, upper, strict)
    test_not_inrange(assert, val, lower, upper, strict)
end
function expect_not_inrange(val, lower, upper, strict)
    test_not_inrange(expect, val, lower, upper, strict)
end


--expect contains


local function set_contains_failure(table, val)
    failure.num_arguments = 2
    failure.arguments = {table, val}
    failure.expected_types = {"table", "non-nil"}
    failure.line_num = debug.getinfo(4).currentline
end

local function _contains(table, val)
    local found = false

    if (type(val) == "table") then
        found = search_tablet(table, val)
        return found
    
    else
        found = search_table(table, val)
        return found
    end
end

local function test_contains(is_assert, table, val)
    set_contains_failure(table, val)
    failure.operation = _failure_conditions.contains

    if type(table) ~= "table" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)

    elseif type(val) == "nil" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false)
    
    else
        coroutine.yield( _contains(table, val), is_assert )
    end
end

function assert_contains(table, val)
    test_contains(assert, table, val)
end
function expect_contains(table, val)
    test_contains(expect, table, val)
end


local function test_doesnt_contain(is_assert, table, val)
    set_contains_failure(table, val)
    failure.operation = _failure_conditions.doesnt_contain

    if type(table) ~= "table" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    elseif type(val) == "nil" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    else
        coroutine.yield( not _contains(table, val), is_assert )
    end
end

function assert_doesnt_contain(table, val)
    test_doesnt_contain(assert, table, val)
end
function expect_doesnt_contain(table, val)
    test_doesnt_contain(expect, table, val)
end


--expect_type


local function set_type_failure(value, type)
    failure.num_arguments = 2
    failure.arguments = {value, type}
    failure.expected_types = {"any", "type-string"}
    failure.line_num = debug.getinfo(4).currentline
end

local function test_type(is_assert, value, t)
    set_type_failure(value, t)
    failure.operation = _failure_conditions.type

    if (type(t) ~= "string") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)
    
    else
        coroutine.yield( type(value) == t, is_assert )
    end
end

function assert_type(value, t)
    test_type(assert, value, t)
end
function expect_type(value, t)
    test_type(expect, value, t)
end


local function test_not_type(is_assert, value, t)
    set_type_failure(value, t)
    failure.operation = _failure_conditions.not_type

    if (type(t) ~= "string") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)
    
    else
        coroutine.yield( type(value) ~= t, is_assert )
    end
end

function assert_not_type(value, t)
    test_not_type(assert, value, t)
end
function expect_not_type(value, t)
    test_not_type(expect, value, t)
end


--expect_error
--I really doubt whether there is a use case for expecdt_error/noerror, but I will leave them in for now

local function set_error_failure(func)
    failure.num_arguments = 1
    failure.arguments = {func}
    failure.expected_types = {"function"}
    failure.line_num = debug.getinfo(4).currentline
end

local function _noerror(func, ...)
    success = pcall(func, ...)
    return success
end

local function test_error(is_assert, func, ...)
    set_error_failure(func)
    failure.operation = _failure_conditions.error

    if (type(func) ~= "function") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)
    else
        coroutine.yield( not _noerror(func, ...), is_assert )
    end
end

function assert_error(func, ...)
    test_error(assert, func, ...)
end
function expect_error(func, ...)
    test_error(expect, func, ...)
end


local function test_noerror(is_assert, func, ...)
    set_error_failure(func)
    failure.operation = _failure_conditions.noerror

    if (type(func) ~= "function") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)
    else
        coroutine.yield( _noerror(func, ...), is_assert )
    end
end

function assert_noerror(func, ...)
    test_noerror(assert, func, ...)
end
function expect_noerror(func, ...)
    test_noerror(expect, func, ...)
end


--expect close
--optional hardcore challenge: expect_close for strings allowing for a certain number of different characters


local function set_close_failure(value, target, magnitudeDif)
    failure.num_arguments = 3
    if (type(target) ~= "number" or type(magnitudeDif) ~= "number") then
        failure.arguments = {value, target, "bad argument"}
    else
        failure.arguments = {value, target, target * magnitudeDif}
    end
    failure.expected_types = {"number", "number", "number"}
    failure.line_num = debug.getinfo(4).currentline
end

local function _close(value, target, magnitudeDif)
    --normalize args
    if magnitudeDif < 0 then magnitudeDif = magnitudeDif * -1 end

    local allowedDif = target * magnitudeDif
    --local realValDif = adjustedVal - target

    if (target == 0) then
        allowedDif = target + magnitudeDif --FLAG: add a note about this and unit tests!
    end

    if (target >= 0) then
        return ((value >= (target - allowedDif)) and (value <= (target + allowedDif)))
    else
        return ((value <= (target - allowedDif)) and (value >= (target + allowedDif)))
    end
end

local function test_close(is_assert, value, target, magnitudeDif)
    set_close_failure(value, target, magnitudeDif)
    failure.operation = _failure_conditions.close

    if type(value) ~= "number" or type(target) ~= "number" or type(magnitudeDif) ~= "number" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)
    
    else
        coroutine.yield( _close(value, target, magnitudeDif), is_assert )
    end
end

function assert_close(value, target, magnitudeDif)
    test_close(assert, value, target, magnitudeDif)
end
function expect_close(value, target, magnitudeDif)
    test_close(expect, value, target, magnitudeDif)
end


local function test_not_close(is_assert, value, target, magnitudeDif)
    set_close_failure(value, target, magnitudeDif)
    failure.operation = _failure_conditions.not_close

    if type(value) ~= "number" or type(target) ~= "number" or type(magnitudeDif) ~= "number" then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)
    
    else
        coroutine.yield( not _close(value, target, magnitudeDif), is_assert )
    end
end

function assert_not_close(value, target, magnitudeDif)
    test_not_close(assert, value, target, magnitudeDif)
end
function expect_not_close(value, target, magnitudeDif)
    test_not_close(expect, value, target, magnitudeDif)
end

--expect/assert

local function set_tf_failure(expression)
    failure.num_arguments = 1
    failure.arguments = {expression}
    failure.expected_types = {"bool"}
    failure.line_num = debug.getinfo(4).currentline
end

local function test_true(is_assert, expression)
    set_tf_failure(expression)
    failure.operation = _failure_conditions.istrue

    if (type(expression) ~= "boolean") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    else
        coroutine.yield( expression, is_assert )
    end
end

function assert_true(expression)
    test_true(assert, expression)
end
function expect_true(expression)
    test_true(expect, expression)
end


local function test_false(is_assert, expression)
    set_tf_failure(expression)
    failure.operation = _failure_conditions.isfalse

    if (type(expression) ~= "boolean") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, is_assert)

    else
        coroutine.yield( not expression, is_assert )
    end
end

function assert_false(expression)
    test_false(assert, expression)
end
function expect_false(expression)
    test_false(expect, expression)
end


--test funciton failure


function expect_failure(test_func, expected_err, ...)
    failure.operation = _failure_conditions.failure
    failure.num_arguments = 2
    failure.arguments = {test_func, expected_err}
    failure.line_num = debug.getinfo(2).currentline
    failure.expected_types = {"function", "string/nil"}

    if (type(test_func) ~= "function") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, expect)

    elseif (type(expected_err) ~= "string" and type(expected_err) ~= "nil") then
        failure.arg_error = _failure_conditions.badtype
        coroutine.yield(false, expect)

    else
        failure.reset()
        local success, failure_log =  run_test(test_func, ...)

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
                for _,msg in pairs(failure_log) do
                    if not string.find(msg, expected_err) then
                        failure.additional_msg = "test function failure message \"" .. msg .. "\" did not contain the expected message: " .. expected_err --TODO: NEED TO TEST THAT MULTIPLE FAILURE MESSAGES SHOW UP IN OUTPUT
                        coroutine.yield(false)
                    end
                end
                coroutine.yield(true)

            else
                coroutine.yield(true)
            end
        end
    end
end