extends RefCounted
class_name PingData

var frame : int
# Frame fraction spans from 0:1 and shows how far into the physics frame we are
var frame_fraction : float
var avg_latency_rounded_up : int
var acked_frame_latency : float
