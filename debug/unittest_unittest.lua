------------------------------------------------------------
--
-- Lua Unit Testing Framework Unit Test
--
-- Verifies correct functionality for the expect functions provided by unitest.lua
--
--
-- Created by Nathan Boehm, 2019

--dofile("C:/Users/Nathan_Boehm/source/repos/lua_unittest/debug/unittest_unittest.lua")
package.path = "C:/Users/Nathan_Boehm/source/repos/lua_unittest/debug/?.lua"

--[[TODO:
          consolodate multiple 'failing' tests into single tests where it makes sense
          document tests' purposes, add more where necessary
          visually verify all test failure output in unittest_failure_unittest
          --]]

require 'unittest'
load_modules()


--expect_eq
tests["expect_eq_passing"] = function ()
   
    --basic int volume
    for i=0, 1000 do
        expect_eq(i,i)
    end

    --basic string
    expect_eq("string", "string")

    --complicated strings
    expect_eq("dsl908ajl9908097\n\n\n\n\n\t", "dsl908ajl9908097\n\n\n\n\n\t")
    expect_eq("{\":::<>()*&&^%$#@!}", "{\":::<>()*&&^%$#@!}")

    -- types strings
    expect_eq(type({1}), type({2}))

    --types bool
    expect_eq(true, true)
    expect_eq(false, false)

    --types nil
    expect_eq(nil, nil)
end

tests["expect_eq_failing"] = function ()

    --diff int
    local function f() expect_eq(5, 6) end
    expect_failure(f,  _failure_conditions.eq)

    --diff bool
    local function f1() expect_eq(true, false) end
    expect_failure(f1, _failure_conditions.eq)

    --diff stirng
    local function f2() expect_eq("string", "String") end
    expect_failure(f2, _failure_conditions.eq)

     --diff types str int
    local function f3() expect_eq("5", 5) end
    expect_failure(f3, _failure_conditions.difftypes)

    --diff types nil str
    local function f4() expect_eq(nil, "nil") end
    expect_failure(f4,  _failure_conditions.difftypes)

    --diff types bool str
    local function f5() expect_eq(true, "true") end
    expect_failure(f5,  _failure_conditions.difftypes)

    --diff types func int
    local function f6() expect_eq(func, 5) end
    expect_failure(f6, _failure_conditions.difftypes)

    --missing arg, nil implied
    local function f7() expect_eq(6) end
    expect_failure(f7)

    --volume
    local function f8(v1,v2) expect_eq(v1,v2) end
    for i=0, 1000 do
        expect_failure(f8, _failure_conditions.failure, i, i+1)
    end
end

tests["expect_eq_table_passing"] = function ()
    
    --standard
    expect_eq({1,2,3}, {1,2,3})

    --nested with keys
    expect_eq({["k1"] = "string", 2, "string", ["k2"] = 99}, {["k1"] = "string", 2, "string", ["k2"] = 99})

    --ordering
    local t1 = {1,2, k={3,4}}
    local t2 = {1,k={3,4},2}
    expect_eq(t1, t2)

    --same/equivalent
    local t3 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t4 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    expect_eq(t3,t4)
    expect_eq(t3,t3)
end

tests["expect_eq_table_failing"] = function ()
    
    --similar but different
    local function f() expect_eq({1, 2, {1, 2}, 3, {4,5}}, {1, 2, {1, 1}, 3, {4,5}}) end
    expect_failure(f)

    --size
    local function f1() expect_eq({1,2,3}, {1,2}) end
    expect_failure(f1, _failure_conditions.eq)
    local function f9() expect_eq({}, {1}) end
    expect_failure(f9, _failure_conditions.eq)
    local function f10() expect_eq({3,3,3,3,3,3,3,3,3}, {3,3,3,3,3,3,3,3,3,3}) end
    expect_failure(f10, _failure_conditions.eq)
    local function f11() expect_eq({{2},{2},{2},{2},{2},{2},{2},{2}}, {{2},{2},{2},{2},{2},{2},{2}}) end --size + nested tables
    expect_failure(f11, _failure_conditions.eq)
    local function f12() expect_eq({{3,3},{3,3}}, {{3},{3}}) end --sizeof nested tables
    expect_failure(f12, _failure_conditions.eq)--]]

    --standard diff
    local function f2() expect_eq({1,2,3}, {1,2,4}) end 
    expect_failure(f2, _failure_conditions.eq)

    --nested difference in keys
    local t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t2 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["v"] = 1}}, 2}
    local function f3() expect_eq(t1, t2) end
    expect_failure(f3, _failure_conditions.eq)

    --nested difference in values
    local t3 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t4 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 2}}, 2}
    local function f4() expect_eq(t3, t4) end
    expect_failure(f4, _failure_conditions.eq)

    --diff types table int
    local function f5() expect_eq({1,2}, 1) end
    expect_failure(f5, _failure_conditions.difftypes)

    --diff types bool table
    local function f6() expect_eq(true, {1,2}) end
    expect_failure(f6, _failure_conditions.difftypes)

    --diff types str table
    local function f7() expect_eq("string", {1,2}) end
    expect_failure(f7, _failure_conditions.difftypes)

    --diff types nil table
    local function f8() expect_eq(nil, {1,2}) end
    expect_failure(f8, _failure_conditions.difftypes)
end
--]]

--
--expect_ne
tests["expect_ne_passing"] = function ()
    
    --string diffs
    expect_ne("String", "string") --capital diff
    expect_ne("amazin", "amazin ") --whitespace diff
    expect_ne("amazin\n", "amazin") --newline diff
    expect_ne(type("5"), type(5)) --type return diff

    --type diff string vs int
    expect_ne("5", 5)

    --bool diff
    expect_ne(true, false)

    --type diff nil vs string
    expect_ne(nil, "not nil")

    --basic diff int volume
    for i=0, 100 do
        expect_ne(i,i+1)
    end
end

tests["expect_ne_failing"] = function ()

    --same string special char
    local function f() expect_ne("\t", "\t") end
    expect_failure(f)

    --same int
    local function f() expect_ne(5,5) end
    expect_failure(f)

    -- same bool t
    local function f() expect_ne(true, true) end
    expect_failure(f)

    --same bool f
    local function f() expect_ne(false, false) end
    expect_failure(f)

    --nil and nil
    local function f() expect_ne(nil, nil) end
    expect_failure(f)

    --same int volume
    local function f(v1,v2) expect_ne(v1,v2) end
    for i=0, 1000 do
        expect_failure(f, _failure_conditions.failure, i, i)
    end
end

tests["expect_ne_table_passing"] = function ()

    --nested table diff
    expect_ne({1, 2, {1, 2}, 3, {4,5}}, {1, 2, {1, 1}, 3, {4,5}})

    --diff types
    expect_ne(nil, {1,2})
    expect_ne("string", {1,2})
    expect_ne({1,2}, 1)

    --nested value diff
    local t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t2 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 2}}, 2}
    expect_ne(t1, t2)

    --nested key diff
    local t3 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t4 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["v"] = 1}}, 2}
    expect_ne(t3, t4)

    --standard diff
    expect_ne({1,2,3}, {1,2,4})
    expect_ne({8,8,1+2},{8,8,1+1})
    
    --size
    expect_ne({1,2,3}, {1,2})
    expect_ne({}, {1})
    expect_ne({3,3,3,3,3,3,3,3,3}, {3,3,3,3,3,3,3,3,3,3})
    expect_ne({{2},{2},{2},{2},{2},{2},{2},{2}}, {{2},{2},{2},{2},{2},{2},{2}}) --size + nested tables
    expect_ne({{3,3},{3,3}}, {{3},{3}}) --sizeof nested tables
end

tests["expect_ne_table_failing"] = function ()

    local function f1() expect_ne({1,2,3}, {1,2,3}) end
    expect_failure(f1) --small equivalent tables

    local function f2() expect_ne({["k1"] = "string", 2, "string", ["k2"] = 99}, {["k1"] = "string", 2, "string", ["k2"] = 99}) end
    expect_failure(f2)
    
    local t1 = {1,2, k={3,4}}
    local t2 = {1,k={3,4},2}
    local function f3() expect_ne(t1, t2) end
    expect_failure(f3) --ordering

    local t3 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local t4 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = 1}}, 2}
    local function f4() expect_ne(t3,t4) end
    expect_failure(f4) --equivalent nested with keys

    local function f5() expect_ne(t3,t3) end
    expect_failure(f5) --same nested with keys
end
--]]

--
--expect_lt
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
--close
tests["close_passing"] = function ()
    expect_close(0.9, 1, 0.2)
    expect_close(0.2, 1, 0.8)
    expect_close(-1, -2, 0.5)
    expect_close(-1, -2, -0.5)
    expect_close(0.2, 1, -0.8)
    expect_close(0.9, 1, -0.2)
    expect_close(1050, 1000, 0.06)
    expect_close(10, 9, 0.15)
    expect_close(11, 10, 0.1)
end

tests["close_failing_badtype"] = function ()
    local function f1() expect_close(1,2,"2") end
    local function f2() expect_close(1,"2",2) end
    local function f3() expect_close("1",2,2) end
    local function f4() expect_close(1,2,true) end
    local function f5() expect_close(1,2,{}) end
    local function f6() expect_close(1,2,f1) end

    expect_failure(f1)
    expect_failure(f2)
    expect_failure(f3)
    expect_failure(f4)
    expect_failure(f5)
    expect_failure(f6)
end

tests["close_failing"] = function ()
    local function f1() expect_close(0.9, 1, 0.01) end
    local function f2() expect_close(-5, -2, 1) end
    local function f3() expect_close(0.01, 0, 1000) end
    expect_failure(f1)
    expect_failure(f2)
    expect_failure(f3)
end

--[[tests["close_failing"] = function ()
    expect_close(0.9, 1, 0.01)
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
    expect_failure(f, _failure_conditions.contains)
end

tests["expect_contains_table_passing"] = function ()
    expect_contains({true,{false}}, {false})
    expect_contains({{}},{})

    local t1 = {1,2, {1,2,3}}
    local t2 = {1,2,3}
    expect_contains(t1,t2)

    local t1 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = {"super sub table", "ye", 1}}}, 2}
    local t2 =  {"super sub table", "ye", 1}
    expect_contains(t1, t2)
end

tests["expect_contains_table_failing"] = function ()
    local t1 = {1,2, {1,2,3}}
    local t2 = {1,2}
    local function f() expect_contains(t1,t2) end
    expect_failure(f, _failure_conditions.contains)

    local t3 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = {"super sub table", "ye", 1}}}, 2}
    local t4 =  {"super (not) sub table", "ye", 1}
    local function f1() expect_contains(t3, t4) end
    expect_failure(f1, _failure_conditions.contains)

    t5 = {"hello", ['needakey'] = true, {1,2,3, {"hi", ["k"] = {"super sub table", "ye", 1}}}, 2}
    t6 = {"who dis?"}
    local function f2() expect_contains(t5, t6) end
    expect_failure(f2, _failure_conditions.contains)

    t7 = {1,2,3}
    t8 = {1,2,3}
    local function f3() expect_contains(t7,t8) end
    local function f4() expect_contains(t7,t7) end
    expect_failure(f3, _failure_conditions.contains)
    expect_failure(f4, _failure_conditions.contains)
end
--]]

start()