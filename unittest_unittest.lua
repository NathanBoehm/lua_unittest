------------------------------------------------------------
--
-- Lua Unit Testing Framework Unit Test
--
-- Verifies correct functionality for the expect functions provided by unitest.lua
--
--
-- Created by Nathan Boehm, 2019

--dofile("C:/Users/Nathan_Boehm/Documents/source/Lua/unittest_unittest.lua")
package.path = "C:/Users/Nathan_Boehm/Documents/source/Lua/?.lua"

require 'unittest'
load_modules()

test_group = 'unittest'

--
--test_failure
local function f()
    expect_eq(5, "5")
end

local function f2()
    expect_eq(5, 6)
end

tests["test_failure_passing"] = function ()
    expect_failure(f)
    expect_failure(f, _failure_conditions.difftypes)
    expect_failure(f2, _failure_conditions.eq)
    --expect_failure(f3, "unexpected error:")
end

--local function f_pass()
--    expect_eq(5, 5)
--end

--tests["test_failure_failing"] = function ()
--    expect_failure(f_pass)
--end
--]]
--
--expect_eq
tests["expect_eq_passing"] = function ()
    for i=0, 1000 do
        expect_eq(i,i)
    end

    expect_eq("string", "string")
    expect_eq("dsl908ajl9908097\n\n\n\n\n\t", "dsl908ajl9908097\n\n\n\n\n\t")
    expect_eq("{\":::<>()*&&^%$#@!}", "{\":::<>()*&&^%$#@!}")

    expect_eq(type({1}), type({2}))

    expect_eq(true, true)
    expect_eq(false, false)

    expect_eq(nil, nil)
end

tests["expect_eq_failing_noteq1"] = function ()
    local function f() expect_eq(5, 6) end
    expect_failure(f,  _failure_conditions.eq)
end

tests["expect_eq_failing_noteq2"] = function ()
    local function f() expect_eq(true, false) end
    expect_failure(f, _failure_conditions.eq)
end

tests["expect_eq_failing_noteq3"] = function ()
    local function f() expect_eq("string", "String") end
    expect_failure(f, _failure_conditions.eq)
end

tests["expect_eq_failing_difftypes1"] = function ()
    local function f() expect_eq("5", 5) end
    expect_failure(f, _failure_conditions.difftypes)
end

tests["expect_eq_failing_difftypes2"] = function ()
    local function f() expect_eq(nil, "nil") end
    expect_failure(f,  _failure_conditions.difftypes)
end

tests["expect_eq_failing_difftypes3"] = function ()
    local function f() expect_eq(true, "true") end
    expect_failure(f,  _failure_conditions.difftypes)
end

tests["expect_eq_failing_difftypes4"] = function ()
    local function f() expect_eq(func, 5) end
    expect_failure(f, _failure_conditions.difftypes)
end

tests["expect_eq_failing_missing_args"] = function ()
    local function f() expect_eq(6) end
    expect_failure(f)
end

--tests["failing_tomany_args"] = function ()
--    expect_eq(5,5,4) -- true because extra args are ignored
--end

--tests["failing_missing_args2"] = function ()
--    expect_eq() --true because nil == nil
--end

tests["expect_eq_failing_volume"] = function ()
    local function f(v1,v2) expect_eq(v1,v2) end
    for i=0, 1000 do
        expect_failure(f, _failure_conditions.failure, i, i+1)
    end
end
--]]

--
--expect_ne
tests["expect_ne_passing"] = function ()
    expect_ne("String", "string")
    expect_ne("amazin", "amazin ")
    expect_ne("amazin\n", "amazin")

    expect_ne(type("5"), type(5))

    expect_ne("5", 5)

    expect_ne(true, false)

    expect_ne(nil, "not nil")
end

tests["expect_ne_passing_volume"] = function ()
    for i=0, 100 do
        expect_ne(i,i+1)
    end
end


tests["expect_ne_failing1"] = function ()
    local function f() expect_ne("\t", "\t") end
    expect_failure(f)
end

tests["expect_ne_failing2"] = function ()
    local function f() expect_ne(5,5) end
    expect_failure(f)
end

tests["expect_ne_failing3"] = function ()
    local function f() expect_ne(true, true) end
    expect_failure(f)
end

tests["expect_ne_failing4"] = function ()
    local function f() expect_ne(false, false) end
    expect_failure(f)
end

--[[tests["failing_missing_args"] = function ()
    local function f() expect_ne(6) end --not a failure because 6 is compared to nil which is not equal
    expect_failure(f)
end--]]

tests["expect_ne_failing5"] = function ()
    local function f() expect_ne(nil, nil) end
    expect_failure(f)
end

tests["expect_ne_failing_volume"] = function ()
    local function f(v1,v2) expect_ne(v1,v2) end
    for i=0, 1000 do
        expect_failure(f, _failure_conditions.failure, i, i)
    end
end
--]]

--
--expect_lt
test_group = "expect_lt"
tests["expect_lt_passing"] = function ()
    expect_lt(4,5)
    expect_lt(0,1)
    expect_lt(-1, 0)
    expect_lt(-1,1)
end

tests["expect_lt_passing_volume"] = function ()
    for i=0,1000 do
        expect_lt(i, i+1)
    end
end

tests["expect_lt_failing1_nonnum"] = function ()
    local function f() expect_lt("5", 6) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_lt_failing1_nonnum2"] = function ()
    local function f() expect_lt("5", "6") end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_lt_failing_nonnum3"] = function ()
    local function f() expect_lt(true, 2) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_lt_failing1"] = function ()
    local function f() expect_lt(1,1) end
    expect_failure(f, _failure_conditions.lt)
end

tests["expect_lt_failing2"] = function ()
    local function f() expect_lt(1,0) end
    expect_failure(f, _failure_conditions.lt)
end

tests["expect_lt_failing_volume"] = function ()
    local function f(i,j) expect_lt(i,j) end
    for i=0,1000 do
        expect_failure(f, _failure_conditions.failure, i, i)
    end
    for i=0,1000 do
        expect_failure(f, _failure_conditions.failure, i, i-1)
    end
end
--]]

--
--expect_lte
tests["expect_lte_passing"] = function ()
    expect_lte(1, 2)
    expect_lte(1, 1)
    expect_lte(-1, 1)
    expect_lte(-1, 0)
    expect_lte(0, 0)
    expect_lte(-1, -1)
end

tests["expect_lte_passing_volume"] = function ()
    for i=0, 1000 do
        expect_lte(i, i+1)
    end
    for i=0, 1000 do
        expect_lte(i, i)
    end
end

tests["expect_lte_failing1"] = function ()
    local function f() expect_lte("5", 6) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_lte_failing2"] = function ()
    local function f() expect_lte(true, 0) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_lte_failing3"] = function ()
    local function f() expect_lte(1,0) end
    expect_failure(f, _failure_conditions.lte) 
end

tests["expect_lte_failing4"] = function ()
    local function f() expect_lte(5,4) end
    expect_failure(f, _failure_conditions.lte)
end

tests["expect_lte_failing_volume"] = function ()
    local function f(i,j) expect_lte(i,j) end
    for i=0,1000 do
        expect_failure(f, _failure_conditions.failure, i+1, i)
    end
end
--]]

--
--expect_gt
tests["expect_gt_passing"] = function ()
    expect_gt(1,0)
    expect_gt(0,-1)
    expect_gt(1,-1)
    expect_gt(5,4)
    expect_gt(1.001, 1)
end

tests["expect_gt_passing_volume"] = function ()
    for i=0,1000 do
        expect_gt(i+1, i)
    end
end

tests["expect_gt_failing1"] = function ()
    local function f() expect_gt(true, 1) end 
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_gt_failing2"] = function ()
    local function f() expect_gt("6", 5) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_gt_failing3"] = function ()
    local function f() expect_gt(5, 6) end
    expect_failure(f, _failure_conditions.gt)
end

tests["expect_gt_failing4"] = function ()
    local function f() expect_gt(1, 1.00001) end
    expect_failure(f, _failure_conditions.gt)
end

tests["expect_gt_failing5"] = function ()
    local function f() expect_gt(1,1) end
    expect_failure(f, _failure_conditions.gt) 
end

tests["expect_gt_failing6"] = function ()
    local function f() expect_gt(-1,-1) end
    expect_failure(f, _failure_conditions.gt)
end

tests["expect_gt_failing_volume"] = function ()
    local function f(i,j) expect_gt(i,j) end
    for i=0,1000 do
        expect_failure(f, _failure_conditions.failure, i, i)
    end
    for i=0,1000 do
        expect_failure(f, _failure_conditions.failure, i, i+1)
    end
end
--]]

--
--expect_gte
tests["expect_gte_passing"] = function ()
    expect_gte(1,0)
    expect_gte(0,0)
    expect_gte(1,1)
    expect_gte(1,1)
    expect_gte(-1,-1)
end

tests["expect_gte_passing_volume"] = function ()
    for i=0,1000 do
        expect_gte(i,i)
    end
    for i=0,1000 do
        expect_gte(i+1,i)
    end
end

tests["expect_gte_failing1"] = function ()
    local function f() expect_gt(true, 1) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_gte_failing2"] = function ()
    local function f() expect_gt("6", 5) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_gte_failing3"] = function ()
    local function f() expect_gte(5, 6) end
    expect_failure(f, _failure_conditions.gte)
end

tests["expect_gte_failing4"] = function ()
    local function f() expect_gte(1, 1.00001) end
    expect_failure(f, _failure_conditions.gte)
end

tests["expect_gte_failing5"] = function ()
    local function f() expect_gte(77, 77.1) end
    expect_failure(f, _failure_conditions.gte)
end
--]]

--[[
function _test()
    expect_eq(5, 6)
end

function __test()
    _test()
end

tests["func_test_failing"] = function ()
    __test()
end
--]]

--
--expect_error
function err_func()
    a.b.c = 10
end

function err_func2()
    local c = "a" * "b"
end

function err_func3()
    local a = {1} .. {2}
end

function noerr_func()
    local c =  "a" .. "b"
    local d = 9 * 8
    local e = type(d)
end

tests["expect_error_passing"] = function ()
    expect_error(err_func)
    expect_error(err_func2)
end

tests["expect_error_passing_multargs"] = function ()
    local function f(a,b,c) local d = a*b*c; return d end
    expect_error(f, "ha!", "lol", "no")
end

tests["expect_error_failing_multargs"] = function ()
    local function f(a,b,c) local d = a*b*c; return d end
    local function f1() expect_error(f, 5, 6, 7) end
    expect_failure(f1, _failure_conditions.error)
end

tests["expect_error_failing"] = function ()
    local function f() expect_error(noerr_func) end
    expect_failure(f, _failure_conditions.error) 
end

tests["expect_error_failing2"] = function ()
    local function f() expect_error(true) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_error_failing3"] = function ()
    local function f() expect_error(10) end
    expect_failure(f, _failure_conditions.badtype) 
end

tests["expect_error_failing4"] = function ()
    local function f() expect_error("string") end
    expect_failure(f, _failure_conditions.badtype)
end
--]]

--
--noerror
tests["expect_noerror_passing"] = function ()
    expect_noerror(noerr_func)
end

tests["expect_noerror_failing1"] = function ()
    local function f() expect_noerror(err_func) end
    expect_failure(f, _failure_conditions.noerror)
end

tests["expect_noerror_failing2"] = function ()
    local function f() expect_noerror(err_func2) end
    expect_failure(f, _failure_conditions.noerror)
end

tests["expect_noerror_failing3"] = function ()
    local function f() expect_noerror(4) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_noerror_failing4"] = function ()
    local function f() expect_noerror(true) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_noerror_failing5"] = function ()
    local function f() expect_noerror("string") end
    expect_failure(f, _failure_conditions.badtype)
end
--]]

--
--expect
tests["expect_passing"] = function ()
    expect(5 == 5)
    expect(true)
    expect(type("s") == "string")
end

tests["expect_failing1"] = function ()
    local function f() expect(false) end
    expect_failure(f, _failure_conditions.istrue)
end

tests["expect_failing2"] = function ()
    local function f() expect(5 == 6) end
    expect_failure(f, _failure_conditions.istrue)
end

tests["expect_failing3"] = function ()
    local function f() expect(type(5) == "string") end
    expect_failure(f, _failure_conditions.istrue)
end

tests["expect_failing_badtype"] = function ()
    local function f() expect({1,2,3}) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_failing_badtype2"] = function ()
    local function f() expect("string") end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_failing_error"] = function ()
    local function f() expect(a.b.c.d) end
    expect_failure(f)
end
--]]

--
--tableeq
tests["tableeq_passing"] = function ()
    expect_tableeq({1,2,3}, {1,2,3})
    expect_tableeq({["k1"] = "string", 2, "string", ["k2"] = 99}, {["k1"] = "string", 2, "string", ["k2"] = 99})
    local t1 = {1,2, k={3,4}}
    local t2 = {1,k={3,4},2}
    expect_tableeq(t1, t2)
    local t3 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t4 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    expect_tableeq(t3,t4)
    expect_tableeq(t3,t3)
end

--TODO: volume test?

tests["tableeq_failing_size"] = function ()
    local function f() expect_tableeq({1,2,3}, {1,2}) end
    expect_failure(f, _failure_conditions.tableeq)
end

tests["tableeq_failing_diff"] = function ()
    local function f() expect_tableeq({1,2,3}, {1,2,4}) end 
    expect_failure(f, _failure_conditions.tableeq)
end

tests["tableeq_failing_diff_nested"] = function ()
    local t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t2 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["v"] = 1}}, 2}
    local function f() expect_tableeq(t1, t2) end
    expect_failure(f, _failure_conditions.tableeq)
end

tests["tableeq_failing_diff_nested"] = function ()
    local t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t2 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 2}}, 2}
    local function f() expect_tableeq(t1, t2) end
    expect_failure(f, _failure_conditions.tableeq) 
end

tests["tableeq_difftypes"] = function ()
    local function f() expect_tableeq({1,2}, 1) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["tableeq_difftypes2"] = function ()
    local function f() expect_tableeq(true, {1,2}) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["tableeq_difftypes3"] = function ()
    local function f() expect_tableeq("string", {1,2}) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["tableeq_difftypes4"] = function ()
    local function f() expect_tableeq(nil, {1,2}) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["tableeq_difftypes4"] = function ()
    local function f() expect_tableeq(1,1) end
    expect_failure(f, _failure_conditions.badtype)
end
--]]

--
--tablene
tests["tablene_passing"] = function ()
    expect_tablene({1,2,3}, {1,2})
    expect_tablene({1,2,3}, {1,2,4})
    local t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t2 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 2}}, 2}
    expect_tablene(t1, t2)
    local t3 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t4 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["v"] = 1}}, 2}
    expect_tablene(t1, t2)
end

--TODO: volume test?

tests["tablene_failing"] = function ()
    local function f() expect_tablene({1,2,3,4}, {1,2,3,4}) end
    expect_failure(f, _failure_conditions.tablene)
end

tests["tablene_failing2"] = function ()
    local t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t2 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local function f() expect_tablene(t1, t2) end
    expect_failure(f, _failure_conditions.tablene)
end
--]]

--
--expect_containstable
tests["containstable_passing"] = function ()
    expect_containstable({true,{false}}, {false})
    expect_containstable({{}},{})

    local t1 = {1,2, {1,2,3}}
    local t2 = {1,2,3}
    expect_containstable(t1,t2)

    local t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = {"super sub table", "ye", 1}}}, 2}
    local t2 =  {"super sub table", "ye", 1}
    expect_containstable(t1, t2)
end

tests["containstable_failing"] = function ()
    local t1 = {1,2, {1,2,3}}
    local t2 = {1,2}
    local function f() expect_containstable(t1,t2) end
    expect_failure(f, _failure_conditions.containstable)
end

tests["containstable_failing2"] = function ()
    local t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = {"super sub table", "ye", 1}}}, 2}
    local t2 =  {"super (not) sub table", "ye", 1}
    local function f() expect_containstable(t1, t2) end
    expect_failure(f, _failure_conditions.containstable)
end

tests["containstable_failing3"] = function ()
    t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = {"super sub table", "ye", 1}}}, 2}
    t2 = {"who dis?"}
    local function f() expect_containstable(t1, t2) end
    expect_failure(f, _failure_conditions.containstable)
end

tests["containstable_failing_badtypes1"] = function ()
    local function f() expect_containstable({1,2}, 1) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["containstable_failing_badtypes2"] = function ()
    local function f() expect_containstable("yeyeyeye", {1}) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["containstable_failing_badtypes3"] = function ()
    local function f() expect_containstable(true, {true}) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["containstable_failing_badtypes4"] = function ()
    local function f() expect_containstable(nil, {1}) end
    expect_failure(f)
end

--]]

--
--inrange
tests["expect_inrange_passing"] = function ()
    expect_inrange(5, 4,6)
    expect_inrange(0, -1,1)
    expect_inrange(0, 0,0)
    expect_inrange(-2, -3,-2)
end

tests["expect_inrange_failing"] = function ()
    local function f() expect_inrange(2, 0,1) end
    expect_failure(f, _failure_conditions.inrange)
end

tests["expect_inrange_failing2"] = function ()
    local function f() expect_inrange(-1, -4, -3) end
    expect_failure(f, _failure_conditions.inrange)
end

tests["expect_inrange_failing3"] = function ()
    local function f() expect_inrange(1, 4, 3) end
    expect_failure(f, _failure_conditions.inrange)
end

tests["expect_inrange_failing4"] = function ()
    local function f() expect_inrange("str", 0,1) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_inrange_failing4"] = function ()
    local function f() expect_inrange(1, "str", 0) end
    expect_failure(f, _failure_conditions.badtype)
end

tests["expect_inrange_failing5"] = function ()
    local function f() expect_inrange(1, 0, true) end
    expect_failure(f, _failure_conditions.badtype)
end
--]]

--
--contains
tests["expect_contains_passing"] = function ()
    expect_contains({1,2,3}, 1)
    expect_contains({1,2,3}, 2)
    expect_contains({1,2,3}, 3)
    t1 = {true, false, 4, "string"}
    expect_contains(t1, true)
    expect_contains(t1, false)
    expect_contains(t1, 4)
    expect_contains(t1, "string")
end

tests["expect_contains_failing"] = function ()
    local function f() expect_contains({1,2,3}, 4) end
    expect_failure(f, _failure_conditions.contains)
end

tests["expect_contains_faling2"] = function ()
    local function f() expect_contains({nil}, nil) end
    expect_failure(f, _failure_conditions.contains)
end

tests["expect_contains_failing3"] = function ()
    local function f() expect_contains({true}, false) end
    expect_failure(f, _failure_conditions.contains)
end

tests["expect_contains_failing4"] = function ()
    local function f() expect_contains({}, "empty") end
    expect_failure(f, _failure_conditions.contains)
end

tests["expect_contains_failing5"] = function ()
    local function f() expect_contains({"tableu"}, {"tableu"}) end
    expect_failure(f, _failure_conditions.badtype)
end
--]]

run_all_tests()