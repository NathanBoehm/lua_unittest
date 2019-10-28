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
local function f()
    expect_eq(5, "5")
end

local function f2()
    expect_eq(5, 6)
end