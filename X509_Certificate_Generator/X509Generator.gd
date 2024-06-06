extends Node

# NOTE - certificates are currently self signed. On release these certificates
# MUST be verified by a third party

var X509_cert_filename = "X509_Certificate.crt" # use the name of the application.crt
var X509_key_filename = "x509_Key.key" # use the name of the application.key
onready var X509_cert_path = "user://Certificate/" + X509_cert_filename
onready var X509_key_path = "user://Certificate/" + X509_key_filename


# CN = myserver, O = myorganisation, C = 2 lettered ISO-3166 country code

var CN = "RogueRoyale"
var O = "LeftCircle"
var C = "US"
# Certifacates should be only a year in length (not before and not after)
var not_before = "20210519000000"
var not_after = "20220518235900"

func _ready():
	var directory = Directory.new()
	if not directory.dir_exists("user://Certificate"):
		directory.make_dir("user://Certificate")
	create_X509_cert()
	print("Certicate Created")
	
func create_X509_cert():
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	X509_cert.save(X509_cert_path)
	crypto_key.save(X509_key_path)
