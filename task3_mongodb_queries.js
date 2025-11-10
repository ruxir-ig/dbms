// Task 3: MongoDB Queries using CRUD Operations
// Demonstrates: Create, Read, Update, Delete, SAVE method, Logical operators

// Connect to MongoDB (assuming connection is established)
// use studentDB

// ============================================================================
// CREATE Operations - Insert documents
// ============================================================================

// Insert single document
db.students.insertOne({
    student_id: 1001,
    name: "Alice Johnson",
    age: 20,
    email: "alice.j@university.edu",
    department: "Computer Science",
    gpa: 3.8,
    courses: ["CS101", "MATH201", "PHYS101"],
    address: {
        street: "123 Main St",
        city: "Boston",
        state: "MA",
        zipcode: "02101"
    },
    enrollment_date: new Date("2022-08-15"),
    is_active: true
});

// Insert multiple documents
db.students.insertMany([
    {
        student_id: 1002,
        name: "Bob Smith",
        age: 22,
        email: "bob.smith@university.edu",
        department: "Mathematics",
        gpa: 3.5,
        courses: ["MATH301", "STAT202", "CS102"],
        address: {
            street: "456 Oak Ave",
            city: "Cambridge",
            state: "MA",
            zipcode: "02138"
        },
        enrollment_date: new Date("2021-08-20"),
        is_active: true
    },
    {
        student_id: 1003,
        name: "Carol White",
        age: 21,
        email: "carol.w@university.edu",
        department: "Physics",
        gpa: 3.9,
        courses: ["PHYS301", "MATH202", "CS101"],
        address: {
            street: "789 Elm St",
            city: "Boston",
            state: "MA",
            zipcode: "02115"
        },
        enrollment_date: new Date("2022-01-10"),
        is_active: true
    },
    {
        student_id: 1004,
        name: "David Brown",
        age: 23,
        email: "david.b@university.edu",
        department: "Computer Science",
        gpa: 3.2,
        courses: ["CS201", "CS301", "MATH101"],
        address: {
            street: "321 Pine Rd",
            city: "Somerville",
            state: "MA",
            zipcode: "02144"
        },
        enrollment_date: new Date("2020-08-15"),
        is_active: false
    },
    {
        student_id: 1005,
        name: "Emma Davis",
        age: 20,
        email: "emma.d@university.edu",
        department: "Computer Science",
        gpa: 3.95,
        courses: ["CS101", "CS201", "MATH301"],
        address: {
            street: "654 Maple Dr",
            city: "Boston",
            state: "MA",
            zipcode: "02116"
        },
        enrollment_date: new Date("2022-08-15"),
        is_active: true
    }
]);

// ============================================================================
// READ Operations - Query documents
// ============================================================================

// Find all students
db.students.find();

// Find with pretty print
db.students.find().pretty();

// Find students in Computer Science department
db.students.find({ department: "Computer Science" });

// Find students with GPA greater than 3.5
db.students.find({ gpa: { $gt: 3.5 } });

// Find students with GPA between 3.5 and 4.0
db.students.find({ gpa: { $gte: 3.5, $lte: 4.0 } });

// Find students in Boston
db.students.find({ "address.city": "Boston" });

// Find active students with GPA > 3.5 (AND operator)
db.students.find({
    $and: [
        { is_active: true },
        { gpa: { $gt: 3.5 } }
    ]
});

// Find students in CS or Math department (OR operator)
db.students.find({
    $or: [
        { department: "Computer Science" },
        { department: "Mathematics" }
    ]
});

// Find students who are either in CS department OR have GPA > 3.8
db.students.find({
    $or: [
        { department: "Computer Science" },
        { gpa: { $gt: 3.8 } }
    ]
});

// Find students NOT in Computer Science (NOT operator)
db.students.find({
    department: { $ne: "Computer Science" }
});

// Find students with age NOT equal to 20 (NOR operator)
db.students.find({
    $nor: [
        { age: 20 }
    ]
});

// Projection - Select specific fields only
db.students.find(
    { department: "Computer Science" },
    { name: 1, gpa: 1, email: 1, _id: 0 }
);

// Sorting - Sort by GPA descending
db.students.find().sort({ gpa: -1 });

// Limit - Get top 3 students by GPA
db.students.find().sort({ gpa: -1 }).limit(3);

// Count documents
db.students.countDocuments({ department: "Computer Science" });

// Find distinct departments
db.students.distinct("department");

// ============================================================================
// UPDATE Operations - Modify documents
// ============================================================================

// Update single document - Update one student's GPA
db.students.updateOne(
    { student_id: 1001 },
    { $set: { gpa: 3.85 } }
);

// Update multiple documents - Activate all inactive students
db.students.updateMany(
    { is_active: false },
    { $set: { is_active: true } }
);

// Update with $inc operator - Increase age by 1
db.students.updateOne(
    { student_id: 1002 },
    { $inc: { age: 1 } }
);

// Update with $push operator - Add a course to array
db.students.updateOne(
    { student_id: 1001 },
    { $push: { courses: "CS301" } }
);

// Update with $pull operator - Remove a course from array
db.students.updateOne(
    { student_id: 1002 },
    { $pull: { courses: "CS102" } }
);

// Update nested document field
db.students.updateOne(
    { student_id: 1003 },
    { $set: { "address.zipcode": "02116" } }
);

// Update multiple fields at once
db.students.updateOne(
    { student_id: 1004 },
    {
        $set: {
            email: "david.brown@university.edu",
            is_active: true,
            gpa: 3.4
        }
    }
);

// Upsert - Update if exists, insert if not
db.students.updateOne(
    { student_id: 1006 },
    {
        $set: {
            name: "Frank Wilson",
            age: 22,
            email: "frank.w@university.edu",
            department: "Physics",
            gpa: 3.6,
            courses: ["PHYS201", "MATH201"],
            is_active: true
        }
    },
    { upsert: true }
);

// Replace entire document (except _id)
db.students.replaceOne(
    { student_id: 1004 },
    {
        student_id: 1004,
        name: "David Brown Jr.",
        age: 24,
        email: "david.brown.jr@university.edu",
        department: "Computer Science",
        gpa: 3.5,
        courses: ["CS401", "CS402"],
        address: {
            street: "999 New St",
            city: "Boston",
            state: "MA",
            zipcode: "02120"
        },
        enrollment_date: new Date("2020-08-15"),
        is_active: true
    }
);

// ============================================================================
// DELETE Operations - Remove documents
// ============================================================================

// Delete single document
db.students.deleteOne({ student_id: 1006 });

// Delete multiple documents - Remove all inactive students
db.students.deleteMany({ is_active: false });

// Delete students with GPA less than 3.0
db.students.deleteMany({ gpa: { $lt: 3.0 } });

// ============================================================================
// SAVE Method - Insert or Update based on _id
// ============================================================================

// Save method (deprecated in newer versions, but demonstrating concept)
// If document with _id exists, it updates; otherwise inserts

// First get a document
var student = db.students.findOne({ student_id: 1001 });

// Modify it
student.gpa = 3.9;
student.courses.push("CS401");

// Save it back (this will update the existing document)
db.students.save(student);

// Alternative using replaceOne with upsert (modern approach)
db.students.replaceOne(
    { _id: student._id },
    student,
    { upsert: true }
);

// ============================================================================
// Advanced CRUD with Logical Operators
// ============================================================================

// Complex query: Find CS students with GPA > 3.5 AND enrolled after 2021
db.students.find({
    $and: [
        { department: "Computer Science" },
        { gpa: { $gt: 3.5 } },
        { enrollment_date: { $gte: new Date("2021-01-01") } }
    ]
});

// Complex query: Students in Boston OR Cambridge with GPA > 3.7
db.students.find({
    $and: [
        {
            $or: [
                { "address.city": "Boston" },
                { "address.city": "Cambridge" }
            ]
        },
        { gpa: { $gt: 3.7 } }
    ]
});

// Query with $in operator - Students in specific departments
db.students.find({
    department: { $in: ["Computer Science", "Mathematics", "Physics"] }
});

// Query with $nin operator - Students NOT in specific departments
db.students.find({
    department: { $nin: ["Biology", "Chemistry"] }
});

// Query array field - Students taking CS101
db.students.find({
    courses: "CS101"
});

// Query array with $all - Students taking both CS101 and MATH201
db.students.find({
    courses: { $all: ["CS101", "MATH201"] }
});

// Query with $exists - Students with address field
db.students.find({
    address: { $exists: true }
});

// Query with $type - Find documents where age is a number
db.students.find({
    age: { $type: "number" }
});

// Query with $regex - Find students whose name starts with 'A'
db.students.find({
    name: { $regex: "^A", $options: "i" }
});

// ============================================================================
// Aggregation Pipeline Examples
// ============================================================================

// Group by department and calculate average GPA
db.students.aggregate([
    {
        $group: {
            _id: "$department",
            avg_gpa: { $avg: "$gpa" },
            student_count: { $sum: 1 }
        }
    },
    { $sort: { avg_gpa: -1 } }
]);

// Match, project and sort
db.students.aggregate([
    { $match: { is_active: true } },
    {
        $project: {
            name: 1,
            department: 1,
            gpa: 1,
            course_count: { $size: "$courses" }
        }
    },
    { $sort: { gpa: -1 } }
]);

// ============================================================================
// Index Creation for Performance
// ============================================================================

// Create single field index
db.students.createIndex({ student_id: 1 });

// Create compound index
db.students.createIndex({ department: 1, gpa: -1 });

// Create text index for searching
db.students.createIndex({ name: "text", email: "text" });

// List all indexes
db.students.getIndexes();

// ============================================================================
// Bulk Operations
// ============================================================================

db.students.bulkWrite([
    {
        insertOne: {
            document: {
                student_id: 1007,
                name: "Grace Lee",
                age: 21,
                department: "Mathematics",
                gpa: 3.7,
                is_active: true
            }
        }
    },
    {
        updateOne: {
            filter: { student_id: 1001 },
            update: { $set: { gpa: 3.88 } }
        }
    },
    {
        deleteOne: {
            filter: { student_id: 1006 }
        }
    }
]);

print("MongoDB CRUD operations completed successfully!");
