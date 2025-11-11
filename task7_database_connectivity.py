import mysql.connector

# ---------- CONNECT TO DATABASE ----------
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="root",  # change if needed
    database="Saurabh"
)
cursor = db.cursor()


# ---------- MENU ----------
def show_menu():
    print("\n--- Student Database ---")
    print("1. Add Student")
    print("2. View Students")
    print("3. Update Student")
    print("4. Delete Student")
    print("5. Exit")


# ---------- FUNCTIONS ----------
def add_student():
    student_id = int(input("Enter ID: "))
    name = input("Enter Name: ")
    age = int(input("Enter Age: "))
    branch = input("Enter Branch: ")
    cursor.execute(
        "INSERT INTO students VALUES (%s, %s, %s, %s)",
        (student_id, name, age, branch)
    )
    db.commit()
    print("Student added successfully!")


def view_students():
    cursor.execute("SELECT * FROM students")
    records = cursor.fetchall()
    print("\n--- All Students ---")
    for record in records:
        print(record)


def update_student():
    student_id = int(input("Enter ID to update: "))
    name = input("Enter New Name: ")
    age = int(input("Enter New Age: "))
    branch = input("Enter New Branch: ")
    cursor.execute(
        "UPDATE students SET name=%s, age=%s, branch=%s WHERE student_id=%s",
        (name, age, branch, student_id)
    )
    db.commit()
    print("Student updated successfully!")


def delete_student():
    student_id = int(input("Enter ID to delete: "))
    cursor.execute("DELETE FROM students WHERE student_id=%s", (student_id,))
    db.commit()
    print("Student deleted successfully!")

# ---------- MAIN LOOP ----------
if __name__ == "__main__":
    while True:
        show_menu()
        choice = input("Enter choice: ")
        if choice == '1':
            add_student()
        elif choice == '2':
            view_students()
        elif choice == '3':
            update_student()
        elif choice == '4':
            delete_student()
        elif choice == '5':
            print("Goodbye!")
            break
        else:
            print("Invalid choice! Try again.")