local suite = test.declare("scoped")

function suite.buildScopedWorkspace()
    scoped.workspace("MyWorkspace", function()
        local activeWks = workspace()
        test.isequal("MyWorkspace", activeWks.name)
    end)
end

function suite.buildScopedProject()
    scoped.workspace("MyWorkspace", function()
        scoped.project("MyProject", function()
            local activePrj = project()
            test.isequal("MyProject", activePrj.name)
        end)
    end)
end

function suite.buildScopedFilter()
    scoped.workspace("MyWorkspace", function()
        configurations { "Debug", "Release" }
        scoped.project("MyProject", function()
            scoped.filter({ "Debug" }, function()
                defines { "DEBUG" }
            end)
        end)
    end)

    local wks = premake.global.getWorkspace("MyWorkspace")
    local prj = test.getProject(wks, 1)
    local cfg = test.getConfig(prj, "Debug")
    
    test.isequal({ "DEBUG" }, cfg.defines)
end

function suite.buildScopedGroup()
    scoped.workspace("MyWorkspace", function()
        scoped.group("MyGroup", function()
            scoped.project("MyProject", function()

            end)
        end)
    end)

    local wks = premake.global.getWorkspace("MyWorkspace")
    local prj = test.getProject(wks, 1)

    test.isequal("MyProject", prj.name)
    test.isequal("MyGroup", prj.group)
end

function suite.buildNestedScopedGroupMulti()
    scoped.workspace("MyWorkspace", function()
        scoped.group("MyGroup", function()
            scoped.group("MySubGroup", function()
                scoped.project("MyProject", function()
                    
                end)
            end)

            scoped.project("MyOtherProject", function()
                
            end)
        end)
    end)

    local wks = premake.global.getWorkspace("MyWorkspace")
    local prj = test.getProject(wks, 1)
    local otherPrj = test.getProject(wks, 2)

    test.isequal("MyProject", prj.name)
    test.isequal("MyGroup/MySubGroup", prj.group)

    test.isequal("MyOtherProject", otherPrj.name)
    test.isequal("MyGroup", otherPrj.group)
end

function suite.buildNestedScopedGroupMulti2()
    scoped.workspace("MyWorkspace", function()
        scoped.group("MyGroup", function()
            scoped.project("MyOtherProject", function()
                
            end)

            scoped.group("MySubGroup", function()
                scoped.project("MyProject", function()
                    
                end)
            end)
        end)
    end)

    local wks = premake.global.getWorkspace("MyWorkspace")
    local prj = test.getProject(wks, 2)
    local otherPrj = test.getProject(wks, 1)

    test.isequal("MyProject", prj.name)
    test.isequal("MyGroup/MySubGroup", prj.group)

    test.isequal("MyOtherProject", otherPrj.name)
    test.isequal("MyGroup", otherPrj.group)
end

function suite.buildNestedScopedGroup()
    scoped.workspace("MyWorkspace", function()
        scoped.group("MyGroup", function()
            scoped.group("MySubGroup", function()
                scoped.project("MyProject", function()
                    
                end)
            end)
        end)
    end)

    local wks = premake.global.getWorkspace("MyWorkspace")
    local prj = test.getProject(wks, 1)

    test.isequal("MyProject", prj.name)
    test.isequal("MyGroup/MySubGroup", prj.group)
end

function suite.buildUsage()
    scoped.workspace("MyWorkspace", function()
        scoped.project("MyProject", function()
            scoped.usage("MyUsage", function()
                local activeUsg = usage()
                test.isequal("MyUsage", activeUsg.name)
            end)
        end)
    end)
end
