------------------------------------------------------------
--
-- Lua Unit Testing Framework Failures Unit Test
--
-- For visual verification of text output for unit test failures and anything else
-- That is difficult to test without visual verification.
--
--
-- Created by Nathan Boehm, 2019

--dofile("C:/Users/Nathan_Boehm/source/repos/lua_unittest/debug/unittest_failure_unittest.lua")
package.path = "C:/Users/Nathan_Boehm/source/repos/lua_unittest/debug/?.lua"

require 'unittest'
load_modules()

--
--expect_eq
tests.verify_eq = function ()
    --not_eq same types
    expect_eq(1,2)
    expect_eq("string", "Otherstring")
    expect_eq(3.14,3.15)
    expect_eq(function () return 1 end, function () return 1 end)
    expect_eq({1,2,3}, {1,2,3,4})

    --not_eq diff types
    expect_eq("string", 1)
    expect_eq(2, function () return 1 end)
    expect_eq({1,2,3}, 3.14)

    --assert
    assert_eq(1,1)
    assert_eq(0,1) --should be recorded because above assert succeeds
    expect_eq(0,1) --should not be recorded because above assert will cause the test to end
end

tests.verify_ne = function ()
    --eq
    expect_ne(1,1)
    expect_ne("string", "string")
    expect_ne({1,2,3}, {1,2,3})

    --assert
    assert_ne(1,2)
    assert_ne(1,1)
    expect_ne(1,1)
end

tests.verify_lt = function ()
    expect_lt(2,1)
    
    --types
    expect_lt("a", "b")
    expect_lt(1, "b")
    expect_lt(function () return 1 end, function () return 1 end)
    expect_lt({1,3}, function () return 1 end)

    --assert
    assert_lt(1,2)
    assert_lt(2,1)
    expect_lt(2,1)
end

tests.verify_lte = function ()
    expect_lte(2,1)

    --types
    expect_lte("a", "b")
    expect_lte(1, "b")
    expect_lte(function () return 1 end, function () return 1 end)
    expect_lte({1,3}, function () return 1 end)

    --assert
    assert_lte(2,2)
    assert_lte(2,1)
    expect_lte(2,1)
end

tests.verify_gt = function ()
    expect_gt(1,2)

    --types
    expect_gt("a", "b")
    expect_gt(1, "b")
    expect_gt(function () return 1 end, function () return 1 end)
    expect_gt({1,3}, function () return 1 end)

    --assert
    assert_gt(2,1)
    assert_gt(1,2)
    expect_gt(1,2)
end

tests.verify_gte = function ()
    expect_gte(1,2)

    --types
    expect_gt("a", "b")
    expect_gt(1, "b")
    expect_gt(function () return 1 end, function () return 1 end)
    expect_gt({1,3}, function () return 1 end)

    --assert
    assert_gte(2,2)
    assert_gte(1,2)
    expect_gte(1,2)
end

tests.verify_inrange = function ()
    expect_inrange(1, -4, 0)

    --bad range
    expect_inrange(1, 3,2)
    expect_inrange(1, 0,-1)

    --types
    expect_inrange(1, 2,"3")
    expect_inrange(function () return 1 end, 2,3)
    expect_inrange(1, {1,2}, 4)

    --strict
    expect_inrange(2, 1,2, true)

    --assert
    assert_inrange(1, 0,3)
    assert_inrange(1, 0,1, true)
    expect_inrange(1, 0,1, true)
end

tests.verifty_not_inrange = function ()
    expect_not_inrange(1, 1,2)

    --bad range
    expect_not_inrange(1, 3,2)
    expect_not_inrange(1, 0,-1)

    --types
    expect_not_inrange(1, 2,"3")
    expect_not_inrange(function () return 1 end, 2,3)
    expect_not_inrange(1, {1,2}, 4)

    --strict
    expect_not_inrange(2, 1,2)

    --assert
    assert_not_inrange(1, 2,3)
    assert_not_inrange(1, 0,1)
    expect_not_inrange(1, 0,1)
end

tests.verify_contains = function ()
    expect_contains({1,2,3}, 0)
    expect_contains({1,2,3, {1}}, {2})

    --types
    expect_contains(1, {1})
    expect_contains("a", 1)
    expect_contains(function () return 1 end, 3.14)

    --assert
    assert_contains({1,2,3}, 1)
    assert_contains({1,2,3}, 0)
    expect_contains({1,2,3}, 0)
end

tests.verify_doesnt_contain = function ()
    expect_doesnt_contain({1,2,3}, 3)
    expect_doesnt_contain({1, {1,2,3}, 3}, {1,2,3})

    --types
    expect_doesnt_contain(1, {1})
    expect_doesnt_contain("a", 1)
    expect_doesnt_contain(function () return 1 end, 3.14)

    --assert
    assert_doesnt_contain({1,2,3}, 4)
    assert_doesnt_contain({1,2,3,{1}}, {1})
    expect_doesnt_contain({1,2,3,{1}}, {1})
end

tests.verify_type = function ()
    expect_type(1, "string")
    expect_type("a", "number")
    expect_type(function () return 1 end, "table")
    expect_type({1,2}, "function")

    --types
    expect_type(1, 1)
    expect_type({1,2}, function () return 1 end)
    expect_type("a", {1,2})

    --assert
    assert_type(1, "number")
    assert_type(1, "string")
    expect_type(1, "string")
end

tests.verify_not_type = function ()
    expect_not_type(1, "number")
    expect_not_type("a", "string")
    expect_not_type({1,2,3}, "table")

    --types
    expect_not_type(1, 1)
    expect_not_type({1,2}, function () return 1 end)
    expect_not_type("a", {1,2})

    --assert
    assert_not_type(1, "string")
    assert_not_type(1, "number")
    expect_not_type(1, "number")
end

local function err_func()
    a.b.c = 10
end
local function noerr_func()
    return 1
end

tests.verify_error = function ()
    expect_error(noerr_func)

    --type
    expect_error(1)
    expect_error("a")
    expect_error({1,2,3})

    --assert
    assert_error(err_func)
    assert_error(noerr_func)
    expect_error(noerr_func)
end

tests.verify_noerror = function ()
    expect_noerror(err_func)

    --type
    expect_noerror(1)
    expect_noerror("a")
    expect_noerror({1,2,3})

    --assert
    assert_noerror(noerr_func)
    assert_noerror(err_func)
    expect_noerror(err_func)
end

tests.verify_close = function ()
    expect_close(1, 1.3, 0.1)
    expect_close(0,1,0.5)

    --type
    expect_close("1", 1, 1)
    expect_close(1, {1,2}, 1)
    expect_close(1,1,function () return 1 end)

    --assert
    assert_close(1, 2, 1)
    assert_close(1, 0.5, 0.1)
    expect_close(1, 0.5, 0.1)
end

tests.verify_not_close = function ()
    expect_not_close(1, 1.1, 0.2)

    --type
    expect_not_close("1", 1, 1)
    expect_not_close(1, {1,2}, 1)
    expect_not_close(1,1,function () return 1 end)

    --assert
    assert_not_close(1, 3, 0.3)
    assert_not_close(1, 1.1, 0.2)
    expect_not_close(1, 1.1, 0.2)
end

tests.verify_true = function ()
    expect_true(false)

    --type
    expect_true(1)
    expect_true("a")
    expect_true({1,2})
    expect_true(function () return 1 end)

    --assert
    assert_true(true)
    assert_true(false)
    expect_true(false)
end

tests.verify_false = function ()
    expect_false(true)

    --type
    expect_false(1)
    expect_false("a")
    expect_false({1,2})
    expect_false(function () return 1 end)

    --assert
    assert_false(false)
    assert_false(true)
    expect_false(true)
end

tests.unexpected_failure = function ()
    expect_true(error("lmao no"))
end


start()