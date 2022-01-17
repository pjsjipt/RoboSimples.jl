module RoboSimples

using PyCall
using AbstractActuator

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

AbstractActuator.numaxes(dev::NRoboClient) = 3
AbstractActuator.numaxes(::Type{NRoboClient}) = 3

function NRoboClient(ip="192.168.0.140", port=9543)
    xmlrpc = pyimport("xmlrpc.client")
    server = xmlrpc.ServerProxy("http://$ip:$port")
    NRoboClient(ip, port, server)
end


AbstractActuator.move(dev::NRoboClient, mm, ax="z"; r=true) =
    dev.server["move"](mm, string(ax), r)

AbstractActuator.moveX(dev::NRoboClient, mm) = dev.server["moveX"](mm)
AbstractActuator.moveY(dev::NRoboClient, mm) = dev.server["moveY"](mm)
AbstractActuator.moveZ(dev::NRoboClient, mm) = dev.server["moveZ"](mm)

AbstractActuator.rmoveX(dev::NRoboClient, mm) = dev.server["rmoveX"](mm)
AbstractActuator.rmoveY(dev::NRoboClient, mm) = dev.server["rmoveY"](mm)
AbstractActuator.rmoveZ(dev::NRoboClient, mm) = dev.server["rmoveZ"](mm)

import Base
function AbstractActuator.position(dev::NRoboClient; pulses=false)
    x = dev.server["position"]("x", pulses)
    y = dev.server["position"]("y", pulses)
    z = dev.server["position"]("z", pulses)

    return Dict{String,Float64}("x"=>x, "y"=>y, "z"=>z)
end

AbstractActuator.position(dev::NRoboClient, ax; pulses=false) =
    dev.server["position"](string(ax), pulses)

AbstractActuator.positionX(dev::NRoboClient; pulses=false) =
    position(dev, "x"; pulses=pulses)
AbstractActuator.positionY(dev::NRoboClient; pulses=false) =
    position(dev, "y"; pulses=pulses)
AbstractActuator.positionZ(dev::NRoboClient; pulses=false) =
    position(dev, "z"; pulses=pulses)

AbstractActuator.setreference(dev::NRoboClient, ax, mm=0; pulses=false) =
    dev.server["set_reference"](string(ax), mm, pulses)

AbstractActuator.setreferenceX(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "x", mm; pulses=pulses)

AbstractActuator.setreferenceY(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "y", mm; pulses=pulses)

AbstractActuator.setreferenceZ(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "z", mm; pulses=pulses)


end


