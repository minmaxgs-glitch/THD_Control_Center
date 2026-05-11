import mysql.connector
 
# connection

con = mysql.connector.connect(

    host="127.0.0.1",

    user="root",

    password="root",

    database="thd_hr_control_center"

)
 
print("Connected Successfully")
 
# cursor

cur = con.cursor()
cur.execute("SELECT * FROM interviews")
 
data = cur.fetchall()
 
for row in data:

    print(row)
 


 