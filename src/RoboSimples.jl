module RoboSimples

using PyCall
using DAQCore

export NRoboClient, NRoboTest
export move, moveX, moveY, moveZ, devposition, setreference
export rmove, rmoveX, rmoveY, rmoveZ
export positionX, positionY, positionZ
export setreferenceX, setreferenceY, setreferenceZ
export numaxes, axesnames, moveto


struct NRoboClient <: AbstractOutputDev
    devname::String
    ip::String
    port::Int32
    server::PyObject
    axes::Vector{String}
end

DAQCore.numaxes(dev::NRoboClient) = length(dev.axes)
DAQCore.axesnames(dev::NRoboClient) = dev.axes

function NRoboClient(devname, ip="192.168.0.140", port=9543; axes=["x", "y", "z"])
    xmlrpc = pyimport("xmlrpc.client")
    server = xmlrpc.ServerProxy("http://$ip:$port")
    NRoboClient(devname, ip, port, server, axes)
end


move(dev::NRoboClient, ax, mm; r=false) =
    dev.server["move"](mm, string(ax), r)

move(dev::NRoboClient, ax::Integer, mm; r=false) =
    move(dev, dev.axes[ax], mm; r=r)

function move(dev::NRoboClient, axes::AbstractVector,
                                x=AbstractVector; r=false)
    ndof = length(axes)

    for i in 1:ndof
        move(dev, axes[i], x[i]; r=r)
    end
    return
end

DAQCore.moveto!(dev::NRoboClient, x) =
    move(dev, dev.axes, x, r=false)


moveX(dev::NRoboClient, mm) = dev.server["moveX"](mm)
moveY(dev::NRoboClient, mm) = dev.server["moveY"](mm)
moveZ(dev::NRoboClient, mm) = dev.server["moveZ"](mm)

rmoveX(dev::NRoboClient, mm) = dev.server["rmoveX"](mm)
rmoveY(dev::NRoboClient, mm) = dev.server["rmoveY"](mm)
rmoveZ(dev::NRoboClient, mm) = dev.server["rmoveZ"](mm)

import Base
DAQCore.devposition(dev::NRoboClient; pulses=false) = 
    [dev.server["position"](ax, pulses) for ax in dev.axes]

DAQCore.devposition(dev::NRoboClient, ax; pulses=false) =
    dev.server["position"](string(ax), pulses)
DAQCore.devposition(dev::NRoboClient, ax::Integer; pulses=false) =
    devposition(dev, dev.axes[ax]; pulses=pulses)

function DAQCore.devposition(dev::NRoboClient, axes::AbstractVector;
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

positionX(dev::NRoboClient; pulses=false) =
    devposition(dev, "x"; pulses=pulses)
positionY(dev::NRoboClient; pulses=false) =
    devposition(dev, "y"; pulses=pulses)
positionZ(dev::NRoboClient; pulses=false) =
    devposition(dev, "z"; pulses=pulses)

setreference(dev::NRoboClient, ax, mm=0; pulses=false) =
    dev.server["set_reference"](string(ax), mm, pulses)
setreference(dev::NRoboClient, ax::Integer, mm=0; pulses=false) =
    setreference(dev, dev.axes[ax], mm; pulses=pulses)

function setreference(dev::NRoboClient,
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



setreferenceX(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "x", mm; pulses=pulses)

setreferenceY(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "y", mm; pulses=pulses)

setreferenceZ(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "z", mm; pulses=pulses)



        
 

    

end
