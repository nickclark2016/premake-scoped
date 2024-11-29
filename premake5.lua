newaction {
    trigger = "test",
    description = "Run the tests",
    execute = function()
        test = require "self-test"
        premake.action.call("self-test")
    end
}
