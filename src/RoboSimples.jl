module RoboSimples

using PyCall
using AbstractActuators

export NRoboClient
export move, moveX, moveY, moveZ, position, setreference
export rmove, rmoveX, rmoveY, rmoveZ
export positionX, positionY, positionZ
export setreferenceX, setreferenceY, setreferenceZ
export numaxes 


struct NRoboClient <: AbstractCartesianRobot
    ip::String
    port::Int32
    server::PyObject
end

AbstractActuators.numaxes(dev::NRoboClient) = 3
AbstractActuators.numaxes(::Type{NRoboClient}) = 3

function NRoboClient(ip="192.168.0.140", port=9543)
    xmlrpc = pyimport("xmlrpc.client")
    server = xmlrpc.ServerProxy("http://$ip:$port")
    NRoboClient(ip, port, server)
end


AbstractActuators.move(dev::NRoboClient, mm, ax="z"; r=true) =
    dev.server["move"](mm, string(ax), r)

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

AbstractActuators.positionX(dev::NRoboClient; pulses=false) =
    position(dev, "x"; pulses=pulses)
AbstractActuators.positionY(dev::NRoboClient; pulses=false) =
    position(dev, "y"; pulses=pulses)
AbstractActuators.positionZ(dev::NRoboClient; pulses=false) =
    position(dev, "z"; pulses=pulses)

AbstractActuators.setreference(dev::NRoboClient, ax, mm=0; pulses=false) =
    dev.server["set_reference"](string(ax), mm, pulses)

AbstractActuators.setreferenceX(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "x", mm; pulses=pulses)

AbstractActuators.setreferenceY(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "y", mm; pulses=pulses)

AbstractActuators.setreferenceZ(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "z", mm; pulses=pulses)


end


