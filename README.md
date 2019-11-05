# lua_unittest
A basic unit testing frame work for Lua modules.

UNFINISHED WORK IN PROGRESS

# TODO:
- refactor to move common code into helper functions, to reduce reused code
    - need to put line_num inside of expect_<> functions
        - can leave them where there at, but adjust the debug.getinfo(x) number
- add PASS() FAIL() "macro"?
- complete not_type, doesnt_contain, not_inrange expect functions
- consolodate multiple 'failing' tests into single tests where it makes sense
- document tests' purposes, add more where necessary
- visually verify all test failure output in unittest_failure_unittest
