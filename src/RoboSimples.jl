module RoboSimples

using PyCall
using DAQCore

export NRoboClient, NRoboTest
export move, moveX, moveY, moveZ, devposition, setreference
export rmove, rmoveX, rmoveY, rmoveZ, moveto!
export positionX, positionY, positionZ
export setreferenceX, setreferenceY, setreferenceZ
export numaxes, axesnames, moveto
export devname, devtype

include("xmlrpcclient.jl")
include("testrobo.jl")

    

end
