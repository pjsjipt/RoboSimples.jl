module RoboSimples

using PyCall
using AbstractActuators

export NRoboClient, NRoboTest
export move, moveX, moveY, moveZ, devposition, setreference
export rmove, rmoveX, rmoveY, rmoveZ
export positionX, positionY, positionZ
export setreferenceX, setreferenceY, setreferenceZ
export numaxes, axesnames


struct NRoboClient <: AbstractCartesianRobot
    devname::String
    ip::String
    port::Int32
    server::PyObject
    axes::Vector{String}
end

AbstractActuators.numaxes(dev::NRoboClient) = 3
AbstractActuators.axesnames(dev::NRoboClient) = dev.axes

function NRoboClient(devname, ip="192.168.0.140", port=9543; axes=["x", "y", "z"])
    xmlrpc = pyimport("xmlrpc.client")
    server = xmlrpc.ServerProxy("http://$ip:$port")
    NRoboClient(devname, ip, port, server, axes)
end


AbstractActuators.move(dev::NRoboClient, ax, mm; r=false) =
    dev.server["move"](mm, string(ax), r)

AbstractActuators.move(dev::NRoboClient, ax::Integer, mm; r=false) =
    move(dev, dev.axes[ax], mm; r=r)

function AbstractActuators.move(dev::NRoboClient, axes::AbstractVector,
                                x=AbstractVector; r=false)
    ndof = length(axes)

    for i in 1:ndof
        move(dev, x[i], axes[i]; r=r)
    end
    return
end

AbstractActuators.moveto(dev::NRoboClient, x::AbstractVector) =
    move(dev, dev.axes, x)


AbstractActuators.moveX(dev::NRoboClient, mm) = dev.server["moveX"](mm)
AbstractActuators.moveY(dev::NRoboClient, mm) = dev.server["moveY"](mm)
AbstractActuators.moveZ(dev::NRoboClient, mm) = dev.server["moveZ"](mm)

AbstractActuators.rmoveX(dev::NRoboClient, mm) = dev.server["rmoveX"](mm)
AbstractActuators.rmoveY(dev::NRoboClient, mm) = dev.server["rmoveY"](mm)
AbstractActuators.rmoveZ(dev::NRoboClient, mm) = dev.server["rmoveZ"](mm)

import Base
function AbstractActuators.devposition(dev::NRoboClient; pulses=false)
    x = dev.server["position"]("x", pulses)
    y = dev.server["position"]("y", pulses)
    z = dev.server["position"]("z", pulses)

    return Dict{String,Float64}("x"=>x, "y"=>y, "z"=>z)
end

AbstractActuators.devposition(dev::NRoboClient, ax; pulses=false) =
    dev.server["position"](string(ax), pulses)
AbstractActuators.devposition(dev::NRoboClient, ax::Integer; pulses=false) =
    devposition(dev, dev.axes[ax]; pulses=pulses)

function AbstractActuators.devposition(dev::NRoboClient, axes::AbstractVector;
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

AbstractActuators.positionX(dev::NRoboClient; pulses=false) =
    devposition(dev, "x"; pulses=pulses)
AbstractActuators.positionY(dev::NRoboClient; pulses=false) =
    devposition(dev, "y"; pulses=pulses)
AbstractActuators.positionZ(dev::NRoboClient; pulses=false) =
    devposition(dev, "z"; pulses=pulses)

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



        
 

    

end
