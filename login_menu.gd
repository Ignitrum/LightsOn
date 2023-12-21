extends Control


var email
var password

var exists = false

func _on_create_button_down():
	$Info.text = ""
	if (!$Email.text == ""):
		email = $Email.text
	else:
		$Info.text = "Can't create account without email address or password"
	if(!$Password.text == ""):
		password = $Password.text.sha256_text()
	else:
		$Info.text = "Can't create account without email address or password"
	makeCreateRequest("email","account","email LIKE '%s'"%[email])

func _on_login_button_down():
	$Info.text = ""
	email = $Email.text
	password = $Password.text.sha256_text()
	emailLoginRequest("email","account","email LIKE '%s'"%[email])
	
func _on_test_pressed():
	$Info.text = ""
	password = $Password.text.sha256_text()
	email = $Email.text
	database.execute("SELECT 'passwordCheck',EXISTS(SELECT 1 FROM ACCOUNT WHERE email = '%s' AND password = '%s')"% [email,password])

func emailLoginRequest(what: String, from:String, where:String)-> void:
	#print("SELECT %s FROM %s WHERE %s;" % [what,from,where])
	database.execute("SELECT 'emailRequest',EXISTS(SELECT %s FROM %s WHERE %s);" % [what,from,where])

func makeCreateRequest(what: String, from:String, where:String)-> void:
	database.execute("SELECT 'createRequest',EXISTS(SELECT %s FROM %s WHERE %s);" % [what,from,where])
	
func _email_valid():
	database.execute("SELECT 'passwordCheck',EXISTS(SELECT 1 FROM account WHERE email = '%s' AND password = '%s')"% [email,password])
	
func _password_valid():
	get_tree().change_scene_to_file("res://Logged_In.tscn")
	
func _invalid():
	$Info.text = "Email or Password wrong"

func _create_account():
	password = $Password.text.sha256_text()
	database.execute("SELECT CONCAT('creatingAccount');")
	

func _email_taken():
	$Info.text = "Email already taken"
	
const USER := "postgres"
const PASSWORD := "1234"
const HOST := "localhost"
const PORT := 5432 # Default postgres port
const DATABASE := "LightsOut" # Database name

var database: PostgreSQLClient = PostgreSQLClient.new()

func _init():
	var _error = database.connect("data_received", Callable(self, "_data_received"))
	#Connection to the database
	_error = database.connect_to_host("postgresql://%s:%s@%s:%d/%s" % [USER, PASSWORD, HOST, PORT, DATABASE])


func _physics_process(_delta: float) -> void:
	database.poll()


func _connection_established() -> void:
	print(database.parameter_status)
	print("Database connected")


func _data_received(error_object: Dictionary, transaction_status: PostgreSQLClient.TransactionStatus, datas: Array) -> void:
	#match transaction_status:
	#	database.TransactionStatus.NOT_IN_A_TRANSACTION_BLOCK:
	#		print("NOT_IN_A_TRANSACTION_BLOCK")
	#	database.TransactionStatus.IN_A_TRANSACTION_BLOCK:
	#		print("IN_A_TRANSACTION_BLOCK")
	#	database.TransactionStatus.IN_A_FAILED_TRANSACTION_BLOCK:
	#		print("IN_A_FAILED_TRANSACTION_BLOCK")
	
	for data in datas:
		#print(data.data_row)
		if(!data.data_row == []):
			var result = data.data_row[0]
			match result[0]:
				"emailRequest":
					if(result[1]):
						_email_valid()
					else:
						_invalid()
				"passwordCheck":
					if(result[1]):
						_password_valid()
					else:
						_invalid()
				"createRequest":
					if(!result[1]):
						_create_account()
					else:
						_email_taken()
						
		
			
	
	if not error_object.is_empty():
		prints("Error:", error_object)
	
	#database.close()


func _authentication_error(error_object: Dictionary) -> void:
	prints("Error connection to database:", error_object["message"])


func _connection_close(clean_closure := true) -> void:
	prints("DB CLOSE,", "Clean closure:", clean_closure)


func _exit_tree() -> void:
	database.close()


func _on_check_button_toggled(button_pressed):
	$Password.secret = !button_pressed

@onready var emailRegex = RegEx.new()
@onready var passwordRegex = RegEx.new()

func _on_ready():
	emailRegex.compile("[^a-zA-Z0-9@.]")
	passwordRegex.compile("[^a-zA-Z0-9!?.:-_]")

func _on_email_text_changed(new_text):
	var cached_caret = $Email.caret_column
	if emailRegex.search(new_text):
		$Email.text = emailRegex.sub($Email.text, "", true)
		$Email.caret_column = cached_caret
