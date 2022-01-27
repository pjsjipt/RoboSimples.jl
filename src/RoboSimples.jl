module RoboSimples

using PyCall
using AbstractActuators

export NRoboClient, NRoboTest
export move, moveX, moveY, moveZ, position, setreference
export rmove, rmoveX, rmoveY, rmoveZ
export positionX, positionY, positionZ
export setreferenceX, setreferenceY, setreferenceZ
export numaxes 


struct NRoboClient <: AbstractCartesianRobot
    ip::String
    port::Int32
    server::PyObject
    axes::Vector{String}
end

AbstractActuators.numaxes(dev::NRoboClient) = 3
AbstractActuators.numaxes(::Type{NRoboClient}) = 3

function NRoboClient(ip="192.168.0.140", port=9543)
    xmlrpc = pyimport("xmlrpc.client")
    server = xmlrpc.ServerProxy("http://$ip:$port")
    NRoboClient(ip, port, server, ["x", "y", "z"])
end


AbstractActuators.move(dev::NRoboClient, mm, ax; r=false) =
    dev.server["move"](mm, string(ax), r)

AbstractActuators.move(dev::NRoboClient, mm, ax::Integer; r=false) =
    move(dev, mm, dev.axes[ax]; r=r)

function AbstractActuators.move(dev::NRoboClient, x::AbstractVector,
                                axes=AbstractVector; r=false)
    ndof = length(axes)

    for i in 1:ndof
        move(dev, x[i], axes[i]; r=r)
    end
    return
end

AbstractActuators.moveX(dev::NRoboClient, mm) = dev.server["moveX"](mm)
AbstractActuators.moveY(dev::NRoboClient, mm) = dev.server["moveY"](mm)
AbstractActuators.moveZ(dev::NRoboClient, mm) = dev.server["moveZ"](mm)

AbstractActuators.rmoveX(dev::NRoboClient, mm) = dev.server["rmoveX"](mm)
AbstractActuators.rmoveY(dev::NRoboClient, mm) = dev.server["rmoveY"](mm)
AbstractActuators.rmoveZ(dev::NRoboClient, mm) = dev.server["rmoveZ"](mm)

import Base
function AbstractActuators.position(dev::NRoboClient; pulses=false)
    x = dev.server["position"]("x", pulses)
    y = dev.server["position"]("y", pulses)
    z = dev.server["position"]("z", pulses)

    return Dict{String,Float64}("x"=>x, "y"=>y, "z"=>z)
end

AbstractActuators.position(dev::NRoboClient, ax; pulses=false) =
    dev.server["position"](string(ax), pulses)
AbstractActuators.position(dev::NRoboClient, ax::Integer; pulses=false) =
    position(dev, dev.axes[ax]; pulses=pulses)

function AbstractActuators.position(dev::NRoboClient, axes::AbstractVector;
                                    pulses=false) 
    ndof = length(axes)

    if ndof == 1
        return [position(dev, dev.axes[axes[1]]; pulses=pulse)]
    elseif ndof == 2
        return [position(dev, dev.axes[axes[1]]; pulses=pulse),
                position(dev, dev.axes[axes[2]]; pulses=pulse)]
    else
        return [position(dev, dev.axes[axes[1]]; pulses=pulse),
                position(dev, dev.axes[axes[2]]; pulses=pulse),
                position(dev, dev.axes[axes[3]]; pulses=pulse)]
    end
end

AbstractActuators.positionX(dev::NRoboClient; pulses=false) =
    position(dev, "x"; pulses=pulses)
AbstractActuators.positionY(dev::NRoboClient; pulses=false) =
    position(dev, "y"; pulses=pulses)
AbstractActuators.positionZ(dev::NRoboClient; pulses=false) =
    position(dev, "z"; pulses=pulses)

AbstractActuators.setreference(dev::NRoboClient, ax, mm=0; pulses=false) =
    dev.server["set_reference"](string(ax), mm, pulses)
AbstractActuators.setreference(dev::NRoboClient, ax::Integer, mm=0; pulses=false) =
    setreference(dev, dev.axes[ax], mm; pulses=pulses)

function AbstractActuators.setreference(dev::NRoboClient,
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



AbstractActuators.setreferenceX(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "x", mm; pulses=pulses)

AbstractActuators.setreferenceY(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "y", mm; pulses=pulses)

AbstractActuators.setreferenceZ(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "z", mm; pulses=pulses)



mutable struct NRoboTest <: AbstractCartesianRobot
    n::Int
    x::Vector{Float64}
    xr::Vector{Float64}
    axes::Vector{String}
    axidx::Dict{String,Int}
    Δt::Float64
end

function NRoboTest(n=3; axes=["x", "y", "z", "w"], dt=1.0)
    axidx = Dict{String,Int}()
    axes = axes[1:n]
    for (i, ax) in enumerate(axes)
        axidx[ax] = i
    end
    
    NRoboTest(n, zeros(n), zeros(n), axes, axidx, dt)
end

AbstractActuators.numaxes(dev::NRoboTest) = dev.n

function AbstractActuators.move(dev::NRoboTest, mm, ax::Integer; r=false)
    if r
        dev.x[ax] += mm
    else
        dev.x[ax] = mm
    end
    
    println("Position: $ax -> $(dev.axes[ax]) = $(dev.x[ax])")
end

AbstractActuators.move(dev::NRoboTest, mm, ax; r=false) =
    move(dev, mm, dev.axidx[string(ax)]; r=r)
    

function AbstractActuators.move(dev::NRoboTest, x::AbstractVector,
                                axes::AbstractVector; r=false)
    ndof = length(axes)

    for i in 1:ndof
        move(dev, x[i], axes[i]; r=r)
    end
    return
end

AbstractActuators.moveX(dev::NRoboTest, mm) = move(dev, mm, dev.axidx["x"]; r=false)
AbstractActuators.moveY(dev::NRoboTest, mm) = move(dev, mm, dev.axidx["y"]; r=false)
AbstractActuators.moveZ(dev::NRoboTest, mm) = move(dev, mm, dev.axidx["z"]; r=false)

AbstractActuators.rmoveX(dev::NRoboTest, mm) = move(dev, mm, dev.axidx["x"]; r=true)
AbstractActuators.rmoveY(dev::NRoboTest, mm) = move(dev, mm, dev.axidx["y"]; r=true)
AbstractActuators.rmoveZ(dev::NRoboTest, mm) = move(dev, mm, dev.axidx["z"]; r=true)

AbstractActuators.position(dev::NRoboTest, ax) = dev.x[dev.axidx[string(ax)]]
AbstractActuators.position(dev::NRoboTest, ax::Integer) = dev.x[ax]

AbstractActuators.position(dev::NRoboTest, axes::AbstractVector) = dev.x[axes]

function AbstractActuators.position(dev::NRoboTest)
    pos = Dict{String,Float64}()

    for i in 1:numaxes(dev)
        pos[dev.axes[i]] = dev.x[i]
    end
    return pos
end

AbstractActuators.positionX(dev::NRoboTest) = position(dev, "x")
AbstractActuators.positionY(dev::NRoboTest) = position(dev, "y")
AbstractActuators.positionZ(dev::NRoboTest) = position(dev, "z")

AbstractActuators.setreference(dev::NRoboTest, ax::Integer, mm=0) = dev.x[ax] = mm
AbstractActuators.setreference(dev::NRoboTest, ax, mm=0) = dev.x[dev.axidx[string(ax)]] = mm

function AbstractActuators.setreference(dev::NRoboTest, ax::AbstractVector, mm=0)
    nax = length(ax)
    if length(mm) == 1
        mm = fill(mm[1], nax)
    end

    for i in 1:nax
        setreference(dev, ax[i], mm[i])
    end
    
end

AbstractActuators.setreferenceX(dev::NRoboTest, mm=0) = dev.x[dev.axidx["x"]] = mm
AbstractActuators.setreferenceY(dev::NRoboTest, mm=0) = dev.x[dev.axidx["y"]] = mm
AbstractActuators.setreferenceZ(dev::NRoboTest, mm=0) = dev.x[dev.axidx["z"]] = mm



        
 

    

end
