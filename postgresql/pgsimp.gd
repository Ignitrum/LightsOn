class_name DatabaseIntegration
var database = PostgreSQLClient.new()

const user = "postgres"
const password = "1234"
const host = "localhost"
const port = 5432
const databaseConn = "LightsOut"

func _ready():
	database.connect("connection_established",Callable(self,"selectFromDB"))
	database.connect("connection_error",Callable(self,"error"))
	database.connect("connection_closed",Callable(self,"closedConnection"))
	
	database.connect_to_host("postgresql://"+user+":"+password+"@"+host+":"+str(port)+"/"+databaseConn)
	
func selectFromDB():
	print("running select query")
	var data = database.execute("""
	BEGIN;
	SELECT * FROM 
	"""
	)
	
func requestEmail():
	var email = database.execute("""
	Begin;
	select * from account;
	""")
	print(email)
