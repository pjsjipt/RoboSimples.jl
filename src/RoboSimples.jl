module RoboSimples

using PyCall
using AbstractMover

export NRoboClient
export move, moveX, moveY, moveZ, position, setreference
export rmove, rmoveX, rmoveY, rmoveZ
export positionX, positionY, positionZ
export setreferenceX, setreferenceY, setreferenceZ
export numaxes 


struct NRoboClient <: AbstractMoverDev
    ip::String
    port::Int32
    server::PyObject
end

AbstractMover.numaxes(dev::NRoboClient) = 3
AbstractMover.numaxes(::Type{NRoboClient}) = 3

function NRoboClient(ip="192.168.0.140", port=9543)
    xmlrpc = pyimport("xmlrpc.client")
    server = xmlrpc.ServerProxy("http://$ip:$port")
    NRoboClient(ip, port, server)
end


AbstractMover.move(dev::NRoboClient, mm, ax="z"; r=true) =
    dev.server["move"](mm, string(ax), r)

AbstractMover.moveX(dev::NRoboClient, mm) = dev.server["moveX"](mm)
AbstractMover.moveY(dev::NRoboClient, mm) = dev.server["moveY"](mm)
AbstractMover.moveZ(dev::NRoboClient, mm) = dev.server["moveZ"](mm)

AbstractMover.rmoveX(dev::NRoboClient, mm) = dev.server["rmoveX"](mm)
AbstractMover.rmoveY(dev::NRoboClient, mm) = dev.server["rmoveY"](mm)
AbstractMover.rmoveZ(dev::NRoboClient, mm) = dev.server["rmoveZ"](mm)

import Base
function AbstractMover.position(dev::NRoboClient; pulses=false)
    x = dev.server["position"]("x", pulses)
    y = dev.server["position"]("y", pulses)
    z = dev.server["position"]("z", pulses)

    return Dict{String,Float64}("x"=>x, "y"=>y, "z"=>z)
end

AbstractMover.position(dev::NRoboClient, ax; pulses=false) =
    dev.server["position"](string(ax), pulses)

AbstractMover.positionX(dev::NRoboClient; pulses=false) =
    position(dev, "x"; pulses=pulses)
AbstractMover.positionY(dev::NRoboClient; pulses=false) =
    position(dev, "y"; pulses=pulses)
AbstractMover.positionZ(dev::NRoboClient; pulses=false) =
    position(dev, "z"; pulses=pulses)

AbstractMover.setreference(dev::NRoboClient, ax, mm=0; pulses=false) =
    dev.server["set_reference"](string(ax), mm, pulses)

AbstractMover.setreferenceX(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "x", mm; pulses=pulses)

AbstractMover.setreferenceY(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "y", mm; pulses=pulses)

AbstractMover.setreferenceZ(dev::NRoboClient, mm=0 ; pulses=false) =
    setreference(dev, "z", mm; pulses=pulses)


end


