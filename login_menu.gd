extends Control


var email = ""
var password

var exists = false

func _on_create_button_down():
	if !exists:
		email = $Email.text
		password = $Password.text.sha256_text()
		exists = true

func _on_login_button_down():
	selectFromDB()
	

var database = PostgreSQLClient.new()

const DBUser = "postgres"
const DBPassword = "1234"
const DBHost = "localhost"
const DBPort = 5432
const databaseConn = "LightsOut"

func _ready():
	database.connect("connection_established",Callable(self,"selectFromDB"))
	database.connect("connection_error",Callable(self,"error"))
	database.connect("connection_closed",Callable(self,"closedConnection"))
	print("postgresql://%s:%s@%s:%d/%s" % [DBUser,DBPassword,DBHost,DBPort,databaseConn])
	database.connect_to_host("postgresql://%s:%s@%s:%d/%s" % [DBUser,DBPassword,DBHost,DBPort,databaseConn])
	
func selectFromDB():
	database.poll()
	print("running select query")
	var data = database.execute("""
	SELECT * FROM account;
	"""
	)
	print(data)
	database.close()
	
func requestEmail():
	var email = database.execute("""
	Begin;
	select * from public.account;
	""")
	print(email)

func _exit_tree():
	database.close()
