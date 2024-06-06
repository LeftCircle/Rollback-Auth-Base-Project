extends RefCounted
class_name CriticallyDampedSpring
# from here https://www.ryanjuckett.com/damped-springs/

var vel = Vector2.ZERO
var pos
var equilibriumPos
var length_to_eq = 0.0

var starting_ang_freq = 25.0

var angular_freq = 25.0
var dampingRatio = 0.5
var m_posPosCoef
var m_posVelCoef
var m_velPosCoef
var m_velVelCoef

func set_start_and_end(starting_position, new_equilibriumPos):
	pos = starting_position
	equilibriumPos = new_equilibriumPos
	angular_freq = starting_ang_freq
	length_to_eq = starting_position.distance_to(new_equilibriumPos)
	#vel = Vector2.ZERO

func zero_velocity():
	vel = Vector2.ZERO

func set_new_end(new_end) -> void:
	equilibriumPos = new_end
	#angular_freq = clamp(angular_freq + 0.5, 25, 75)
	#vel = Vector2.ZERO

func advance(time : float) -> void:
	critically_damped(time)
	var old_pos = pos - equilibriumPos
	pos = old_pos * m_posPosCoef + vel * m_posVelCoef + equilibriumPos
	vel = old_pos * m_velPosCoef + vel * m_velVelCoef
	length_to_eq = pos.distance_to(equilibriumPos)

func critically_damped(deltaTime : float) -> void:
	var expTerm = exp(-angular_freq * deltaTime)
	var timeExp = deltaTime * expTerm
	var timeExpFreq = timeExp * angular_freq

	m_posPosCoef = timeExpFreq + expTerm
	m_posVelCoef = timeExp
	m_velPosCoef = -angular_freq * timeExpFreq;
	m_velVelCoef = -timeExpFreq + expTerm;


func under_damped_coef(deltaTime):
	var omegaZeta = angular_freq * dampingRatio;
	var alpha = angular_freq * sqrt(1.0 - dampingRatio*dampingRatio);

	var expTerm = exp(-omegaZeta * deltaTime);
	var cosTerm = cos(alpha * deltaTime);
	var sinTerm = sin(alpha * deltaTime);

	var invAlpha = 1.0 / alpha;

	var expSin = expTerm*sinTerm;
	var expCos = expTerm*cosTerm;
	var expOmegaZetaSin_Over_Alpha = expTerm*omegaZeta*sinTerm*invAlpha;

	m_posPosCoef = expCos + expOmegaZetaSin_Over_Alpha;
	m_posVelCoef = expSin*invAlpha;

	m_velPosCoef = -expSin*alpha - omegaZeta*expOmegaZetaSin_Over_Alpha;
	m_velVelCoef =  expCos - expOmegaZetaSin_Over_Alpha;
