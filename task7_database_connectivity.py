"""
Task 7: Database Connectivity Program
MySQL/Oracle Database Connectivity with Front-End Language (Python)
Implements: Add, Delete, Edit operations (Database Navigation)

This program demonstrates CRUD operations (Create, Read, Update, Delete)
with a database using Python.

Installation Required:
    For MySQL:  pip install mysql-connector-python
    For Oracle: pip install cx_Oracle
"""

import sys

# ============================================================================
# DATABASE CONNECTIVITY - MYSQL VERSION
# ============================================================================

class MySQLDatabaseManager:
    """
    MySQL Database Manager for performing CRUD operations
    """

    def __init__(self, host='localhost', user='root', password='', database='testdb'):
        """Initialize database connection"""
        try:
            import mysql.connector
            self.connection = mysql.connector.connect(
                host=host,
                user=user,
                password=password,
                database=database
            )
            self.cursor = self.connection.cursor()
            print("✓ MySQL Database connected successfully!")
            self.create_table()
        except ImportError:
            print("ERROR: mysql-connector-python not installed.")
            print("Install using: pip install mysql-connector-python")
            sys.exit(1)
        except Exception as e:
            print(f"ERROR: Unable to connect to database: {e}")
            sys.exit(1)

    def create_table(self):
        """Create students table if not exists"""
        try:
            create_table_query = """
            CREATE TABLE IF NOT EXISTS students (
                student_id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                department VARCHAR(50),
                gpa DECIMAL(3,2),
                enrollment_date DATE
            )
            """
            self.cursor.execute(create_table_query)
            self.connection.commit()
            print("✓ Table 'students' verified/created.")
        except Exception as e:
            print(f"ERROR creating table: {e}")

    def add_student(self, name, email, department, gpa, enrollment_date):
        """Add a new student record (CREATE operation)"""
        try:
            insert_query = """
            INSERT INTO students (name, email, department, gpa, enrollment_date)
            VALUES (%s, %s, %s, %s, %s)
            """
            values = (name, email, department, gpa, enrollment_date)
            self.cursor.execute(insert_query, values)
            self.connection.commit()
            print(f"✓ Student '{name}' added successfully! (ID: {self.cursor.lastrowid})")
            return self.cursor.lastrowid
        except Exception as e:
            print(f"ERROR adding student: {e}")
            self.connection.rollback()
            return None

    def view_all_students(self):
        """View all student records (READ operation)"""
        try:
            select_query = "SELECT * FROM students ORDER BY student_id"
            self.cursor.execute(select_query)
            students = self.cursor.fetchall()

            if not students:
                print("No students found in database.")
                return

            print("\n" + "="*100)
            print(f"{'ID':<5} {'Name':<20} {'Email':<30} {'Department':<15} {'GPA':<5} {'Enrollment Date'}")
            print("="*100)

            for student in students:
                student_id, name, email, dept, gpa, enroll_date = student
                print(f"{student_id:<5} {name:<20} {email:<30} {dept:<15} {gpa:<5} {enroll_date}")

            print("="*100)
            print(f"Total Students: {len(students)}\n")

        except Exception as e:
            print(f"ERROR retrieving students: {e}")

    def search_student(self, student_id):
        """Search for a specific student by ID (READ operation)"""
        try:
            select_query = "SELECT * FROM students WHERE student_id = %s"
            self.cursor.execute(select_query, (student_id,))
            student = self.cursor.fetchone()

            if student:
                print("\nStudent Found:")
                print(f"  ID: {student[0]}")
                print(f"  Name: {student[1]}")
                print(f"  Email: {student[2]}")
                print(f"  Department: {student[3]}")
                print(f"  GPA: {student[4]}")
                print(f"  Enrollment Date: {student[5]}")
                return student
            else:
                print(f"No student found with ID: {student_id}")
                return None

        except Exception as e:
            print(f"ERROR searching student: {e}")
            return None

    def update_student(self, student_id, name=None, email=None, department=None, gpa=None):
        """Update student record (UPDATE operation)"""
        try:
            # Build dynamic update query based on provided fields
            update_fields = []
            values = []

            if name:
                update_fields.append("name = %s")
                values.append(name)
            if email:
                update_fields.append("email = %s")
                values.append(email)
            if department:
                update_fields.append("department = %s")
                values.append(department)
            if gpa is not None:
                update_fields.append("gpa = %s")
                values.append(gpa)

            if not update_fields:
                print("No fields to update!")
                return

            values.append(student_id)
            update_query = f"UPDATE students SET {', '.join(update_fields)} WHERE student_id = %s"

            self.cursor.execute(update_query, tuple(values))
            self.connection.commit()

            if self.cursor.rowcount > 0:
                print(f"✓ Student ID {student_id} updated successfully!")
            else:
                print(f"No student found with ID: {student_id}")

        except Exception as e:
            print(f"ERROR updating student: {e}")
            self.connection.rollback()

    def delete_student(self, student_id):
        """Delete a student record (DELETE operation)"""
        try:
            # First check if student exists
            if not self.search_student(student_id):
                return

            confirm = input(f"\nAre you sure you want to delete student ID {student_id}? (yes/no): ")
            if confirm.lower() != 'yes':
                print("Delete operation cancelled.")
                return

            delete_query = "DELETE FROM students WHERE student_id = %s"
            self.cursor.execute(delete_query, (student_id,))
            self.connection.commit()
            print(f"✓ Student ID {student_id} deleted successfully!")

        except Exception as e:
            print(f"ERROR deleting student: {e}")
            self.connection.rollback()

    def close(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
        print("✓ Database connection closed.")


# ============================================================================
# DATABASE CONNECTIVITY - ORACLE VERSION
# ============================================================================

class OracleDatabaseManager:
    """
    Oracle Database Manager for performing CRUD operations
    """

    def __init__(self, username='system', password='password', dsn='localhost:1521/xe'):
        """Initialize Oracle database connection"""
        try:
            import cx_Oracle
            self.connection = cx_Oracle.connect(
                user=username,
                password=password,
                dsn=dsn
            )
            self.cursor = self.connection.cursor()
            print("✓ Oracle Database connected successfully!")
            self.create_table()
        except ImportError:
            print("ERROR: cx_Oracle not installed.")
            print("Install using: pip install cx_Oracle")
            sys.exit(1)
        except Exception as e:
            print(f"ERROR: Unable to connect to database: {e}")
            sys.exit(1)

    def create_table(self):
        """Create students table if not exists"""
        try:
            # Create sequence for auto-increment
            try:
                self.cursor.execute("CREATE SEQUENCE student_seq START WITH 1 INCREMENT BY 1")
            except:
                pass  # Sequence might already exist

            create_table_query = """
            CREATE TABLE students (
                student_id NUMBER PRIMARY KEY,
                name VARCHAR2(100) NOT NULL,
                email VARCHAR2(100) UNIQUE NOT NULL,
                department VARCHAR2(50),
                gpa NUMBER(3,2),
                enrollment_date DATE
            )
            """
            self.cursor.execute(create_table_query)
            self.connection.commit()
            print("✓ Table 'students' created.")
        except Exception as e:
            # Table might already exist
            pass

    def add_student(self, name, email, department, gpa, enrollment_date):
        """Add a new student record (CREATE operation)"""
        try:
            insert_query = """
            INSERT INTO students (student_id, name, email, department, gpa, enrollment_date)
            VALUES (student_seq.NEXTVAL, :name, :email, :dept, :gpa, TO_DATE(:date, 'YYYY-MM-DD'))
            """
            self.cursor.execute(insert_query, {
                'name': name,
                'email': email,
                'dept': department,
                'gpa': gpa,
                'date': enrollment_date
            })
            self.connection.commit()
            print(f"✓ Student '{name}' added successfully!")
        except Exception as e:
            print(f"ERROR adding student: {e}")
            self.connection.rollback()

    def view_all_students(self):
        """View all student records (READ operation)"""
        try:
            select_query = "SELECT * FROM students ORDER BY student_id"
            self.cursor.execute(select_query)
            students = self.cursor.fetchall()

            if not students:
                print("No students found in database.")
                return

            print("\n" + "="*100)
            print(f"{'ID':<5} {'Name':<20} {'Email':<30} {'Department':<15} {'GPA':<5} {'Enrollment Date'}")
            print("="*100)

            for student in students:
                print(f"{student[0]:<5} {student[1]:<20} {student[2]:<30} {student[3]:<15} {student[4]:<5} {student[5]}")

            print("="*100)
            print(f"Total Students: {len(students)}\n")

        except Exception as e:
            print(f"ERROR retrieving students: {e}")

    def update_student(self, student_id, name=None, email=None, department=None, gpa=None):
        """Update student record (UPDATE operation)"""
        try:
            update_fields = []
            params = {'student_id': student_id}

            if name:
                update_fields.append("name = :name")
                params['name'] = name
            if email:
                update_fields.append("email = :email")
                params['email'] = email
            if department:
                update_fields.append("department = :dept")
                params['dept'] = department
            if gpa is not None:
                update_fields.append("gpa = :gpa")
                params['gpa'] = gpa

            if not update_fields:
                print("No fields to update!")
                return

            update_query = f"UPDATE students SET {', '.join(update_fields)} WHERE student_id = :student_id"
            self.cursor.execute(update_query, params)
            self.connection.commit()

            if self.cursor.rowcount > 0:
                print(f"✓ Student ID {student_id} updated successfully!")
            else:
                print(f"No student found with ID: {student_id}")

        except Exception as e:
            print(f"ERROR updating student: {e}")
            self.connection.rollback()

    def delete_student(self, student_id):
        """Delete a student record (DELETE operation)"""
        try:
            delete_query = "DELETE FROM students WHERE student_id = :id"
            self.cursor.execute(delete_query, {'id': student_id})
            self.connection.commit()

            if self.cursor.rowcount > 0:
                print(f"✓ Student ID {student_id} deleted successfully!")
            else:
                print(f"No student found with ID: {student_id}")

        except Exception as e:
            print(f"ERROR deleting student: {e}")
            self.connection.rollback()

    def close(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()
        print("✓ Database connection closed.")


# ============================================================================
# INTERACTIVE MENU SYSTEM
# ============================================================================

def display_menu():
    """Display main menu"""
    print("\n" + "="*50)
    print("   STUDENT DATABASE MANAGEMENT SYSTEM")
    print("="*50)
    print("1. Add New Student")
    print("2. View All Students")
    print("3. Search Student by ID")
    print("4. Update Student Information")
    print("5. Delete Student")
    print("6. Exit")
    print("="*50)


def main():
    """Main program execution"""
    print("="*50)
    print("  DATABASE CONNECTIVITY DEMONSTRATION")
    print("="*50)
    print("\nSelect Database Type:")
    print("1. MySQL")
    print("2. Oracle")
    print("3. Exit")

    choice = input("\nEnter choice (1-3): ")

    if choice == '1':
        # MySQL Connection
        host = input("Enter MySQL host (default: localhost): ") or 'localhost'
        user = input("Enter MySQL username (default: root): ") or 'root'
        password = input("Enter MySQL password: ")
        database = input("Enter database name (default: testdb): ") or 'testdb'

        try:
            db = MySQLDatabaseManager(host, user, password, database)
        except:
            return

    elif choice == '2':
        # Oracle Connection
        username = input("Enter Oracle username (default: system): ") or 'system'
        password = input("Enter Oracle password: ")
        dsn = input("Enter DSN (default: localhost:1521/xe): ") or 'localhost:1521/xe'

        try:
            db = OracleDatabaseManager(username, password, dsn)
        except:
            return

    else:
        print("Exiting...")
        return

    # Main menu loop
    while True:
        display_menu()
        choice = input("\nEnter your choice (1-6): ")

        if choice == '1':
            # Add Student
            print("\n--- Add New Student ---")
            name = input("Enter name: ")
            email = input("Enter email: ")
            department = input("Enter department: ")
            gpa = float(input("Enter GPA (0.0 - 4.0): "))
            enrollment_date = input("Enter enrollment date (YYYY-MM-DD): ")

            db.add_student(name, email, department, gpa, enrollment_date)

        elif choice == '2':
            # View All Students
            db.view_all_students()

        elif choice == '3':
            # Search Student
            student_id = int(input("\nEnter student ID to search: "))
            db.search_student(student_id)

        elif choice == '4':
            # Update Student
            print("\n--- Update Student Information ---")
            student_id = int(input("Enter student ID to update: "))

            print("Leave blank to skip updating a field")
            name = input("Enter new name: ") or None
            email = input("Enter new email: ") or None
            department = input("Enter new department: ") or None
            gpa_input = input("Enter new GPA: ")
            gpa = float(gpa_input) if gpa_input else None

            db.update_student(student_id, name, email, department, gpa)

        elif choice == '5':
            # Delete Student
            student_id = int(input("\nEnter student ID to delete: "))
            db.delete_student(student_id)

        elif choice == '6':
            # Exit
            print("\nThank you for using the Student Database Management System!")
            db.close()
            break

        else:
            print("Invalid choice! Please enter a number between 1-6.")


if __name__ == "__main__":
    main()
