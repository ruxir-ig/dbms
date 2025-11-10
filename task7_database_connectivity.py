import mysql.connector

# Connect
conn = mysql.connector.connect(
host='localhost',
user='root',
password='password',
database='testdb'
)
cursor = conn.cursor()

# Create & Insert
cursor.execute("CREATE TABLE IF NOT EXISTS emp (id INT, name VARCHAR(50),
salary INT)")
cursor.execute("INSERT INTO emp VALUES (101, 'John', 50000)")
cursor.execute("INSERT INTO emp VALUES (102, 'Jane', 60000)")
conn.commit()

# Read
cursor.execute("SELECT * FROM emp")
for row in cursor.fetchall():
print(row)

# Update
cursor.execute("UPDATE emp SET salary = 55000 WHERE id = 101")
conn.commit()

# Delete
cursor.execute("DELETE FROM emp WHERE id = 102")
conn.commit()
# Close
cursor.close()
conn.close()