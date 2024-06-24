class_name Log
extends Node

static var LOGPATH = "res://logs/"
static var   LOGFILE : String
static var   LOG : FileAccess
enum LEVEL {
	  DEBUG = 0, 
	  INFO = 1, 
	  WARNING = 2, 
	  ERROR = 3,
	  FATAL = 4
}
const CurrentLevel = LEVEL.DEBUG ## TODO: Change this before production :P

static func array_to_string(arr: Array) -> String:
	var s = ""
	var n = 0
	for i in arr:
		if n == 0:
			s += "["
		if n > 0:
			s += ", \"" + str(i) + "\""
		else:
			s += "\"" + str(i) + "\""
		n += 1
	s += "]"
	return s

static func addToLog(string : String):
	LOGFILE = Time.get_date_string_from_system() + ".log"
	
	## TODO: Fixa det här!
	# var dir = DirAccess.open(LOGPATH)	
	# if FileAccess.file_exists(LOGPATH + LOGFILE):
	#	var newname = LOGFILE + ".1"
	#	dir.rename(LOGPATH+LOGFILE, LOGPATH+newname)
	
	#var LOG = FileAccess.open(LOGPATH+LOGFILE,FileAccess.WRITE)
	FileAccess.open(LOGPATH+LOGFILE,FileAccess.WRITE).store_string(string + "\n")
	if CurrentLevel == 0:
		print(string)
	
static func debug(caller : Node, message : String):
	var time = str(Time.get_datetime_string_from_system())
	addToLog("[ " + time + " ] [ DEBUG   ] [ " + str(caller) + " ]: " + message)

	
static func info(caller : Node, message : String):
	var time = str(Time.get_datetime_string_from_system())
	addToLog("[ " + time + " ] [ INFO    ] [ " + str(caller) + " ]: " + message)
	
	
static func warning(caller : Node, message : String):
	var time = str(Time.get_datetime_string_from_system())
	var logString = "[ " + time + " ] [ WARNING ] [ " + str(caller) + " ]: " + message
	addToLog(logString)
	push_warning(logString)


static func error(caller : Node, message : String):
	var time = str(Time.get_datetime_string_from_system())
	var logString = "[ " + time + " ] [ ERROR   ] [ " + str(caller) + " ]: " + message
	addToLog(logString)
	push_error(logString)
	

static func fatal(caller : Node, message : String):
	var time = str(Time.get_datetime_string_from_system())
	var logString = "[ " + time + " ] [ FATAL   ] [ " + str(caller) + " ]: " + message
	addToLog(logString)
	push_error(logString)
	var tree = SceneTree.new()
	tree.quit(69)


#static func addToLog(string : String):
	#var 
	#.store_string(string)
	#if LEVEL == 0:
		#prints(string)
