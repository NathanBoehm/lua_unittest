# lua_unittest
A simple, googletest inspired unit-testing framework for lua modules, designed to be run from a terminal and provide detailed feedback on test failures.

# Usage
To begin using, put 
`require 'unittest'`
followed by
`load_modules('<name of module to test here>', ...)`

in your unittesting file. Unit tests are created by adding functions to the 'tests' table in the unittest.lua module. Inside each of these functions you can make use of the various expect/assert functions provided. Run the file by calling dofile("path to your file") in the terminal.
### note 
see 'unittest_unittest.lua' under debug for a more extensive example.

## Example
```lua
require 'unittest'
load_modules('my_module.lua')

tests.my_test = function()
	expect_eq(return_one(), 1)
end

function my_test_two()
	assert_lt(return_one(), 2)
end
add_test("second test", my_test_two())
```

# Testing Functions
There are two versions of every testing function and expect\_<> and an assert\_<>. An assert will immeadiately end the test and log the result on a failure, an expect will log the result but continue with the test.


| Name | Parameters | Description |
| ------------- | ------------- | ------------- |
| expect_eq(lhs, rhs) | lhs: any-type, rhs: any-type; type(lhs) == type(rhs) | Tests the left hand argument for equality with the right hand argument. |
| expect_ne(lhs, rhs) | lhs: any type, rhs: any type | Tests the left hand argument for inequality with the right hand argument. |
| expect_lt(lhs, rhs) | lhs: number, rhs: number | Tests that the left hand argument is less than the right hand argument. |
| expect_lte(lhs, rhs) | lhs: number, rhs: number | Tests that the left hand argument is less than or equal to the right hand argument. |
| expect_gt(lhs, rhs) | lhs: number, rhs: number | Tests that the left hand argument is greater than the right hand argument. |
| expect_gte(lhs, rhs) | lhs: number, rhs: number | Tests that the left hand argument is less than or equal to the right hand argument. |
| expect_inrange(val, lower,upper, strict) | val: number, lower: number, upper: number, strict: boolean | Tests that 'val' is between 'lower' and 'upper', if 'strict' is true, it will fail on values equal to 'lower' or 'upper'. |
| expect_not_inrange(val, lower,upper, strict) | val: number, lower: number, upper: number, strict: boolean | Tests that 'val' is not between 'lower' and 'upper', if 'strict' is true, it will succeed on values equal to 'lower' or 'upper'. |
| expect_contains(table, val) | table: table, val: any-type | Tests that 'table' contains an instance of val. |
| expect_doesnt_contain(table, val) | table: table, val: any-type | Tests that 'table' does not contains an instance of val. |
| expect_type(value, type) | value: any-type, type: type-string | Tests that 'value' is of type 'type'.|
| expect_not_type(value, type) | value: any-type, type: type-string | Tests that 'value' is not of type 'type'. |
| expect_error(function, ...) | function: function, ... : variable number of arguments to 'function' | Tests that if function were run with '...' arguments, it would produce an error. |
| expect_noerror(function, ...) | function: function, ... : variable number of arguments to 'function' | Tests that if function were run with '...' arguments, it would not produce an error. |
| expect_close(value, target, magnitudeDif) | value: number, target: number, magnitudeDif: number | Tests that value is within ± (target * magnitudeDif) of 'target'. |
| expect_not_close(value, target, magnitudeDif) | value: number, target: number, magnitudeDif: number | Tests that value is not within ± (target * magnitudeDif) of 'target'. |
| expect_true(expression) | expression: boolean | Tests that 'expression' evaluates to true. |
| expect_false(expression) | expression: boolean | Tests that 'expression' evaluates to false. |

### note
in the case of tables, equality means both tables contain the same key-value pairs.

## misc
`add_test(name, test)` where 'name' is a string and 'test' is a function is also provided as an optional way to add a test
