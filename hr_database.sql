
-- ============================================
-- THD HR CONTROL CENTER DATABASE SCHEMA
-- ============================================

CREATE DATABASE thd_hr_control_center;

USE thd_hr_control_center;

-- ============================================
-- USERS TABLE
-- HR Admins / Recruiters
-- ============================================

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Admin', 'Recruiter', 'HR Manager') DEFAULT 'Recruiter',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- DEPARTMENTS TABLE
-- ============================================

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- JOB POSTINGS TABLE
-- ============================================

CREATE TABLE jobs (
    job_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    department_id INT NOT NULL,
    description TEXT,
    status ENUM('Draft', 'Review', 'Published', 'Closed') DEFAULT 'Draft',
    applicants_count INT DEFAULT 0,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_jobs_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_jobs_user
        FOREIGN KEY (created_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL
);

-- ============================================
-- APPLICANTS TABLE
-- ============================================

CREATE TABLE applicants (
    applicant_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(30),
    resume_url VARCHAR(255),
    skills TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- JOB APPLICATIONS TABLE
-- ============================================

CREATE TABLE applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    applicant_id INT NOT NULL,
    job_id INT NOT NULL,

    status ENUM(
        'New Application',
        'Under Review',
        'Interview',
        'Rejected',
        'Hired'
    ) DEFAULT 'New Application',

    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_application_applicant
        FOREIGN KEY (applicant_id)
        REFERENCES applicants(applicant_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_application_job
        FOREIGN KEY (job_id)
        REFERENCES jobs(job_id)
        ON DELETE CASCADE
);

-- ============================================
-- INTERVIEWS TABLE
-- ============================================

CREATE TABLE interviews (
    interview_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    interview_date DATETIME NOT NULL,
    interview_mode ENUM('Online', 'Onsite', 'Phone') DEFAULT 'Online',
    interviewer_name VARCHAR(100),
    notes TEXT,
    result ENUM('Pending', 'Passed', 'Failed') DEFAULT 'Pending',

    CONSTRAINT fk_interview_application
        FOREIGN KEY (application_id)
        REFERENCES applications(application_id)
        ON DELETE CASCADE
);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================

CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notification_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- ============================================
-- ANALYTICS TABLE
-- ============================================

CREATE TABLE analytics (
    analytics_id INT PRIMARY KEY AUTO_INCREMENT,
    total_jobs INT DEFAULT 0,
    total_applicants INT DEFAULT 0,
    interviews_scheduled INT DEFAULT 0,
    successful_hires INT DEFAULT 0,
    reviewed_percentage DECIMAL(5,2) DEFAULT 0,
    interview_completion_percentage DECIMAL(5,2) DEFAULT 0,
    hiring_completion_percentage DECIMAL(5,2) DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- SAMPLE DEPARTMENTS
-- ============================================

INSERT INTO departments (department_name, description)
VALUES
('IT Services', 'Technical support and infrastructure'),
('AI Research Lab', 'Artificial Intelligence research'),
('Marketing', 'Marketing and communications');

-- ============================================
-- SAMPLE USERS
-- ============================================

INSERT INTO users (full_name, email, password_hash, role)
VALUES
('HR Administrator', 'admin@thdhr.com', 'hashed_password_here', 'Admin');

-- ============================================
-- SAMPLE JOBS
-- ============================================

INSERT INTO jobs (
    title,
    department_id,
    description,
    status,
    applicants_count,
    created_by
)
VALUES
(
    'Student Assistant - IT Support',
    1,
    'Assist with IT support tasks',
    'Published',
    12,
    1
),
(
    'Research Assistant',
    2,
    'Support AI research activities',
    'Review',
    9,
    1
),
(
    'Marketing Student Worker',
    3,
    'Assist marketing campaigns',
    'Published',
    21,
    1
);

-- ============================================
-- SAMPLE APPLICANTS
-- ============================================

INSERT INTO applicants (
    first_name,
    last_name,
    email,
    phone,
    skills
)
VALUES
('Anna', 'Schmidt', 'anna@example.com', '+49123456789', 'Frontend, React'),
('John', 'Miller', 'john@example.com', '+49111111111', 'Research, Python'),
('Lisa', 'Wagner', 'lisa@example.com', '+49222222222', 'UI/UX, Figma');

-- ============================================
-- SAMPLE APPLICATIONS
-- ============================================

INSERT INTO applications (
    applicant_id,
    job_id,
    status
)
VALUES
(1, 1, 'New Application'),
(2, 2, 'Under Review'),
(3, 3, 'Interview');

-- ============================================
-- SAMPLE INTERVIEWS
-- ============================================

INSERT INTO interviews (
    application_id,
    interview_date,
    interview_mode,
    interviewer_name,
    result
)
VALUES
(
    3,
    '2026-05-20 10:00:00',
    'Online',
    'HR Administrator',
    'Pending'
);

-- ============================================
-- SAMPLE ANALYTICS
-- ============================================

INSERT INTO analytics (
    total_jobs,
    total_applicants,
    interviews_scheduled,
    successful_hires,
    reviewed_percentage,
    interview_completion_percentage,
    hiring_completion_percentage
)
VALUES
(
    12,
    148,
    24,
    8,
    75.00,
    55.00,
    35.00
);

-- ============================================
-- USEFUL VIEWS
-- ============================================

CREATE VIEW active_jobs AS
SELECT
    j.job_id,
    j.title,
    d.department_name,
    j.status,
    j.applicants_count,
    j.created_at
FROM jobs j
JOIN departments d
ON j.department_id = d.department_id
WHERE j.status IN ('Published', 'Review');

-- ============================================
-- STORED PROCEDURE
-- CREATE NEW JOB
-- ============================================

DELIMITER $$

CREATE PROCEDURE create_job (
    IN p_title VARCHAR(150),
    IN p_department_id INT,
    IN p_description TEXT,
    IN p_status VARCHAR(20),
    IN p_created_by INT
)
BEGIN
    INSERT INTO jobs (
        title,
        department_id,
        description,
        status,
        created_by
    )
    VALUES (
        p_title,
        p_department_id,
        p_description,
        p_status,
        p_created_by
    );
END $$

DELIMITER ;

-- ============================================
-- TRIGGER TO UPDATE APPLICANTS COUNT
-- ============================================

DELIMITER $$

CREATE TRIGGER update_applicant_count
AFTER INSERT ON applications
FOR EACH ROW
BEGIN
    UPDATE jobs
    SET applicants_count = applicants_count + 1
    WHERE job_id = NEW.job_id;
END $$

DELIMITER ;