using Dates

struct NRoboTest <: AbstractOutputDev
    devname::String
    logfile::String
    axes::Vector{String}
    avals::Vector{Float64}
    amap::Dict{String,Int}
end

DAQCore.devtype(dev::NRoboTest) = "NRoboTest"
DAQCore.numaxes(dev::NRoboTest) = length(dev.axes)
DAQCore.axesnames(dev::NRoboTest) = dev.axes

function NRoboTest(devname, logfile=tempname(); axes=["x", "y", "z"])
    open(logfile, "w") do f
        println(f, "Robot started at $(now()) with axes:")
        for a in axes
            println(f, a)
        end
    end
    amap = Dict{String,Int}()
    for (i,ax) in enumerate(axes)
        amap[ax] = i
    end
    avals = zeros(length(axes))
    NRoboTest(devname, logfile, axes, avals, amap)
end


msglog(dev, msg) = open(dev.logfile, "a") do f
    println(f, "$msg  --> $(now())")
end


function move(dev::NRoboTest, ax::Integer, mm; r=false)
    if r
        dev.avals[ax] += mm
    else
        dev.avals[ax]  = mm
    end
    msglog(dev, "move ax=$(dev.axes[ax]) mm=$mm r=$r")
end

move(dev::NRoboTest, ax::AbstractString, mm; r=false) = 
    move(dev, dev.amap[ax], mm, r=r)


function move(dev::NRoboTest, axes::AbstractVector,
              x=AbstractVector; r=false)
    ndof = length(axes)
    
    for i in 1:ndof
        move(dev, axes[i], x[i]; r=r)
    end
    return
end

DAQCore.moveto!(dev::NRoboTest, x) =
    move(dev, dev.axes, x, r=false)


moveX(dev::NRoboTest, mm) = move(dev, "x", mm, r=false)
moveY(dev::NRoboTest, mm) = move(dev, "y", mm, r=false)
moveZ(dev::NRoboTest, mm) = move(dev, "z", mm, r=false)

rmoveX(dev::NRoboTest, mm) = move(dev, "x", mm, r=true)
rmoveY(dev::NRoboTest, mm) = move(dev, "y", mm, r=true)
rmoveZ(dev::NRoboTest, mm) = move(dev, "z", mm, r=true)

import Base
DAQCore.devposition(dev::NRoboTest; pulses=false) = dev.avals

DAQCore.devposition(dev::NRoboTest, ax; pulses=false) = dev.avals[dev.amap[string(ax)]]
DAQCore.devposition(dev::NRoboTest, ax::Integer; pulses=false) = dev.avals[ax]

function DAQCore.devposition(dev::NRoboTest, axes::AbstractVector;
                                       pulses=false) 
    ndof = length(axes)

    if ndof == 1
        return [devposition(dev, dev.axes[axes[1]]; pulses=pulse)]
    elseif ndof == 2
        return [devposition(dev, dev.axes[axes[1]]; pulses=pulse),
                devposition(dev, dev.axes[axes[2]]; pulses=pulse)]
    else
        return [devposition(dev, dev.axes[axes[1]]; pulses=pulse),
                devposition(dev, dev.axes[axes[2]]; pulses=pulse),
                devposition(dev, dev.axes[axes[3]]; pulses=pulse)]
    end
end

positionX(dev::NRoboTest; pulses=false) = dev.avals[dev.amap["x"]]
positionY(dev::NRoboTest; pulses=false) = dev.avals[dev.amap["y"]]
positionZ(dev::NRoboTest; pulses=false) = dev.avals[dev.amap["z"]]

function setreference(dev::NRoboTest, ax::Integer, mm=0; pulses=false) 
    dev.avals[ax] = mm
    msglog(dev, "setreference ax=$(dev.axes[ax]) mm=$mm")
end

setreference(dev::NRoboTest, ax, mm=0; pulses=false) =
    setreference(dev, dev.amap[string(ax)], mm; pulses=pulses)

function setreference(dev::NRoboTest,
                      ax::AbstractVector,
                      mm=0; pulses=false)
    nax = length(ax)

    if length(mm) == 1
        mm = fill(mm[1], nax)
    end

    for i in 1:nax
        setreference(dev, ax[i], mm[i]; pulses=pulses)
    end
end



setreferenceX(dev::NRoboTest, mm=0 ; pulses=false) =
    setreference(dev, "x", mm; pulses=pulses)

setreferenceY(dev::NRoboTest, mm=0 ; pulses=false) =
    setreference(dev, "y", mm; pulses=pulses)

setreferenceZ(dev::NRoboTest, mm=0 ; pulses=false) =
    setreference(dev, "z", mm; pulses=pulses)



        
 

    

